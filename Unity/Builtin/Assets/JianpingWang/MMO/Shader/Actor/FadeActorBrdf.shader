Shader "Dodjoy/Actor/Fade/ActorBrdf" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_MaskTex ("Mask Tex(R-Spec,G-Emission,B-Reflect)", 2D) = "black" {}
		
		_DiffScale ("Diffuse scale", float) = 1	
		_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
		_SpecScale("Spec scale", float) = 1
		_ReflectScale ("Reflect scale", float) = 1
		_ReflectContrast ("Reflect Contrast", float) = 1
		_ReflectRoughness("ReflectRoughness", range( 0, 5)) = 3
		_EmissScale("Emission scale", float) = 1.0
		_FadeAlpha("Fade Alpha", Range(0, 1)) = 1
	}

	SubShader 
	{ 
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}	
		Pass
		{
			ZWrite On
			ColorMask 0
			Cull Back
		}
		
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma vertex BrdfVert
			#pragma fragment BrdfFrag
					
			#define DIFFUSE_ON
			#define SPEC_ON
			#define EMISS_MAP_ON
			#define REFLECT_MAP_ON
			#define ENVLIGHT_ON
			
			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON
			#define FADE_ON
			
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
					
			#include "ActorBrdfCore.cginc"		
			ENDCG	
		}	
	}
}

