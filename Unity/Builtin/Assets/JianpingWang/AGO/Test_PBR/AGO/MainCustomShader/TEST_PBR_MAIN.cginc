// Upgrade NOTE: replaced 'defined GAMMA' with 'defined (GAMMA)'

#ifndef TEST_PBR_MAIN
#define TEST_PBR_MAIN

#include "TEST_PBR_DATA_FUNCTION.cginc"

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

//20200716 晴


v2fA vert (appdataA v)
{
    v2fA o; 

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);

    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #endif
    #endif

    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = TRANSFORM_TEX(v.uv0, _MainTex);

    o.eyeVec.xyz = NormalizePerVertexNormalA(posWorld.xyz - _WorldSpaceCameraPos);

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

    //We need this for shadow receving
    UNITY_TRANSFER_LIGHTING(o, v.uv1);

    o.ambientOrLightmapUV = VertexGIForwardA(v, posWorld, normalWorld);

    return o;
}
  


fixed4 frag (v2fA i) : SV_Target
{
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);
    half nv = abs(dot(normal, viewDir));
    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    FRAGMENT_SETUP(s)

    UnityLight mainLight = MainLight ();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

    half occlusion = Occlusion(i.tex.xy);
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

    half4 c = MainPBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    c.rgb += Emission(i.tex.xy);


    return c;
}


#endif