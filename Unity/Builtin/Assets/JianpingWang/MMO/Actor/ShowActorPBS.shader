Shader "Dodjoy/Actor/Show/ActorPBS" {
	Properties 
	{
		_MainTex("Albedo", 2D) = "white" {}
		_DiffScale("Diffuse Scale", range(0, 1)) = 1
		_DiffWrap("DiffWrap", Range(0, 1)) = 0.5
		_BumpTex("Normal", 2D) = "bump" {}
		_MaskTex("Mask Tex(R-Metallic, G-Emission, B-Skin, A-Rough)", 2D) = "black"{}

		_Smoothness("Smoothness", range(0, 1)) = 0
		_ReflectScale("Reflect Scale", range(0, 1)) = 1
		_SpecScale("Specular Scale", float) = 1

		_EmissScale("Emission Scale", range(0, 10)) = 3
		_EmissGloss("Emission Gloss", range(1, 5)) = 2

		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimBias("Rim Range", range(-1, 1)) = 0
		_RimScale("Rim Scale", range(0, 2)) = 1

		_ToonScale("Toon Scale", range(0, 1)) = 1
		_AttenScale("Atten Scale", range(0, 1)) = 0.5
	}
	
	SubShader { 
		Tags { "Queue"="Geometry" "RenderType"="Opaque"}
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }
			Cull off
		
			CGPROGRAM
			
			#pragma vertex PBSVert
			#pragma fragment PBSFrag
			
			#define DIFFUSE_ON
			#define SPEC_ON
			#define EMISS_MAP_ON
			#define REFLECT_MAP_ON
			#define TOON_EFFECT
			#define ENVLIGHT_ON
			#define RIM_ON

			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON
	
			#pragma multi_compile_fwdbase noshadowmask

			#include "ActorPBSCore.cginc"

			ENDCG
		}//END PASS

		Pass 
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			#include "ActorShadowCaster.cginc"

			#pragma multi_compile_shadowcaster			
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			
			ENDCG
		}// End PASS
	}
}

