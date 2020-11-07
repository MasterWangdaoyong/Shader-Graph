Shader "MMO/Actor/ActorSkin"
{
    Properties
    {
        _MainTex("Base (RGB-Albedo, A-Roughness)", 2D) = "white" {}
        _BumpTex("Normal", 2D) = "bump"{}
        _BRDFTex("BRDF Tex", 2D) = "gray"{}
        
        _DiffScale("Diffuse Scale", Range(0, 2)) = 1
        _DiffWrap("Diffuse wrap", Range(0, 2)) = 1
        _BumpScale("Normal Sacale", Range(0, 5)) = 1
        _CurvatureScale("Curvature Scale", Range(0.01, 1)) = 0.3
        _SpecScale("Specular Scale", Range(0, 10)) = 1
        _ReflectScale("Reflection Scale", Range(0, 1)) = 0.2
        _Smoothness("Smoothness", Range(0, 10)) = 1

        [Space(10)][Header(Rim Param)]
        _RimGloss("Rim Gloss", Range(0, 32)) = 8
        _RimScale("Rim Scale", Range(0, 10)) = 1
        _RimColor("Rim Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags {"Queue"="Geometry" "RenderType"="Opaque" }
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vertSkin
            #pragma fragment fragSkin
            #pragma multi_compile_fwdbase

            #include "DodSkinCore.cginc"
            ENDCG
        }
    }
}
