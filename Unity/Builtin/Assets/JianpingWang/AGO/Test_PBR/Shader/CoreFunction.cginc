// ---------------------20201020
// 函数
// 
#include "StructData.cginc"
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

float4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;

sampler2D _MetallicGlossMap;
float _GlossMapScale;

float _BumpScale;
sampler2D _BumpMap;
float4 _BumpMap_ST;

float _OcclusionStrength;
sampler2D _OcclusionMap;

float4 _EmissionColor;
sampler2D _EmissionMap;

float unity_Lightmap_ST;

float _Cutoff, _Glossiness, _Metallic;

//=========================================================================================
//=========================================================================================
//=========================================================================================
float4 aTexCoords(appdata v) 
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex);
    texcoord.zw = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;    
    return texcoord;
}
half3 aNormalizePerVertexNormal (float3 n) 
{  
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return normalize(n);
    #else
        return n;
    #endif
}
half3x3 aCreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign) 
{
    half sign = tangentSign * unity_WorldTransformParams.w;
    half3 binormal = cross(normal, tangent) * sign;
    return half3x3(tangent, binormal, normal);
}
half3 aSHEvalLinearL2 (half4 normal)
{
    half3 x1, x2;
    half4 vB = normal.xyzz * normal.yzzx;
    x1.r = dot(unity_SHBr,vB);
    x1.g = dot(unity_SHBg,vB);
    x1.b = dot(unity_SHBb,vB);
    half vC = normal.x*normal.x - normal.y*normal.y;
    x2 = unity_SHC.rgb * vC;
    return x1 + x2;
}
half3 aShadeSHPerVertex (half3 normal, half3 ambient)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE      
        ambient += max(half3(0,0,0), ShadeSH9 (half4(normal, 1.0)));
    #else
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = GammaToLinearSpace (ambient);
        #endif
        ambient += aSHEvalLinearL2 (half4(normal, 1.0));
    #endif
    return ambient;
}
half4 aVertexGIForward(float4 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        ambientOrLightmapUV.rgb = aShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
    return ambientOrLightmapUV;
}

//=========================================================================================
// vertex function
v2f vert (appdata v) 
{  
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.tex = aTexCoords(v);
    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);     
    
    o.eyeVec = aNormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos); 
    
    o.tangentToWorldAndPackedData[0].w = posWorld.x;
    o.tangentToWorldAndPackedData[1].w = posWorld.y;
    o.tangentToWorldAndPackedData[2].w = posWorld.z;  

    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
    float3x3 tangentToWorld = aCreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
    o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
    o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
    o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
    UNITY_TRANSFER_LIGHTING(o, v.uv1); //06Q
    o.SH.rgb = aVertexGIForward(posWorld, normalWorld);
    o.posWorld = posWorld;
    return o;
}
 
//=========================================================================================
//=========================================================================================
//=========================================================================================































#define aUNITY_APPLY_DITHER_CROSSFADE(vpos)  aUnityApplyDitherCrossFade(vpos)
sampler2D unity_DitherMask;
void aUnityApplyDitherCrossFade(float2 vpos)
{
    vpos /= 4;
    float mask = tex2D(unity_DitherMask, vpos).a;
    float sgn = unity_LODFade.x > 0 ? 1.0f : -1.0f;
    clip(unity_LODFade.x - mask * sgn);
}

//=========================================================================================
half aAlpha(float2 uv) 
{
    return tex2D(_MainTex, uv).a * _Color.a;
}

half2 aMetallicGloss(float2 uv)
{
    half2 mg;
    // mg = tex2D(_MetallicGlossMap, uv).ra;
    // mg.g *= _GlossMapScale;
    mg.r = _Metallic;
    mg.g = _Glossiness;
    return mg;
}

half3 aAlbedo(float4 texcoords) 
{
    half3 albedo = _Color.rgb * tex2D (_MainTex, texcoords.xy).rgb;
    return albedo;
}

inline half aOneMinusReflectivityFromMetallic(half metallic)
{
    half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}
inline half3 aDiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity) 
{    
    specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);    
    oneMinusReflectivity = aOneMinusReflectivityFromMetallic(metallic);
    return albedo * oneMinusReflectivity;
}
inline aFragmentCommonData aMetallicSetup (float4 i_tex)
{
    half2 metallicGloss = aMetallicGloss(i_tex.xy);  //得到原始metallic 原始roughness
    half metallic = metallicGloss.x; //原始metallic 
    half smoothness = metallicGloss.y; //原始roughness
    half oneMinusReflectivity; //out变量声明
    half3 specColor;   //out变量声明
    half3 diffColor = aDiffuseAndSpecularFromMetallic (aAlbedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);                                               
    aFragmentCommonData o = (aFragmentCommonData)0;
    o.diffColor = diffColor; //漫反射颜色部分 
    o.specColor = specColor; //F0 
    o.oneMinusReflectivity = oneMinusReflectivity;  //1-F0 
    o.smoothness = smoothness; //roughness 
    return o;
}

