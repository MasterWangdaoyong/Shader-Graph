Shader "MMO/Actor/ActorHair"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0, 0, 0, 1)
        _MainTex("Mask(G-Specula shift, B-Noise, A-Cutoff)", 2D) = "white" {}
        _BumpTex("Normal", 2D) = "bump"{}

        _BumpScale("Norm Scale", Range(0,1)) = 1
        _Cutoff("Cut off", range(0, 1)) = 0 
        _DiffWrap("Diffuse wrap", Range(0, 2)) = 1
        _SpecIntensity("Specular Intensity", Range(0, 5)) = 1.0 
	    
        [Header(Primary Specular)]
        _SpecColor1("Primary Specular Color", Color) = (1,1,1,1)
        _SpecShift1("Primary Specular Shift", Range(-1, 1)) = 0
        _SpecGloss1("Primary Specular Gloss", Range(8, 256)) = 8
        [Header(Second Specular)]
        _SpecColor2("Second Specular Color", Color) = (1,1,1,1)
        _SpecShift2("Second Specular Shift", Range(-1, 1)) = 0
        _SpecGloss2("Second Specular Gloss", Range(8, 256)) = 8
    }

    SubShader
    {
        Tags {"Queue"="Transparent-1" "RenderType"="Transparent" }
        LOD 600
        pass{
            Cull back
            ZWrite on

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_mask

            #include "DodHairCore.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull off
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #define NORMAL_TEX
			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON

            #include "DodHairCore.cginc"
            ENDCG
        }

        UsePass "Dodjoy/Actor/ActorShdow/SHADOW_CUTOFF"
    }

    SubShader
    {
        Tags {"Queue"="Transparent-1" "RenderType"="Transparent"}
        LOD 300
        pass{
            Cull back
            ZWrite on

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_mask
            #include "DodHairCore.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Cull off
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #define SPECULAR_ONE
			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON

            #include "DodHairCore.cginc"
            ENDCG
        }
        UsePass "Dodjoy/Actor/ActorShdow/SHADOW_CUTOFF"
    }

    SubShader
    {
        Tags{"Queue"="Transparent-1" "RenderType"="Transparent" "IgnoreProjector"="True" "ForceNoShadowCasting"="true"}
        LOD 200
        Pass
        {
            Cull back
            ZWrite on
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag_mask
            #include "DodHairCore.cginc"
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull off
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #define SPECULAR_ONE
			
			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON

            #include "DodHairCore.cginc"
            ENDCG
        }
    }
	FallBack "Dodjoy/FallBack"
}
