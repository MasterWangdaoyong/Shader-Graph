
// 1/3  A



#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

#define TRANSFER_TANGENTTOWORLD(o, v) \
    o.worldNormal = UnityObjectToWorldNormal(v.normal); \
    o.worldTangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w); \
    o.worldNormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;


inline half3 GetWorldNormal(half3 bump, half3 worldTangent, half3 worldBinormal, half3 worldNormal)
{
    half3 TtoW0 = half3(worldTangent.x, worldBinormal.x, worldNormal.x);
    half3 TtoW1 = half3(worldTangent.y, worldBinormal.y, worldNormal.y);
    half3 TtoW2 = half3(worldTangent.z, worldBinormal.z, worldNormal.z);
    half3 worldBump = normalize(half3(dot(TtoW0, bump), dot(TtoW1, bump), dot(TtoW2, bump)));
    // float3x3 rotation = float3x3(tangent, binormal, wNormal);
    // return normalize(mul(tNormal, rotation));
    return worldBump;
}     //？？？？？？？？？？？？？？？？？？

// inline half3 GetWorldNormal(half3 tNormal, half3 tangent, half3 binormal, half3 wNormal)
// {
//     float3x3 rotation = float3x3(tangent, binormal, wNormal);
//     return normalize(mul(tNormal, rotation));
// }   //存在个人分歧    mul()  应该是左乘 



// #define TANGENT_SPACE_ROTATION \
//     float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w; \
//     float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal )

// o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
// o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;   // 从模型空间转到切线空间

//从模型空间到世界空间
// o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
// o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
// o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
//bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
//float3x3 ObjectToWorldNormal = float3x3(o.TtoW0.xyz, o.Tto1.xyz, o.Tto2.xyz).........

inline half3 ToneEffect(half3 color)
{
    half v = max(max(color.x, color.y), color.z) + 0.01;
    fixed multi = v * v;
    fixed temp = multi + 0.187;
    half v2 = multi / temp * 1.03;
    v = v2 / v;
    return v;
}

inline float GetRoughness(float smoothness)
{
    float roughness = (1 - smoothness) * (1 - smoothness);
    return max(0.002, roughness);
}

inline float GGXV(float NdL, float NdV, float roughness)
{
    float a = roughness;
    float lambertDaV = 1;      //未完成
    return a;  //未完成
}  