// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_CORE_INCLUDED
#define UNITY_STANDARD_CORE_INCLUDED

#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityStandardInput.cginc"
#include "UnityPBSLighting.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityGBuffer.cginc"
#include "UnityStandardBRDF.cginc"

#include "AutoLight.cginc"
//-------------------------------------------------------------------------------------
// NormalizePerPixelNormal的对应项
//跳过每个顶点的归一化，并期望每个像素进行归一化
half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow//进行浮点运算以避免溢出
{   //1.2
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
    //如果shader model 小于3.0 或者simple开启
        return normalize(n);
        //返回归一化计算
    #else
    //如果shader model 小于3.0 或者simple开启 以外
        return n; // will normalize per-pixel instead
        //返回原数据，打算在fragment (pixel) 里面计算
    #endif
}

float3 NormalizePerPixelNormal (float3 n)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return n;
    #else
        return normalize((float3)n); //进行浮动以避免溢出
    #endif
}

//-------------------------------------------------------------------------------------
// struct UnityLight 结构体（从lightngCommon文件挪过来的)
// {
//     half3 color;
//     half3 dir;
//     half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it.
// };
UnityLight MainLight () //113a
{
    UnityLight l;
    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz; 
    return l;
}

UnityLight AdditiveLight (half3 lightDir, half atten)
{
    UnityLight l;

    l.color = _LightColor0.rgb;
    l.dir = lightDir;
    #ifndef USING_DIRECTIONAL_LIGHT
        l.dir = NormalizePerPixelNormal(l.dir);
    #endif

    // shadow the light
    l.color *= atten;
    return l;
}

UnityLight DummyLight ()
{
    UnityLight l;
    l.color = 0;
    l.dir = half3 (0,1,0);
    return l;
}

UnityIndirect ZeroIndirect ()
{
    UnityIndirect ind;
    ind.diffuse = 0;
    ind.specular = 0;
    return ind;
}

//-------------------------------------------------------------------------------------
// Common fragment setup

// deprecated
//不推荐使用
half3 WorldNormal(half4 tan2world[3])
{
    return normalize(tan2world[2].xyz);
}

// deprecated
//不推荐使用
#ifdef _TANGENT_TO_WORLD
    half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
    {
        half3 t = tan2world[0].xyz;
        half3 b = tan2world[1].xyz;
        half3 n = tan2world[2].xyz;

    #if UNITY_TANGENT_ORTHONORMALIZE
        n = NormalizePerPixelNormal(n);

        // ortho-normalize Tangent
        t = normalize (t - n * dot(t, n));

        // recalculate Binormal
        half3 newB = cross(n, t);
        b = newB * sign (dot (newB, b));
    #endif

        return half3x3(t, b, n);
    }
#else
    half3x3 ExtractTangentToWorldPerPixel(half4 tan2world[3])
    {
        return half3x3(0,0,0,0,0,0,0,0,0);
    }
#endif

float3 PerPixelWorldNormal(float4 i_tex, float4 tangentToWorld[3])
{//2.2.4
    #ifdef _NORMALMAP
    // 如果材质球使用了法线贴图
        half3 tangent = tangentToWorld[0].xyz; //切线
        half3 binormal = tangentToWorld[1].xyz; //副法线
        half3 normal = tangentToWorld[2].xyz; //法线
        #if UNITY_TANGENT_ORTHONORMALIZE
        //如果需要对切线空间的3个坐标值进行正交单位化
            normal = NormalizePerPixelNormal(normal);
            // ortho-normalize Tangent 单位化法向量
            tangent = normalize (tangent - normal * dot(tangent, normal));
            // recalculate Binormal 如果原本切线与法线相互垂直，则dot(tangent, normal)为0
            // 如果不垂直，则切线等于三角形斜边，法线为一个直角边
            // tangent - normal * dot(tanget, normal) 为另一边
            half3 newB = cross(normal, tangent);
            // 调整法线和切线使之相互垂直之后，重新计算副法线
            binormal = newB * sign (dot (newB, binormal));
        #endif
        half3 normalTangent = NormalInTangentSpace(i_tex);
        // 切线空间下的法向量
        float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); 
        // @TODO：看看我们是否也可以在SM2.0上进行压缩
        //法线贴图 从切线空间转到世界空间 单位化法向量
    #else
        float3 normalWorld = normalize(tangentToWorld[2].xyz);
        //顶点法线的归一化
    #endif
    return normalWorld;
}

