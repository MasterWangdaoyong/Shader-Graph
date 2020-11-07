Shader "MMO/Actor/Show/ActorEye" {
Properties {	
	_EyeBallColor("Eye Color", Color) = (0,0,0,0)
	_MainTex ("Base (RGB)", 2D) = "grey" {}
	_MaskTex ("MaskTex(R-Spec, G-EyeColor, B-Reflect)", 2D) = "black" {}
	_ReflectMatcap("Reflect Matcap", 2D) = "black"{}
	
	_EnvScale("EnvLight Scale", float) = 1
	_SpecScale("Spec scale", float) = 1
	_ReflectScale ("Reflect scale", float) = 1
}

	
SubShader { 
	Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
	
	
	Pass
	{
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		
		#pragma vertex EyeVert
		#pragma fragment EyeFrag
				
		#define DIFFUSE_ON
		#define SPEC_ON
		#define REFLECT_MAP_ON
		#define ENVLIGHT_ON
		
		#define CUSTOM_ENV_LIGHT_ON

		#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
		
		#define USE_DOD_SHADOW
		#define TEX_HIGH

		
		#include "ActorEyeCore.cginc"		

		ENDCG
		
	}	
	
	
	// ------------------------------------------------------------------
		//  Additive forward pass (one light per pass)
	Pass
	{
		Name "FORWARD_DELTA"
		Tags { "LightMode" = "ForwardAdd" }
		Blend One One
		Fog { Color (0,0,0,0) } // in additive pass fog should be black
		ZWrite Off
		ZTest LEqual

		CGPROGRAM
		
		#pragma vertex EyeVert
		#pragma fragment EyeFrag
		
		#pragma multi_compile_fwdadd
		
		#define DIFFUSE_ON
		#define TEX_HIGH
		
		#include "ActorEyeCore.cginc"
		
		ENDCG
	}
}

}

