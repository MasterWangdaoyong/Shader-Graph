Shader "MMO/Actor/Fade/ActorEye" {
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
		
		#pragma vertex EyeVert
		#pragma fragment EyeFrag
				
		#define DIFFUSE_ON
		#define SPEC_ON
		#define REFLECT_MAP_ON
		#define ENVLIGHT_ON
		#define FADE_ON
		
		#define CUSTOM_MAIN_LIGHT
		#define CUSTOM_ENV_LIGHT_ON
		
		#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
		#pragma multi_compile_fog
		
		#include "ActorEyeCore.cginc"		

		ENDCG
		
	}		
}

}