#ifdef _PARALLAXMAP  //112a2
    #define IN_VIEWDIR4PARALLAX(i) NormalizePerPixelNormal(half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w))
    #define IN_VIEWDIR4PARALLAX_FWDADD(i) NormalizePerPixelNormal(i.viewDirForParallax.xyz)
#else
    #define IN_VIEWDIR4PARALLAX(i) half3(0,0,0)
    #define IN_VIEWDIR4PARALLAX_FWDADD(i) half3(0,0,0)
#endif

#if UNITY_REQUIRE_FRAG_WORLDPOS  //112a3
    #if UNITY_PACK_WORLDPOS_WITH_TANGENT
        #define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)
    #else
        #define IN_WORLDPOS(i) i.posWorld
    #endif
    #define IN_WORLDPOS_FWDADD(i) i.posWorld
#else
    #define IN_WORLDPOS(i) half3(0,0,0)
    #define IN_WORLDPOS_FWDADD(i) half3(0,0,0)
#endif

#define IN_LIGHTDIR_FWDADD(i) half3(i.tangentToWorldAndLightDir[0].w, i.tangentToWorldAndLightDir[1].w, i.tangentToWorldAndLightDir[2].w)

#define FRAGMENT_SETUP(x) FragmentCommonData x = \   
    FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i)); 
    //输入 
    // i.tex = UV0 UV1(细节)
    // i.eyeVec.xyz 裁剪空间下的片元到相机向量
    // IN_VIEWDIR4PARALLAX(i) //112a2 切线空间下片元到相机向量
    // IN_WORLDPOS(i) //112a3 片元在切线空间下的相关信息

#define FRAGMENT_SETUP_FWDADD(x) FragmentCommonData x = \
    FragmentSetup(i.tex, i.eyeVec.xyz, IN_VIEWDIR4PARALLAX_FWDADD(i), i.tangentToWorldAndLightDir, IN_WORLDPOS_FWDADD(i));

struct FragmentCommonData
{
    half3 diffColor, specColor;
    //diffColor 漫反射颜色 specColor 漫反射高光    
    //注意：出于优化目的，smoothness和oneMinusReflectivity主要用于DX9 SM2.0级别。
    //大部分数学运算都是在这些（1-x）值上完成的，这样可以节省一些宝贵的ALU插槽。
    half oneMinusReflectivity, smoothness;
    //oneMinusReflectivity 1－F0
    //smoothness roughness 
    float3 normalWorld;    //worldspace normal vector
    float3 eyeVec;    //worldspace 相机到顶点 vector
    half alpha;
    float3 posWorld;    //fragment worldspace postion
    #if UNITY_STANDARD_SIMPLE
        half3 reflUVW; //worldspace pix 到相机 vector  也相当于 invert eyeVec vector
    #endif
    #if UNITY_STANDARD_SIMPLE
        half3 tangentSpaceNormal; //tangentspace normal vector
    #endif
};

#ifndef UNITY_SETUP_BRDF_INPUT
    #define UNITY_SETUP_BRDF_INPUT SpecularSetup
#endif

