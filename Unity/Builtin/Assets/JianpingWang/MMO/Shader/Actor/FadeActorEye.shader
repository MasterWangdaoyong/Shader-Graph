Shader "Dodjoy/Actor/Fade/ActorEye" 
{
	Properties
	{	
		_MainColor("Eye Color (A-Color blend)", Color) = (0,0,0,1)
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_MaskTex ("Mask(R-Specular, G-EyeColor, B-Reflect, A-Shadow)", 2D) = "white" {}
		_ReflectMatcap("Reflect Matcap", 2D) = "black"{}

		_DiffScale("Diffuse Scale", Range(0, 5)) = 1
		_DiffWrap("Diffuse Wrap", Range(0, 2)) = 1
		_SpecScale("Specular Scale", Range(0, 10)) = 1
		_SpecOffsetX("Specluar offsetX", Range(-2, 2)) = 0
		_SpecOffsetY("Specluar offsetY", Range(-2, 2)) = 0
		_ReflScale ("Reflect Scale", Range(0, 10)) = 1
		_ShadowScale("Shadow Scale", Range(0, 1)) = 1
		_FadeAlpha("Fade Alpha", Range(0, 1)) = 1
	}

	
	SubShader 
	{ 
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		
		Pass{
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
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON
			#define LIGHT_ON
			#define REFLECT_ON
			#define FADE_ON

			#include "DodEyeCore.cginc"		

			ENDCG
		}		
	}
}

