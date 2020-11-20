// 时间：20201020
// JianpingWang
// 功能：数组数据

#include "AutoLight.cginc"
//=========================================================================================
struct appdata 
{
    float4 vertex : POSITION;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    float2 uv2 : TEXCOORD2;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float4 tex : TEXCOORD0;
    float3 eyeVec : TEXCOORD1;
    float4 tangentToWorldAndPackedData[3] : TEXCOORD2;
    half4  SH      : TEXCOORD5;
    UNITY_LIGHTING_COORDS(6,7)
    float3 posWorld                     : TEXCOORD8;
};

struct aFragmentCommonData 
{
    half3 diffColor, specColor;
    half oneMinusReflectivity, smoothness;
    float3 normalWorld;
    float3 eyeVec;
    half alpha;
    float3 posWorld;
    // #if UNITY_STANDARD_SIMPLE
    //     half3 reflUVW;
    // #endif
    // #if UNITY_STANDARD_SIMPLE
    //     half3 tangentSpaceNormal;
    // #endif
};
//=========================================================================================
struct aUnityLight
{
    half3 color;
    half3 dir;
};
// ----------------------------------------------------------------------------------------
struct aUnityIndirect
{
    half3 diffuse;
    half3 specular;
};

struct aUnityGI 
{
    aUnityLight light;
    aUnityIndirect indirect;    
};

// ----------------------------------------------------------------------------------------
struct aUnityGIInput
{
    aUnityLight light;

    float3 worldPos;
    half3 worldViewDir;
    half atten;
    half3 ambient;
    float4 lightmapUV;

    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
        float4 boxMin[2];
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        float4 boxMax[2];
        float4 probePosition[2];
    #endif
    float4 probeHDR[2];
};
// ----------------------------------------------------------------------------------------
struct aUnity_GlossyEnvironmentData
{
    half    roughness; 
    half3   reflUVW;
};