inline FragmentCommonData SpecularSetup (float4 i_tex)
{
    half4 specGloss = SpecularGloss(i_tex.xy);
    half3 specColor = specGloss.rgb;
    half smoothness = specGloss.a;

    half oneMinusReflectivity;
    half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

inline FragmentCommonData RoughnessSetup(float4 i_tex)
{
    half2 metallicGloss = MetallicRough(i_tex.xy);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic(Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

inline FragmentCommonData MetallicSetup (float4 i_tex)  ////2.2.3
{
    half2 metallicGloss = MetallicGloss(i_tex.xy);     //002a   //函数调取
    //得到原始metallic 原始roughness
    half metallic = metallicGloss.x; //原始metallic 
    half smoothness = metallicGloss.y; //原始roughness// this is 1 minus the square root of real roughness m.
    //这是1减去实际粗糙度m的平方根  1-CookTorrance_roughness 平方根 平方根概念：比如 9 的平方根是3和-3。
    half oneMinusReflectivity; //out变量声明
    half3 specColor;   //out变量声明
    half3 diffColor = DiffuseAndSpecularFromMetallic (Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity); //003a                                                        
                                                    //003a1
    FragmentCommonData o = (FragmentCommonData)0; //结构体声明，及给上0参。 //004a
    o.diffColor = diffColor; //漫反射颜色部分 
    o.specColor = specColor; //F0 
    o.oneMinusReflectivity = oneMinusReflectivity;  //1-F0 
    o.smoothness = smoothness; //roughness 
    return o;
}


// 输入 2.2.00
// float3 i_eyeVec
// half3 i_viewDirForParallax
// float4 tangentToWorld[3]
// float3 i_posWorld

// parallax transformed texcoord is used to sample occlusion
// /视差转换的texcoord用于采样遮挡
// base 与 add 输入参数是不一样的
inline FragmentCommonData FragmentSetup (inout float4 i_tex, float3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld)
{
    i_tex = Parallax(i_tex, i_viewDirForParallax);    //视差//2.2.1
    half alpha = Alpha(i_tex.xy); //透明信息计算 //2.2.2
    #if defined(_ALPHATEST_ON)
        clip (alpha - _Cutoff); //如果是alpha test  丢弃使用
    #endif
    FragmentCommonData o = UNITY_SETUP_BRDF_INPUT (i_tex); //2.2.3 //MetallicSetup 
    //检测金属流还是高光流 不同的shader线路切换 一系列的函数调用都不再相同 得到metallic 计算后的相关数据
    o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld); //2.2.4
    //如果有法线图就得到转换过后的法线图信息 如果没有就使用归一化后的顶点法线 两种方案
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec); //2.2.5
    //判断平台后 归一化
    o.posWorld = i_posWorld;
    // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    //注意：着色器依赖于预乘alpha混合（_SrcBlend = One，_DstBlend = OneMinusSrcAlpha）
    //alpha Reflectivity metallic 值都会影响abledo 
    o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha); //2.2.6
    return o;
}

inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light, bool reflections) 
{   //2.6
    UnityGIInput d;
    d.light = light;
    d.worldPos = s.posWorld;
    d.worldViewDir = -s.eyeVec; //worldspace 相机向量
    d.atten = atten;    //光照衰减
    d.ambient = i_ambientOrLightmapUV.rgb;
    d.lightmapUV = 0;
    //两个反射探针（反射球）各项属性
    d.probeHDR[0] = unity_SpecCube0_HDR;//记录全局光照所要使用的光探针
    d.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
      d.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
      // .w保留lerp值以进行混合
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
      d.boxMax[0] = unity_SpecCube0_BoxMax;
      d.probePosition[0] = unity_SpecCube0_ProbePosition;
      d.boxMax[1] = unity_SpecCube1_BoxMax;
      d.boxMin[1] = unity_SpecCube1_BoxMin;
      d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif
    if(reflections)
    {//如果反射
        Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.smoothness, -s.eyeVec, s.normalWorld, s.specColor);  //2.6.1
        // 获取IBL计算所需的结构体 
        //s.specColor ＝ fresnel0 参数都没用上
        // Replace the reflUVW if it has been compute in Vertex shader. Note: the compiler will optimize the calcul in UnityGlossyEnvironmentSetup itself
        //如果reflUVW已在Vertex着色器中计算，则将其替换。 注意：编译器将在UnityGlossyEnvironmentSetup自身中优化计算
        //结构体 Unity_GlossyEnvironmentData 返回两个数据 half roughness，half3 reflUVW
        #if UNITY_STANDARD_SIMPLE
        //如果是简化版 就直接使用simple版本的
            g.reflUVW = s.reflUVW;
        #endif
        return UnityGlobalIllumination (d, occlusion, s.normalWorld, g); //2.6.2
        // 间接照明的漫反射 + 镜面反射部分
    }
    else //否则 
    {
        return UnityGlobalIllumination (d, occlusion, s.normalWorld); //2.6.3
        // 间接照明的漫反射
    }
}
inline UnityGI FragmentGI (FragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, UnityLight light) //2.6
{
    return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, true); //2.6
}


