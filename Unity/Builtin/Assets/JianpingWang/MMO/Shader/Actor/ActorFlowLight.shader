Shader "Dodjoy/Actor/ActorFlowLight" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "grey" {}
	_MaskTex ("Mask Tex(R-Spec,G-Emission,B-Reflect)", 2D) = "black" {}
	
	_DiffScale ("Diffuse scale", float) = 1	
	_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
	_SpecScale("Spec scale", float) = 1
	_ReflectScale ("Reflect scale", float) = 1
	_ReflectContrast ("Reflect Contrast", float) = 1
	_ReflectRoughness("ReflectRoughness", range( 0, 5)) = 3
	_EmissScale("Emission scale", float) = 1.0
	
	_FlowLightTex ("Flow Light(RGB)", 2D) = "black" {}
	_FlowLightScale("Flow Light scale", float) = 1.0
	_FlowLightColor("Flow Light Color", Color) = (1,1,1,0)
	_FlowLightSpeed("Flow Ligth speed(x-u,y-v)", vector) = (0.1,0.1, 0,0)
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
				
		#define DIFFUSE_ON
		#define SPEC_ON
		#define EMISS_MAP_ON
		#define REFLECT_MAP_ON
		#define TOON_EFFECT
		#define ENVLIGHT_ON
		#define EFFECT_FLOW_LIGHT
		
		#define CUSTOM_MAIN_LIGHT
		#define CUSTOM_ENV_LIGHT_ON
		
		#pragma multi_compile  MRT_DISABLE MRT_ENABLE
		#pragma multi_compile HIGHLIGHT_ON HIGHLIGHT_OFF
		
		#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
		#pragma multi_compile_fog
				
		#include "ActorBrdfCore.cginc"		

		ENDCG
		
	}	
	
	// ------------------------------------------------------------------
	//  Shadow rendering pass
	Pass {
		Name "ShadowCaster"
		Tags { "LightMode" = "ShadowCaster" }

		ZWrite On ZTest LEqual
		
		CGPROGRAM
		
		// -------------------------------------
		#pragma multi_compile_shadowcaster

		#pragma vertex vertShadowCaster
		#pragma fragment fragShadowCaster
		
		#include "ActorShadowCaster.cginc"
		
		ENDCG
	}
	
}

}