float3 aNormalizePerPixelNormal (float3 n)
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return n;
    #else
        return normalize((float3)n); // takes float to avoid overflow
    #endif
}
//------------------------------------------------------------------
#ifdef _aNORMALMAP
    half3 aNormalInTangentSpace(float4 texcoords)
    {
        half3 normalTangent = UnpackScaleNormal(tex2D (_BumpMap, texcoords.xy), _BumpScale);        
        return normalTangent;
    }
#endif
float3 aPerPixelWorldNormal(float4 i_tex, float4 tangentToWorld[3])
{
    #ifdef _aNORMALMAP    
        half3 tangent = tangentToWorld[0].xyz; 
        half3 binormal = tangentToWorld[1].xyz; 
        half3 normal = tangentToWorld[2].xyz;
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
        half3 normalTangent = aNormalInTangentSpace(i_tex);
        // 切线空间下的法向量
        float3 normalWorld = aNormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); 
        // @TODO：看看我们是否也可以在SM2.0上进行压缩
        //法线贴图 从切线空间转到世界空间 单位化法向量
    #else
        float3 normalWorld = normalize(tangentToWorld[2].xyz);
        //顶点法线的归一化
    #endif
    return normalWorld;
}
//------------------------------------------------------------------
inline half3 aPreMultiplyAlpha (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{   //2.2.6
    #if defined(_ALPHAPREMULTIPLY_ON)
        //注意：着色器依赖于预乘alpha混合（_SrcBlend = One，_DstBlend = OneMinusSrcAlpha）
        //透明度从“漫反射”组件中“删除”
        diffColor *= alpha;
        #if (SHADER_TARGET < 30)
            // SM2.0：指令计数限制
            //相反，它会牺牲部分基于物理的透明度，其中反射率会影响透明度
            // SM2.0：使用未修改的Alpha
            outModifiedAlpha = alpha;
        #else
            //反射率从其他组件中“消除”，包括透明度
            // outAlpha = 1-(1-alpha)*(1-reflectivity) = 1-(oneMinusReflectivity - alpha*oneMinusReflectivity) =
            //          = 1-oneMinusReflectivity + alpha*oneMinusReflectivity
            outModifiedAlpha = 1 - oneMinusReflectivity + alpha * oneMinusReflectivity;
        #endif
    #else
        outModifiedAlpha = alpha;
    #endif
    return diffColor;
}
//------------------------------------------------------------------
#define IN_WORLDPOS(i) half3(i.tangentToWorldAndPackedData[0].w,i.tangentToWorldAndPackedData[1].w,i.tangentToWorldAndPackedData[2].w)

#define aFRAGMENT_SETUP(x) aFragmentCommonData x = aFragmentSetup(i.tex, i.eyeVec.xyz, i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

aFragmentCommonData aFragmentSetup (inout float4 i_tex, float3 i_eyeVec, float4 tangentToWorld[3], float3 i_posWorld)
{    
    half alpha = aAlpha(i_tex.xy);
        clip (alpha);
    aFragmentCommonData o = aUNITY_SETUP_BRDF_INPUT (i_tex);    
    o.normalWorld = aPerPixelWorldNormal(i_tex, tangentToWorld);  
    o.eyeVec = aNormalizePerPixelNormal(i_eyeVec);  
    o.posWorld = i_posWorld;  
    o.diffColor = aPreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
    return o;
}
//=========================================================================================

aUnityLight aMainLight ()
{
    aUnityLight l;
    l.color = _LightColor0.rgb;
    l.dir = _WorldSpaceLightPos0.xyz; 
    return l;
}

//=========================================================================================
half aLerpOneTo(half b, half t)
{
    half oneMinusT = 1 - t;
    return oneMinusT + b * t;
}

half aOcclusion(float2 uv)
{
    #if (SHADER_TARGET < 30)
        return tex2D(_OcclusionMap, uv).g;
    #else
        half occ = tex2D(_OcclusionMap, uv).g;
        return aLerpOneTo (occ, _OcclusionStrength);
    #endif
}

//=========================================================================================
float aSmoothnessToPerceptualRoughness(float smoothness)
{
    return (1 - smoothness);
}

aUnity_GlossyEnvironmentData aUnityGlossyEnvironmentSetup(half Smoothness, half3 worldViewDir, half3 Normal, half3 fresnel0)
{
    Unity_GlossyEnvironmentData g;
    g.roughness = aSmoothnessToPerceptualRoughness(Smoothness);
    g.reflUVW   = reflect(-worldViewDir, Normal);
    return g;
}
inline void aResetUnityLight(out aUnityLight outLight)
{
    outLight.color = half3(0, 0, 0);
    outLight.dir = half3(0, 1, 0);
}

inline void aResetUnityGI(out aUnityGI outGI)
{
    aResetUnityLight(outGI.light);
    outGI.indirect.diffuse = 0;
    outGI.indirect.specular = 0;
}

inline aUnityGI aUnityGI_Base(aUnityGIInput data, half occlusion, half3 normalWorld)
{
    aUnityGI o_gi;
    aResetUnityGI(o_gi);
    
    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
        half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos); //shadowmask 阴影
        float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz); //当前片元的Z 深度 
        float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist); //计算阴影淡化
        data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist)); //混合动态阴影和静态阴影 
    #endif

    o_gi.light = data.light;
    o_gi.light.color *= data.atten; //对亮度进行衰减

    #if UNITY_SHOULD_SAMPLE_SH //diffuse 第一步计算 球谐光照
        o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
    #endif
    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
        half3 bakedColor = DecodeLightmap(bakedColorTex); //解压lightmap
        #ifdef DIRLIGHTMAP_COMBINED //定向光照贴图技术 directional lightmap 略
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);
            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light);
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif
        #else // not directional lightmap 如果没有定向光照贴图
            o_gi.indirect.diffuse += bakedColor; //diffuse 第二步计算 加上 lightmap
            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
            // 当混合lightmap开启 并且 没有开启shadow mask 并且 开启阴影 
            // 经常会碰到烘了lightmap（已经有阴影） 但角色的实时阴影加进不了 lightmap阴影里，此方法应该是较好的解决
                ResetUnityLight(o_gi.light); //重置参数，清零
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
                //lambert  lightmap 和阴影  阴影颜色做混合
            #endif
        #endif
    #endif
    #ifdef DYNAMICLIGHTMAP_ON //动态lightmap 略
        // Dynamic lightmaps
        fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
        half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);
        #ifdef DIRLIGHTMAP_COMBINED
            half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
        #else
            o_gi.indirect.diffuse += realtimeColor;
        #endif
    #endif
    o_gi.indirect.diffuse *= occlusion; //diffuse 第三步计算 乘上 AO
    return o_gi;
}