//-------------------------------------------------------------------------------------
half4 OutputForward (half4 output, half alphaFromSurface)
{
    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
        output.a = alphaFromSurface;
    #else
        UNITY_OPAQUE_ALPHA(output.a);
    #endif
    return output;
}

inline half4 VertexGIForward(VertexInput v, float3 posWorld, half3 normalWorld) 
{   //1.5
    half4 ambientOrLightmapUV = 0;   
    #ifdef LIGHTMAP_ON
    //如果定义LIGHTMAP_ON 
        ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        //xy输入lightmap uv
        ambientOrLightmapUV.zw = 0;
    //仅针对动态对象的采样光探针（无静态或动态光照贴图）
    #elif UNITY_SHOULD_SAMPLE_SH
    //否则如果 SH 
        #ifdef VERTEXLIGHT_ON
        //顶点光照开启            
            //非重要点光源的近似照度 用一个数组 存各灯光的储数据
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld); 
        #endif
        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
        //如果有启用VERTEXLIGHT_ON ShadeSHPerVertex SH光照
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
    //动态lightmap
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
    return ambientOrLightmapUV;
}

// ------------------------------------------------------------------
//  Base forward pass (directional light, emission, lightmaps, ...)

struct VertexOutputForwardBase  //1.01   v2f
{
    UNITY_POSITION(pos); 
    //在D3D上，从片段着色器读取屏幕空间坐标需要SM3.0
    //#define UNITY_POSITION(pos) float4 pos : SV_POSITION
    //声明Clippos
    float4 tex                            : TEXCOORD0;     //UV
    float4 eyeVec                         : TEXCOORD1;    // eyeVec.xyz | fogCoord 相机到片元的vector
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]  //切线矩阵 worldpos
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UV 
    UNITY_LIGHTING_COORDS(6,7)   
    //在AutoLight.cginc  里面有判断灯光模式 和 阴影模式
    //6 _LightCoord 灯光数据  DECLARE_LIGHT_COORDS
    //7 _ShadowCoord 阴影数据 UNITY_SHADOW_COORDS
    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    //下一个不符合SM2.0限制，但始终适用于SM3.0 +
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                     : TEXCOORD8;
    #endif
    UNITY_VERTEX_INPUT_INSTANCE_ID //GPU instance
    UNITY_VERTEX_OUTPUT_STEREO //VR
};



VertexOutputForwardBase vertForwardBase (VertexInput v) //顶点着色器
{
    //输入 VertexInput 
    //输出 VertexOutputForwardBase 
    UNITY_SETUP_INSTANCE_ID(v); 
    VertexOutputForwardBase o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBase, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //VR
    //GPU instance
    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    #if UNITY_REQUIRE_FRAG_WORLDPOS
    //如果片元要记录它在世界空间中的坐标    
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
        //使用法线和高度视差效果时，需要切线矩阵
        //寄存在矩阵W项中
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
            //否则直接寄存在posworld寄存插槽中
        #endif
    #endif
    o.pos = UnityObjectToClipPos(v.vertex);
    //裁剪变换
    o.tex = TexCoords(v);
    o.eyeVec.xyz = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    // _WorldSpaceCameraPos相机坐标
    // 单位化片元到相机连线向量
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    //顶点法线（非法线图）变换到世界空间
    #ifdef _TANGENT_TO_WORLD
    //如果定义 切线到世界
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
        //切线判断
        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);//1.3
        //构建切线空间到世界空间 变换矩阵
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
    //否则
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
        //只存顶点法线在世空间下的信息
    #endif
    //接收阴影 内含不同的判断 
    UNITY_TRANSFER_LIGHTING(o, v.uv1); //阴影
    o.ambientOrLightmapUV = VertexGIForward(v, posWorld, normalWorld); //1.5
    //顶点着色器内的顶点灯光计算
    #ifdef _PARALLAXMAP//曲面细分 视差效果 略过（端游才用得上）
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif
    UNITY_TRANSFER_FOG_COMBINED_WITH_EYE_VEC(o,o.pos);
    //fog 项 雾效
    return o;
}

