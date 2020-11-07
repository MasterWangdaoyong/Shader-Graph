Shader "MMO/Actor/ActorFace(SSS)"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Base (RGB-Albedo, A-Roughness)", 2D) = "white" {}
        [NoScaleOffset]_BumpTex("Normal", 2D) = "bump"{}
        _BumpScale("Normal Sacale", Range(0, 5)) = 1
        [NoScaleOffset]_BRDFTex("BRDF Tex", 2D) = "gray"{}
        _CurvatureScale("Curvature Scale", Range(0.01, 1)) = 0.3

        _DiffScale("Diffuse Scale", Range(0, 2)) = 1
        _DiffWrap("Diffuse wrap", Range(0, 2)) = 1
        _SpecScale("Specular Scale", Range(0, 10)) = 1
        _ReflectScale("Reflection Scale", Range(0, 1)) = 0.2
        //_Smoothness("Smoothness", Range(0, 10)) = 1

        [Space(10)][Header(Rim Param)]
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimGloss("Rim Gloss", Range(0, 8)) = 4
        _RimScale("Rim Scale", Range(0, 2)) = 1
        
        
        [Space(10)][Header(Face Decal)]
        _EyeTex("Eye Atlas", 2D) = "black" {}			//ÑÛ¿ôµÄÌùÍ¼
		_UvOffsetEyeTex("Eye Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleEyeTex("Eye Atlas uv scale", vector) = (1,1,0,0)

		[NoScaleOffset]_MouthTex("Mouth Atlas", 2D) = "black" {}		//×ì´½
		_UvOffsetMouthTex("Mouth Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleMouthTex("Mouth Atlas uv scale", vector) = (1,1,0,0)

		[NoScaleOffset]_EyeBrowTex("EyeBrow Atlas", 2D) = "black" {}	//Ã¼Ã«
		_UvOffsetEyeBrowTex("EyeBrow Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleEyeBrowTex("EyeBrow Atlas uv scale", vector) = (1,1,0,0)

		[NoScaleOffset]_TattooTex("Tattoo Atlas", 2D) = "black" {}	//Á³ÉÏµÄ»¨ÎÆ
		_UvOffsetTattooTex("Tattoo Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleTattooTex("Tattoo Atlas uv scale", vector) = (1,1,0,0)

		[NoScaleOffset]_MustacheTex("Mustache Atlas", 2D) = "black" {}	//ºú×Ó
		_UvOffsetMustacheTex("Mustache Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleMustacheTex("Mustache Atlas uv scale", vector) = (1,1,0,0)
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


            //#define SIMPLE_BLUR
            
            //#define MAKS_TEST_MODE
            #define MASK_EYE_TEX
            #define MASK_MOUTH_TEX
            #define MASK_EYEBROW_TEX
            #define MASK_TATTOO_TEX
            #define MASK_MUSTACHE_TEX

            #include "DodSkinCore.cginc"

            ENDCG
        }

		UsePass "Dodjoy/Actor/ActorShdow/SHADOW"
    }
}
