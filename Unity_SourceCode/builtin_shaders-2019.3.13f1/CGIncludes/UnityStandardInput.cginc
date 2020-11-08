// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_INPUT_INCLUDED
#define UNITY_STANDARD_INPUT_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityPBSLighting.cginc" // TBD: remove
#include "UnityStandardUtils.cginc"

//---------------------------------------
// Directional lightmaps & Parallax require tangent space too
#if (_NORMALMAP || DIRLIGHTMAP_COMBINED || _PARALLAXMAP)
    #define _TANGENT_TO_WORLD 1
#endif

#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
    #define _DETAIL 1
#endif

//---------------------------------------
half4       _Color;
half        _Cutoff;

sampler2D   _MainTex;
float4      _MainTex_ST;

sampler2D   _DetailAlbedoMap;
float4      _DetailAlbedoMap_ST;

sampler2D   _BumpMap;
half        _BumpScale;

sampler2D   _DetailMask;
sampler2D   _DetailNormalMap;
half        _DetailNormalMapScale;

sampler2D   _SpecGlossMap;
sampler2D   _MetallicGlossMap;
half        _Metallic;
float       _Glossiness;
float       _GlossMapScale;

sampler2D   _OcclusionMap;
half        _OcclusionStrength;

sampler2D   _ParallaxMap;
half        _Parallax;
half        _UVSec;

half4       _EmissionColor;
sampler2D   _EmissionMap;

//-------------------------------------------------------------------------------------
// Input functions

struct VertexInput //1.00
{
    float4 vertex   : POSITION; 
    half3 normal    : NORMAL;
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
    #if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
        float2 uv2      : TEXCOORD2; 
    #endif
    #ifdef _TANGENT_TO_WORLD
        half4 tangent   : TANGENT; 
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID 
};

float4 TexCoords(VertexInput v) //1.1
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0
    //UV0 主贴图纹理
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    //detail 纹理 经过面板选择用uv0 还是uv1
    return texcoord;
}

half DetailMask(float2 uv)
{
    return tex2D (_DetailMask, uv).a;
}

half3 Albedo(float4 texcoords) //003a1
{ //参数为float4 两个UV信息
// 输入 i_tex.xyzw
// 输出 half3 albedo
    half3 albedo = _Color.rgb * tex2D (_MainTex, texcoords.xy).rgb;
    //获取abledo贴图 并且混合面板颜色
    #if _DETAIL
    //如果启用面板细节 detail mask属性
        #if (SHADER_TARGET < 30)
        //如果shader model 小于3.0
            // SM20: instruction count limitation
            // SM20: no detail mask
            half mask = 1; //shader model条件限制 所以直接使用1 不使用Detail mask功能
        #else
        //否则shader model 不小于3.0 那么
            half mask = DetailMask(texcoords.xy); //函数调用  return tex2D (_DetailMask, uv).a;
            //mask 值为 面板纹理_DetailMask 的A通道
        #endif
        half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
        //获取detail albedo.rgb
        #if _DETAIL_MULX2
            albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask); //函数调用
            //(1-t) + b * t  LerpWhiteTo(half3 b, half t)
            //linear #define unity_ColorSpaceDouble fixed4(4.59479380, 4.59479380, 4.59479380, 2.0)
            //gamma #define unity_ColorSpaceDouble fixed4(2.0, 2.0, 2.0, 2.0)
            //管线不同值不同
        #elif _DETAIL_MUL
            albedo *= LerpWhiteTo (detailAlbedo, mask);
            //(1-t) + b * t  LerpWhiteTo(half3 b, half t)
            //普通相乘
        #elif _DETAIL_ADD
            albedo += detailAlbedo * mask;
            //普通相加
        #elif _DETAIL_LERP
            //普通lerp
            albedo = lerp (albedo, detailAlbedo, mask);
        #endif
    #endif
    return albedo;    //返回最终aldedo
}

half Alpha(float2 uv)  //2.2.2
{
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        return _Color.a;
    #else
        return tex2D(_MainTex, uv).a * _Color.a;
    #endif
}

half Occlusion(float2 uv) //115a
{
    #if (SHADER_TARGET < 30)
        // SM20：指令计数限制
        // SM20：更简单的遮挡
        return tex2D(_OcclusionMap, uv).g;
    #else
        half occ = tex2D(_OcclusionMap, uv).g;
        return LerpOneTo (occ, _OcclusionStrength);
        //控制条反向下 
    #endif
}

