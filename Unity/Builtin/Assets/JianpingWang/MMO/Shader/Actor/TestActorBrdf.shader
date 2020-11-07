Shader "MMO/Actor/TestActorBrdf" {
Properties {
	[Toggle(DIFFUSE_ON)]_DiffuseOpen("Diffuse open", float) = 1
	[Toggle(SPEC_ON)]_SpecularOpen("Specular open", float) = 1
	[Toggle]_ReflectOn("Reflect open", float) = 1
	[Toggle]_EmissionOn("Emission open", float) = 1
	//[Toggle(TOON_EFFECT)]_ToonEffectOn("Toon effect open", float) = 1
	//[Toggle(RIM_ON)]_RIM_ON("RimLight open", float) = 1
	[Toggle(ENVLIGHT_ON)]_ENVLIGHT_ON("Env light open", float) = 1
	
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_SkinTex("Skin Map", 2D) = "black" {}
	_SpecTex ("Specular Map", 2D) = "black" {}
	_ReflectTex ("Reflect Map", 2D) = "black" {}
	_EmissTex ("Emission Map", 2D) = "black" {}
	
	_DiffScale ("Diffuse scale", float) = 1	
	_DiffWrap("Diffuse Wrap", range(0, 2)) = 0.5

	_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
	_SpecScale("Spec scale", float) = 1
	_ReflectScale ("Reflect scale", float) = 1
	_ReflectContrast ("Reflect Contrast", float) = 1
	_ReflectRoughness("ReflectRoughness", range( 0, 5)) = 3
	_EmissScale("Emission scale", float) = 1.0
	_AttenScale("Atten Scale", range(0, 1)) = 0.5
}
	
	
SubShader { 
	Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
		
	Pass
	{
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		
		#pragma vertex BrdfVert
		#pragma fragment BrdfFrag
		
		//#pragma target 3.0

		// -------------------------------------
		
		#pragma shader_feature DIFFUSE_ON
		#pragma shader_feature SPEC_ON
		//#pragma shader_feature TOON_EFFECT
		#pragma shader_feature ENVLIGHT_ON
				
		#define REFLECT_MAP_ON
		#define EMISS_MAP_ON
		#define MRT_ENABLE
		#define SKIN_ON

		//#define TEX_HIGH
		
		#pragma multi_compile_fwdbase
		#pragma multi_compile_fog
				
		#include "TestActorBrdfCore.cginc"		

		ENDCG	
	}	
	
		
	
	// ------------------------------------------------------------------
		//  Additive forward pass (one light per pass)
		/*
	Pass
	{
		Name "FORWARD_DELTA"
		Tags { "LightMode" = "ForwardAdd" }
		Blend One One
		Fog { Color (0,0,0,0) } // in additive pass fog should be black
		ZWrite Off
		ZTest LEqual

		CGPROGRAM
		
		#pragma vertex BrdfVert
		#pragma fragment BrdfFrag
		
		#pragma multi_compile_fwdadd
		
		#define DIFFUSE_ON
		#define TEX_HIGH
		
		#include "TestActorBrdfCore.cginc"		
		
		ENDCG
	}
	*/
	
	// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM

			#pragma multi_compile_shadowcaster			

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			#define CUT_OFF
			
			#include "ActorShadowCaster.cginc"

			ENDCG
		}
		
	
}

}