half4 fragForwardBaseInternal (VertexOutputForwardBase i) //片元着色器
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy); //lod剔除裁剪 淡入淡出 //2.1
    FRAGMENT_SETUP(s) //片元计算前的数据准备
    UNITY_SETUP_INSTANCE_ID(i); //GPU instance
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);//VR
    UnityLight mainLight = MainLight (); //灯光信息结构体声明 灯光初始化 //2.3
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);   //阴影 //2.4
    half occlusion = Occlusion(i.tex.xy);     //AO //2.5
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight); ////光照计算 2.6    
    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    //BRDF 计算 2.7
    c.rgb += Emission(i.tex.xy);   // 自发光 2.8
    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG(_unity_fogCoord, c.rgb); // fog 项
    return OutputForward(c, s.alpha); // alpha 通道处理 2.9
}

// backward compatibility (this used to be the fragment entry function)
////向后兼容（以前是片段输入功能）
half4 fragForwardBase (VertexOutputForwardBase i) : SV_Target   
{
    return fragForwardBaseInternal(i); //函数调用 110a
}

// ------------------------------------------------------------------
//  Additive forward pass (one light per pass)

struct VertexOutputForwardAdd
{
    UNITY_POSITION(pos);
    float4 tex                          : TEXCOORD0;
    float4 eyeVec                       : TEXCOORD1;    // eyeVec.xyz | fogCoord
    float4 tangentToWorldAndLightDir[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
    float3 posWorld                     : TEXCOORD5;
    UNITY_LIGHTING_COORDS(6, 7)
    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if defined(_PARALLAXMAP)
    half3 viewDirForParallax            : TEXCOORD8;
#endif
    UNITY_VERTEX_OUTPUT_STEREO
};

VertexOutputForwardAdd vertForwardAdd (VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardAdd o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardAdd, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = TexCoords(v);
    o.eyeVec.xyz = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    o.posWorld = posWorld.xyz;
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndLightDir[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndLightDir[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndLightDir[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndLightDir[0].xyz = 0;
        o.tangentToWorldAndLightDir[1].xyz = 0;
        o.tangentToWorldAndLightDir[2].xyz = normalWorld;
    #endif
    //We need this for shadow receiving and lighting
    UNITY_TRANSFER_LIGHTING(o, v.uv1);

    float3 lightDir = _WorldSpaceLightPos0.xyz - posWorld.xyz * _WorldSpaceLightPos0.w;
    #ifndef USING_DIRECTIONAL_LIGHT
        lightDir = NormalizePerVertexNormal(lightDir);
    #endif
    o.tangentToWorldAndLightDir[0].w = lightDir.x;
    o.tangentToWorldAndLightDir[1].w = lightDir.y;
    o.tangentToWorldAndLightDir[2].w = lightDir.z;

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
    #endif

    UNITY_TRANSFER_FOG_COMBINED_WITH_EYE_VEC(o, o.pos);
    return o;
}

half4 fragForwardAddInternal (VertexOutputForwardAdd i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    FRAGMENT_SETUP_FWDADD(s)

    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
    UnityLight light = AdditiveLight (IN_LIGHTDIR_FWDADD(i), atten);
    UnityIndirect noIndirect = ZeroIndirect ();

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);

    UNITY_EXTRACT_FOG_FROM_EYE_VEC(i);
    UNITY_APPLY_FOG_COLOR(_unity_fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass
    return OutputForward (c, s.alpha);
}

half4 fragForwardAdd (VertexOutputForwardAdd i) : SV_Target     // backward compatibility (this used to be the fragment entry function)
{
    return fragForwardAddInternal(i);
}

// ------------------------------------------------------------------
//  Deferred pass

struct VertexOutputDeferred
{
    UNITY_POSITION(pos);
    float4 tex                            : TEXCOORD0;
    float3 eyeVec                         : TEXCOORD1;
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
    half4 ambientOrLightmapUV             : TEXCOORD5;    // SH or Lightmap UVs

    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                     : TEXCOORD6;
    #endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


VertexOutputDeferred vertDeferred (VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputDeferred o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputDeferred, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif
    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = TexCoords(v);
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
        float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

        float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
        o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
        o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
        o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    #else
        o.tangentToWorldAndPackedData[0].xyz = 0;
        o.tangentToWorldAndPackedData[1].xyz = 0;
        o.tangentToWorldAndPackedData[2].xyz = normalWorld;
    #endif

    o.ambientOrLightmapUV = 0;
    #ifdef LIGHTMAP_ON
        o.ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #elif UNITY_SHOULD_SAMPLE_SH
        o.ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, o.ambientOrLightmapUV.rgb);
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        o.ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif

    return o;
}

void fragDeferred (
    VertexOutputDeferred i,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3          // RT3: emission (rgb), --unused-- (a)
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
    ,out half4 outShadowMask : SV_Target4       // RT4: shadowmask (rgba)
#endif
)
{
    #if (SHADER_TARGET < 30)
        outGBuffer0 = 1;
        outGBuffer1 = 1;
        outGBuffer2 = 0;
        outEmission = 0;
        #if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
            outShadowMask = 1;
        #endif
        return;
    #endif

    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP(s)
    UNITY_SETUP_INSTANCE_ID(i);

    // no analytic lights in this pass
    UnityLight dummyLight = DummyLight ();
    half atten = 1;

    // only GI
    half occlusion = Occlusion(i.tex.xy);
#if UNITY_ENABLE_REFLECTION_BUFFERS
    bool sampleReflectionsInDeferred = false;
#else
    bool sampleReflectionsInDeferred = true;
#endif

    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, dummyLight, sampleReflectionsInDeferred);

    half3 emissiveColor = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect).rgb;

    #ifdef _EMISSION
        emissiveColor += Emission (i.tex.xy);
    #endif

    #ifndef UNITY_HDR_ON
        emissiveColor.rgb = exp2(-emissiveColor.rgb);
    #endif

    UnityStandardData data;
    data.diffuseColor   = s.diffColor;
    data.occlusion      = occlusion;
    data.specularColor  = s.specColor;
    data.smoothness     = s.smoothness;
    data.normalWorld    = s.normalWorld;

    UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

    // Emissive lighting buffer
    outEmission = half4(emissiveColor, 1);

    // Baked direct lighting occlusion if any
    #if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
        outShadowMask = UnityGetRawBakedOcclusions(i.ambientOrLightmapUV.xy, IN_WORLDPOS(i));
    #endif
}


//
// Old FragmentGI signature. Kept only for backward compatibility and will be removed soon
//

inline UnityGI FragmentGI(
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light,
    bool reflections)
{
    // we init only fields actually used
    FragmentCommonData s = (FragmentCommonData)0;
    s.smoothness = smoothness;
    s.normalWorld = normalWorld;
    s.eyeVec = eyeVec;
    s.posWorld = posWorld;
    return FragmentGI(s, occlusion, i_ambientOrLightmapUV, atten, light, reflections);
}
inline UnityGI FragmentGI (
    float3 posWorld,
    half occlusion, half4 i_ambientOrLightmapUV, half atten, half smoothness, half3 normalWorld, half3 eyeVec,
    UnityLight light)
{
    return FragmentGI (posWorld, occlusion, i_ambientOrLightmapUV, atten, smoothness, normalWorld, eyeVec, light, true);
}

#endif // UNITY_STANDARD_CORE_INCLUDED