half4 SpecularGloss(float2 uv)
{
    half4 sg;
#ifdef _SPECGLOSSMAP
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        sg.rgb = tex2D(_SpecGlossMap, uv).rgb;
        sg.a = tex2D(_MainTex, uv).a;
    #else
        sg = tex2D(_SpecGlossMap, uv);
    #endif
    sg.a *= _GlossMapScale;
#else
    sg.rgb = _SpecColor.rgb;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        sg.a = tex2D(_MainTex, uv).a * _GlossMapScale;
    #else
        sg.a = _Glossiness;
    #endif
#endif
    return sg;
}

half2 MetallicGloss(float2 uv)  //002a
{
    // 输入 float2  i_tex.xy
    // 输出 half2 metallic roughness贴图信息
    half2 mg; //变量声明
    #ifdef _METALLICGLOSSMAP
    //这里用来判断是否被赋值纹理图
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        //如果roughness在albedo A通道
            mg.r = tex2D(_MetallicGlossMap, uv).r; 
            //metallic值使用资源metallic图R通道
            mg.g = tex2D(_MainTex, uv).a; 
            //roughness使用资源的Albedo图A通道
        #else
        //否则
            mg = tex2D(_MetallicGlossMap, uv).ra;
            //直接使用Metallic Roughness资源图RA通道
        #endif
        mg.g *= _GlossMapScale; //最后混合roughness 面板参数0-1强度控制
        //从此处也能看出，在正确的工作流中。不会把Metallic给0-1提供变量乱调整
        //因为在物质切片中，Albedo与metallic对应关系对于错在渲染中太重要了。
    #else
    //如果没有纹理图输入 
        mg.r = _Metallic; //直接 使用面板参数 0-1强度控制
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A   
        //如果roughness在albedo A通道
            mg.g = tex2D(_MainTex, uv).a * _GlossMapScale;
            // roughness使用资源的Albedo图A通道 并面板参数0-1强度控制 
        #else 
        //否则 
            mg.g = _Glossiness; //直接 使用面板参数Smoothness 0-1强度控制
        #endif
    #endif
    return mg;  //返回metallic和roughness
}

half2 MetallicRough(float2 uv)
{
    half2 mg;
#ifdef _METALLICGLOSSMAP
    mg.r = tex2D(_MetallicGlossMap, uv).r;
#else
    mg.r = _Metallic;
#endif

#ifdef _SPECGLOSSMAP
    mg.g = 1.0f - tex2D(_SpecGlossMap, uv).r;
#else
    mg.g = 1.0f - _Glossiness;
#endif
    return mg;
}

half3 Emission(float2 uv)
{
#ifndef _EMISSION
    return 0;
#else
    return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
#endif
}

#ifdef _NORMALMAP
// 如果有定义 _NORMALMAP
    half3 NormalInTangentSpace(float4 texcoords)
    {
        half3 normalTangent = UnpackScaleNormal(tex2D (_BumpMap, texcoords.xy), _BumpScale);
        // 解法线，并使用_BumpScale控制强度
            #if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
            // 如果定义 _DETAIL 和已定义 UNITY_ENABLE_DETAIL_NORMALMAP
                half mask = DetailMask(texcoords.xy);
                half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
                #if _DETAIL_LERP
                    normalTangent = lerp(
                        normalTangent,
                        detailNormalTangent,
                        mask);
                #else
                    normalTangent = lerp(
                        normalTangent,
                        BlendNormals(normalTangent, detailNormalTangent),
                        mask);
                #endif
            #endif
        return normalTangent;
    }
#endif

float4 Parallax (float4 texcoords, half3 viewDir)  //2.2.1
{
    #if !defined(_PARALLAXMAP) || (SHADER_TARGET < 30)
        // 如果没有定义_PARALLAXMAP 或者 渲染模型低于3.0 返回原数值
        return texcoords;
    #else
        //否则 视差高度UV偏移计算
        half h = tex2D (_ParallaxMap, texcoords.xy).g;
        float2 offset = ParallaxOffset1Step (h, _Parallax, viewDir);
        return float4(texcoords.xy + offset, texcoords.zw + offset);
    #endif
}

#endif // UNITY_STANDARD_INPUT_INCLUDED
