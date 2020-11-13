Shader "Dodjoy/Actor/High/ActorBrdf" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_MaskTex ("Mask Tex(R-Spec,G-Emission,B-Reflect,A-Skin)", 2D) = "black" {}
		
		_DiffScale ("Diffuse scale", float) = 1	
		_DiffWrap("Diffuse Wrap", Range(0, 2)) = 0.5
		_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
		_SpecScale("Spec scale", float) = 1
		_ReflectScale ("Reflect scale", float) = 1
		_ReflectContrast ("Reflect Contrast", float) = 1
		_ReflectRoughness("ReflectRoughness", range( 0, 5)) = 3
		_EmissScale("Emission scale", float) = 1.0
		_AttenScale("Atten Scale", range(0, 1)) = 0.5
	}

	SubShader 
	{ 
		Tags { "Queue"="Geometry"  "RenderType"="Opaque"}
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex BrdfVert
			#pragma fragment BrdfFrag
			#pragma multi_compile HIGHLIGHT_ON HIGHLIGHT_OFF
			#pragma multi_compile_fwdbase
					
			#define DIFFUSE_ON
			#define SPEC_ON
			#define EMISS_MAP_ON
			#define REFLECT_MAP_ON
			#define ENVLIGHT_ON
			#define SKIN_ON
			
			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON
			
			
			#include "ActorBrdfCore.cginc"	
				
			ENDCG
			
		}	
		UsePass "Dodjoy/Actor/ActorShdow/SHADOW"
	}
}