half3 aUnity_GlossyEnvironment (UNITY_ARGS_TEXCUBE(tex), half4 hdr, Unity_GlossyEnvironmentData glossIn)
{
    half perceptualRoughness = glossIn.roughness ;
    #if 0
        float m = PerceptualRoughnessToRoughness(perceptualRoughness); // m是实际粗糙度参数
        const float fEps = 1.192092896e-07F;
        float n =  (2.0/max(fEps, m*m))-2.0;
        n /= 4;   
        perceptualRoughness = pow( 2/(n+2), 0.25);
    #else
        perceptualRoughness = perceptualRoughness * (1.7 - 0.7*perceptualRoughness);
    #endif
    half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
    half3 R = glossIn.reflUVW;
    half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(tex, R, mip);
    return DecodeHDR(rgbm, hdr);
}

inline half3 aUnityGI_IndirectSpecular(aUnityGIInput data, half occlusion, aUnity_GlossyEnvironmentData glossIn)
{
    half3 specular;
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION        
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[0], data.boxMin[0], data.boxMax[0]);
    #endif
    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else
        half3 env0 = aUnity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
        #ifdef UNITY_SPECCUBE_BLENDING
            const float kBlendFactor = 0.99999;
            float blendLerp = data.boxMin[0].w;
            UNITY_BRANCH
            if (blendLerp < kBlendFactor)
            {
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
                #endif

                half3 env1 = aUnity_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], glossIn);
                specular = lerp(env1, env0, blendLerp);
            }
            else
            {
                specular = env0;
            }
        #else
            specular = env0;
        #endif
    #endif

    return specular * occlusion; //最后乘上AO
}

inline aUnityGI aUnityGlobalIllumination (aUnityGIInput data, half occlusion, half3 normalWorld, aUnity_GlossyEnvironmentData glossIn)
{
    aUnityGI o_gi = aUnityGI_Base(data, occlusion, normalWorld);//函数调用    //lightmap 计算
    o_gi.indirect.specular = aUnityGI_IndirectSpecular(data, occlusion, glossIn);     //间接反射 
    return o_gi;
}

