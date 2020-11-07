Shader "MMO/Actor/ActorFace" 
{
	Properties{
		_MainTex("Base (RGB)", 2D) = "grey" {}
		_MaskTex("Mask Tex(R-Spec,G-UnUsed,B-UnUsed,A-Skin)", 2D) = "black" {}

		_DiffScale("Diffuse scale", float) = 1
		_DiffWrap("Diffuse Wrap", Range(0, 2)) = 0.5
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
		_AttenScale("Atten Scale", range(0, 1)) = 0.5
	}

	SubShader { 
		Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
		LOD 600
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex BrdfVert
			#pragma fragment BrdfFrag
					
			#define DIFFUSE_ON
			#define SPEC_ON
			#define ENVLIGHT_ON
			#define SKIN_ON

			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON

			#define MASK_EYE_TEX
			#define MASK_MOUTH_TEX
			#define MASK_EYEBROW_TEX
			#define MASK_TATTOO_TEX
			#define MASK_MUSTACHE_TEX
			
			#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
			#include "ActorBrdfCore.cginc"		

			ENDCG
		}
		UsePass "Dodjoy/Actor/ActorShdow/SHADOW"
	}

	SubShader { 
		Tags { "Queue"="Geometry" "RenderType"="Opaque" }
		LOD 300
		Pass
		{
			Name "FORWARD" 
			Tags { "LightMode" = "ForwardBase"}
			
			CGPROGRAM
			
			#pragma vertex BrdfVert
			#pragma fragment BrdfFrag
					
			#define DIFFUSE_ON
			#define SPEC_ON
			#define ENVLIGHT_ON
			#define SKIN_ON

			#define CUSTOM_MAIN_LIGHT
			#define CUSTOM_ENV_LIGHT_ON

			#define MASK_EYE_TEX
			#define MASK_MOUTH_TEX
			#define MASK_EYEBROW_TEX
			#define MASK_TATTOO_TEX
			#define MASK_MUSTACHE_TEX
			
			#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
			#include "ActorBrdfCore.cginc"		

			ENDCG
		}
	}

	SubShader
	{
		Tags { "Queue"="Geometry" "RenderType"="Opaque" "IgnoreProjector"="True" "ForceNoShadowCasting"="true"}
		LOD 200
		Pass
		{
			CGPROGRAM
			#pragma vertex UnLitVert
			#pragma fragment UnLitFrag

			#define MASK_EYE_TEX
			#define MASK_MOUTH_TEX
			#define MASK_EYEBROW_TEX
			#define MASK_TATTOO_TEX
			#define MASK_MUSTACHE_TEX

			#include "ActorBrdfCore.cginc"	
			ENDCG
		}
	}
	FallBack "Dodjoy/FallBack"
}

