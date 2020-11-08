// Upgrade NOTE: replaced 'defined GAMMA' with 'defined (GAMMA)'

#ifndef TEST_PBR_DATA_FUNCTION
#define TEST_PBR_DATA_FUNCTION

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

//20200716 晴

//input 
half4           _Color;
sampler2D       _MainTex;
float4          _MainTex_ST;
sampler2D       _MetallicGlossMap;
sampler2D       _BumpMap;
half            _MetallicStrength;
half            _GlossStrength;
float           _BumpScale;
half4           _EmissionColor;
sampler2D       _EmissionMap;

//PI
//UNITY_INV_PI
#if defined (GAMMA)
    #define ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
#else
    #define ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)
#endif

// //texSetup
// #define FRAG_DATA(s) Frag2Data s = ToFragSetup(i.uv, _Color, _MainTex, _MainTex_ST, _MetallicGlossMap, _MetallicStrength, _GlossStrength, _OcclusionMap, _EmissionMap, _EmissionColor, _BumpScale, i.TtoW0, i.TtoW1, i.TtoW2);

// struct Frag2Data
// {
//     half3 Albedo;
//     half3 Normal;
//     half3 emission;
//     half2 metallicGloss;
//     half metallic;
//     half roughness;
//     half occlusion;
// };

// FragData Frag2Data(half2 uv, half4 _Color, half4 _MainTex, half4 _MainTex_ST, half4 _MetallicGlossMap, half _MetallicStrength, half _GlossStrength, half4 _OcclusionMap, half4 _EmissionMap, half4 _EmissionColor, half _BumpScale, half4 TtoW0, half4 TtoW1, half4 TtoW2)
// {
//     Frag2Data data = (Frag2Data) 0;

//     // data.Albedo = tex2D(_MainTex, uv).rgb * _Color.rgb;    
//     // data.metallicGloss  = tex2D(_MetallicGlossMap, uv).ra;
//     // data.metallic = metallicGloss.x * _MetallicStrength;//金属度
//     // data.roughness = 1 - metallicGloss.y * _GlossStrength;//粗糙度
//     // data.occlusion = tex2D(_OcclusionMap, uv).g;//环境光遮挡
//     // data.emission = tex2D(_EmissionMap, uv).rgb * _EmissionColor;//自发光颜色

//     // half3 normalTangent = UnpackNormal(tex2D(_BumpMap, uv));
//     // normalTangent.xy *= _BumpScale;
//     // normalTangent.z = sqrt(1.0 - saturate(dot(normalTangent.xy, normalTangent.xy)));
//     // data.Normal = normalize(half3(dot(TtoW0.xyz,normalTangent),	dot(TtoW1.xyz,normalTangent), dot(TtoW2.xyz,normalTangent)));

//     return data;
// }


//struct vertexInput
struct appdataA
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

};

//struct fragInput
struct v2fA
{
    float2 tex                            : TEXCOORD0;
    float4 tangentToWorldAndPackedData[3] : TEXCOORD1;
    half4 ambientOrLightmapUV           : TEXCOORD2;
    float4 pos : SV_POSITION;
    
    SHADOW_COORDS(3)

    UNITY_FOG_COORDS_PACKED(4, half4)

    half4 normalWorld                   : TEXCOORD5;

    #ifdef _NORMALMAP
        half3 tangentSpaceLightDir          : TEXCOORD6;
        #if SPECULAR_HIGHLIGHTS
            half3 tangentSpaceEyeVec        : TEXCOORD7;
        #endif
    #endif

    #if UNITY_REQUIRE_FRAG_WORLDPOS
        float3 posWorld                     : TEXCOORD8;
    #endif
    half4 eyeVec                        : TEXCOORD9;
    
};

//struct GI 所有灯光计算
struct GIA
{
    half3 color;
    half3 dir;
    half  ndotl;
    half3 diffuse;
    half3 specular;
};   

GIA LightMap_gi(half3 vertexNormalWorld, half3 worldPos )
{
    GIA gi = (GIA) 0;

    gi.color = _LightColor0.rgb;
    gi.dir = _WorldSpaceLightPos0.xyz;
    gi.ndotl = max(0, dot(_WorldSpaceLightPos0.xyz, vertexNormalWorld));
    gi.diffuse = gi.ndotl * gi.color;
    gi.specular = 0;

    return gi;
}

inline half POW5(half x)
{
    return x * x * x * x * x;
}

