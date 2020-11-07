Shader "MMO/Actor/TestActorPBS" {
	Properties 
	{
		[Toggle(DIFFUSE_ON)]_DiffuseOpen("Diffuse open", float) = 1
		[Toggle(SPEC_ON)]_SpecularOpen("Specular open", float) = 1
		[Toggle(REFLECT_MAP_ON)]_ReflectOn("Reflect open", float) = 1
		[Toggle(EMISS_MAP_ON)]_EmissionOn("Emission open", float) = 1
		[Toggle(TOON_EFFECT)]_ToonEffectOn("Toon effect open", float) = 1
		[Toggle(RIM_ON)]_RIM_ON("RimLight open", float) = 1
		[Toggle(ENVLIGHT_ON)]_ENVLIGHT_ON("EnvLight open", float) = 1
	
		_MainTex("Albedo", 2D) = "white" {}
		_DiffScale("Diffuse Scale", range(0, 1)) = 1
		_DiffWrap("DiffWrap", Range(0, 1)) = 0.5
		_BumpTex("Normal", 2D) = "bump" {}
		_MetallicTex("Metallic", 2D) = "white"{}
		_SkinTex("Skin", 2D) = "black" {}

		_RoughTex("Rough", 2D) = "white" {}
		_Smoothness("Smoothness", range(0, 1)) = 0
		_ReflectScale("Reflect Scale", range(0, 1)) = 1
		_SpecScale("Specular Scale", float) = 1

		_EmissTex("Emission", 2D) = "black" {}
		_EmissScale("Emission Scale", range(0, 10)) = 1
		_EmissGloss("Emission Gloss", range(1, 5)) = 2

		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimBias("Rim Range", range(-1, 1)) = 0
		_RimScale("Rim Scale", range(0, 2)) = 1

		_ToonScale("Toon Scale", range(0, 1)) = 1
		_AttenScale("Atten Scale", range(0, 1)) = 0.5
	}
	
	SubShader { 
		Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }
			Cull off
		
			CGPROGRAM
			#include "TestActorPBSCore.cginc"

			#pragma vertex PBSVert
			#pragma fragment PBSFrag
			
			#pragma shader_feature DIFFUSE_ON
			#pragma shader_feature SPEC_ON
			#pragma shader_feature REFLECT_MAP_ON
			#pragma shader_feature EMISS_MAP_ON
			#pragma shader_feature TOON_EFFECT
			#pragma shader_feature ENVLIGHT_ON
			#pragma shader_feature RIM_ON
		
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
		
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

