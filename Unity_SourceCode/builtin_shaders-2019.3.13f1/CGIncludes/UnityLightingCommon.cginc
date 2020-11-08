// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_LIGHTING_COMMON_INCLUDED
#define UNITY_LIGHTING_COMMON_INCLUDED

fixed4 _LightColor0;
fixed4 _SpecColor;

struct UnityLight
{   //2.6.01
    half3 color;
    half3 dir;
    half  ndotl; // Deprecated: Ndotl is now calculated on the fly and is no longer stored. Do not used it.
    //不推荐使用：Ndotl现在可以即时计算，不再存储。 不要使用它。
};

struct UnityIndirect
{
    half3 diffuse;
    half3 specular;
};

struct UnityGI //结构体中包含结构体
{   //2.6.03
    UnityLight light;
    //UnityLight 结构体 包含half3 color; half3 dir; half  ndotl;
    UnityIndirect indirect;
    //UnityIndirect 结构体 包含half3 diffuse; half3 specular;
};

struct UnityGIInput
{
    UnityLight light; // pixel light, sent from the engine
    //引擎发出的像素光
    //结构体声明
    //UnityLight 结构体 包含color dir ndotl

    float3 worldPos;
    half3 worldViewDir;
    half atten;//阴影衰减
    half3 ambient;

    // interpolated lightmap UVs are passed as full float precision data to fragment shaders
    // so lightmapUV (which is used as a tmp inside of lightmap fragment shaders) should
    // also be full float precision to avoid data loss before sampling a texture.
    //插值的光照贴图UV作为完整的浮动精度数据传递到片段着色器
    //因此，lightmapUV（在lightmap片段着色器内部用作tmp）应该
    //也应具有全浮点精度，以避免在采样纹理之前丢失数据。
    // .xy =静态光照贴图UV，.zw =动态光照贴图UV
    float4 lightmapUV; // .xy = static lightmap UV, .zw = dynamic lightmap UV

    #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION) || defined(UNITY_ENABLE_REFLECTION_BUFFERS)
        float4 boxMin[2]; //反射球混合？？？
    #endif
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION
        float4 boxMax[2];
        float4 probePosition[2];
    #endif

    // HDR cubemap properties, use to decompress HDR texture
    // HDR cubemap属性，用于解压缩HDR纹理
    float4 probeHDR[2];
};

#endif
