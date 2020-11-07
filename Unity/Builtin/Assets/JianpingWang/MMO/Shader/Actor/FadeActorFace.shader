Shader "MMO/Actor/Fade/ActorFace" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "grey" {}
		_MaskTex("Mask Tex(R-Spec,G-UnUsed,B-UnUsed)", 2D) = "black" {}

		_DiffScale("Diffuse scale", float) = 1
		_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
		_SpecScale("Spec scale", float) = 1
		
		_EyeTex("Eye Atlas", 2D) = "black" {}			//�ۿ�����ͼ
		_UvOffsetEyeTex("Eye Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleEyeTex("Eye Atlas uv scale", vector) = (1,1,0,0)

		_MouthTex("Mouth Atlas", 2D) = "black" {}		//�촽
		_UvOffsetMouthTex("Mouth Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleMouthTex("Mouth Atlas uv scale", vector) = (1,1,0,0)

		_EyeBrowTex("EyeBrow Atlas", 2D) = "black" {}	//üë
		_UvOffsetEyeBrowTex("EyeBrow Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleEyeBrowTex("EyeBrow Atlas uv scale", vector) = (1,1,0,0)

		_TattooTex("Tattoo Atlas", 2D) = "black" {}	//���ϵĻ���
		_UvOffsetTattooTex("Tattoo Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleTattooTex("Tattoo Atlas uv scale", vector) = (1,1,0,0)

		_MustacheTex("Mustache Atlas", 2D) = "black" {}	//����
		_UvOffsetMustacheTex("Mustache Atlas uv offset", vector) = (0,0,0,0)
		_UvScaleMustacheTex("Mustache Atlas uv scale", vector) = (1,1,0,0)
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
		
		#pragma vertex BrdfVert
		#pragma fragment BrdfFrag
				
		#define DIFFUSE_ON
		#define SPEC_ON
		#define TOON_EFFECT
		#define ENVLIGHT_ON
		#define FADE_ON
		#define MRT_DISABLE
		
		#define CUSTOM_MAIN_LIGHT
		#define CUSTOM_ENV_LIGHT_ON

		#define MASK_EYE_TEX
		#define MASK_MOUTH_TEX
		#define MASK_EYEBROW_TEX
		#define MASK_TATTOO_TEX
		#define MASK_MUSTACHE_TEX
		
		#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
		#pragma multi_compile_fog

				
		#include "ActorBrdfCore.cginc"		

		ENDCG
		
	}
	
}

}