inline aUnityGI aFragmentGI (aFragmentCommonData s, half occlusion, half4 i_ambientOrLightmapUV, half atten, aUnityLight light) //998a
{
    aUnityGIInput d; 
    d.light = light;
    d.worldPos = s.posWorld;
    d.worldViewDir = -s.eyeVec;
    d.atten = atten; 
    d.ambient = i_ambientOrLightmapUV.rgb; 
    d.lightmapUV = 0;
    d.probeHDR[0] = unity_SpecCube0_HDR;
    d.probeHDR[1] = unity_SpecCube1_HDR;
    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
      d.boxMin[0] = unity_SpecCube0_BoxMin;
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
      d.boxMax[0] = unity_SpecCube0_BoxMax;
      d.probePosition[0] = unity_SpecCube0_ProbePosition;
      d.boxMax[1] = unity_SpecCube1_BoxMax;
      d.boxMin[1] = unity_SpecCube1_BoxMin;
      d.probePosition[1] = unity_SpecCube1_ProbePosition;
    #endif
    aUnity_GlossyEnvironmentData g = aUnityGlossyEnvironmentSetup(s.smoothness, -s.eyeVec, s.normalWorld, s.specColor); 
    return aUnityGlobalIllumination (d, occlusion, s.normalWorld, g);
}
//=========================================================================================
#define aUNITY_BRDF_PBS aBRDF3_Unity_PBS

half3 aBRDF3_Direct(half3 diffColor, half3 specColor, half rlPow4, half smoothness)
{ //基于blinn-phong 光照模型的优化实现 
    half LUT_RANGE = 16.0;
    //必须与GeneratedTextures.cpp中的NHxRoughness（）函数中的范围匹配
     //查找纹理以保存指令
    half specular = tex2D(unity_NHxRoughness, half2(rlPow4, aSmoothnessToPerceptualRoughness(smoothness))).r * LUT_RANGE;
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specular = 0.0;
    #endif
    return diffColor + specular * specColor;
}
half3 aBRDF3_Indirect(half3 diffColor, half3 specColor, aUnityIndirect indirect, half grazingTerm, half fresnelTerm)
{
    half3 c = indirect.diffuse * diffColor;
    c += indirect.specular * lerp (specColor, grazingTerm, fresnelTerm);
    return c;
}
half4 aBRDF3_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    aUnityLight light, aUnityIndirect gi)
{   //2.7
    float3 reflDir = reflect (viewDir, normal);
    half nl = saturate(dot(normal, light.dir));
    half nv = saturate(dot(normal, viewDir));
    // Vectorize Pow4 to save instructions 向量化Pow4以保存说明
    half2 rlPow4AndFresnelTerm = Pow4 (float2(dot(reflDir, light.dir), 1-nv));
    //使用R.L代替N.H保存指令
    half rlPow4 = rlPow4AndFresnelTerm.x; 
    // 幂指数必须与GeneratedTextures.cpp的NHxRoughness（）函数中的kHorizontalWarpExp相匹配
    half fresnelTerm = rlPow4AndFresnelTerm.y;   // 简化版 (1-h . wi)4(次方)
    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));  //掠射角项
    half3 color = aBRDF3_Direct(diffColor, specColor, rlPow4, smoothness); //直接光部分
                //2.7.1
    color *= light.color * nl;
    color += aBRDF3_Indirect(diffColor, specColor, gi, grazingTerm, fresnelTerm);  //间接光部分
                //2.7.2
    return half4(color, 1);
}
//=========================================================================================
half3 aEmission(float2 uv)
{
    #ifndef _EMISSION
        return 0;
    #else
        return tex2D(_EmissionMap, uv).rgb * _EmissionColor.rgb;
    #endif
}
//=========================================================================================
#define aUNITY_OPAQUE_ALPHA(outputAlpha) outputAlpha = 1.0
half4 aOutputForward (half4 output, half alphaFromSurface)
{
    #if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
        output.a = alphaFromSurface;
    #else
        aUNITY_OPAQUE_ALPHA(output.a);
    #endif
    return output;
}
//=========================================================================================
half4 frag (v2f i) : SV_Target
{ 
    // aUNITY_APPLY_DITHER_CROSSFADE(i.pos.xy); 
    aFRAGMENT_SETUP(s)
    aUnityLight mainLight = aMainLight();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);
    half occlusion = aOcclusion(i.tex.xy);
    aUnityGI gi = aFragmentGI (s, occlusion, i.SH, atten, mainLight);  
    half4 c = aUNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    // c.rgb += aEmission(i.tex.xy);  
    // return aOutputForward(c, s.alpha); 
    return c; 
}