inline float3 Unity_SAfeNormalize(float3 inVec)
{
    float dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

float OneSmoothnessTORoughness(float OneSmoothness)
{
    return OneSmoothness * OneSmoothness;
}

inline half3 FResnelLerp (half3 F0, half3 F90, half cosA)
{
    half t = POW5 (1 - cosA);   // ala Schlick interpoliation
    return lerp (F0, F90, t);
}

inline half3 NormalizePerVertexNormalA (float3 n) // takes float to avoid overflow
{
    #if (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        return normalize(n);
    #else
        return n; // will normalize per-pixel instead
    #endif
}

inline half4 VertexGIForwardA(appdataA v, float3 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
    // Static lightmaps
    #ifdef LIGHTMAP_ON
        ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        ambientOrLightmapUV.zw = 0;
    // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
    #elif UNITY_SHOULD_SAMPLE_SH
        #ifdef VERTEXLIGHT_ON
            // Approximated illumination from non-important point lights
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        #endif

        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return ambientOrLightmapUV;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------------------------
//Diffuse 漫反射项
inline half DIsneyDiffuse(half NdotV, half NdotL, half LdotH, half Roughness)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * Roughness;

    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

    return lightScatter * viewScatter;
}

// // [Burley 2012, "Physically-Based Shading at Disney"]   
// float3 Diffuse_Burley_Disney( float3 DiffuseColor, float Roughness, float NoV, float NoL, float VoH )
// {
// 	float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
// 	float FdV = 1 + (FD90 - 1) * Pow5( 1 - NoV );
// 	float FdL = 1 + (FD90 - 1) * Pow5( 1 - NoL );
// 	return DiffuseColor * ( (1 / PI) * FdV * FdL );
// }
//----------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------------------------
//Specular D : GTR  法线分布  Generalized-Trowbridge-Reitz
inline float GGXTErm (float NdotH, float Roughness)
{
    float a2 = Roughness * Roughness;
    float a4 = a2 * a2;
    float d = (NdotH * a4 - NdotH) * NdotH + 1.0f; 
    return UNITY_INV_PI * a4 / (d * d + 1e-7f);                                             
}

// // Generalized-Trowbridge-Reitz distribution
// inline float D_GTR1(float Roughness, float dotNH)
// {
//     float a2 = Roughness * Roughness;
//     float cos2th = dotNH * dotNH;
//     float den = (1.0 + (a2 - 1.0) * cos2th);

//     return (a2 - 1.0) / (PI * log(a2) * den);
// }

// inline float D_GTR2(float Roughness, float dotNH)
// {
//     float a2 = Roughness * Roughness;
//     float cos2th = dotNH * dotNH;
//     float den = (1.0 + (a2 - 1.0) * cos2th);

//     return a2 / (PI * den * den);
// }

// inline float D_GTR2_aniso(float dotHX, float dotHY, float dotNH, float ax, float ay)
// {
//     float deno = dotHX * dotHX / (ax * ax) + dotHY * dotHY / (ay * ay) + dotNH * dotNH;
//     return 1.0 / (PI * ax * ay * deno * deno);
// }
//----------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------------------------
//Specular F 菲涅尔项（Specular F）：Schlick Fresnel
//F0 =    
inline half3 FResnelTerm (half3 F0, half LdotH)
{
    half t = Pow5 (1 - LdotH);   // ala Schlick interpoliation
    return F0 + (1-F0) * t;
}
//----------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------------------------
//Specular G  几何项 Smith-GGX
inline float SMithJointGGXVisibilityTerm(float NdotL, float NdotV, float roughness)
{
	half a          = roughness;
    half a2         = a * a;

    half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
    half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);
	
	return 0.5f / (lambdaV + lambdaL + 1e-5f);
}

// float a = roughness;
// float lambdaV = NdotL * (NdotV * (1 - a) + a);
// float lambdaL = NdotV * (NdotL * (1 - a) + a);
//----------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------------------------------------
//diffColor     //specColor     //oneMinusReflectivity      //smoothness        //normal   viewDir   GI light   GI gi
inline half3 MainPBS(half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness, float3 normal, float3 viewDir, GIA light, GIA gi)
{
    float OneSmoothness = 1 - smoothness;
    float3 halfDir = Unity_SAfeNormalize (float3(light.dir) + viewDir);
    half nv = abs(dot(normal, viewDir));
    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    //diffuse 
    half diffuseTerm = DIsneyDiffuse(nv, nl, lh, OneSmoothness) * nl;

    //specular
    float roughness = OneSmoothness * OneSmoothness;
    roughness = max(roughness, 0.002);
    float V = SMithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTErm (nh, roughness);
    float specularTerm = V * D * UNITY_PI;    
    specularTerm = max(0, specularTerm * nl);
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    //surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction = 1.0 / (roughness * roughness + 1.0);    

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));

    // // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    // o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
    half3 Color =   diffColor * (gi.diffuse + light.color * diffuseTerm) + specularTerm * light.color * FResnelTerm (specColor, lh) + surfaceReduction * gi.specular * FResnelLerp (specColor, grazingTerm, nv);


    return half4(Color, 1);
}
//----------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////////////////////////////////


#endif