Shader "MMO/Actor/TestActorFace" {
Properties {
	[Toggle(DIFFUSE_ON)]_DiffuseOpen("Diffuse open", float) = 1
	[Toggle(SPEC_ON)]_SpecularOpen("Specular open", float) = 1
	//[Toggle(TOON_EFFECT)]_ToonEffectOn("Toon effect open", float) = 1
	[Toggle(ENVLIGHT_ON)]_ENVLIGHT_ON("Env light open", float) = 1
	
	_MainTex ("Base (RGB)", 2D) = "white" {}
	[HideInInspector]_SkinTex("Skin Map", 2D) = "white" {}
	_SpecTex ("Specular Map", 2D) = "black" {}
	
	_DiffScale ("Diffuse scale", float) = 1	
	_DiffWrap("Diffuse Wrap", range(0, 2)) = 0.5

	_SpecRoughness("SpecRoughness", range(0, 1)) = 0.2
	_SpecScale("Spec scale", float) = 1
	
	_EyeTex ("Eye Atlas", 2D) = "black" {}			//�ۿ�����ͼ
	_UvOffsetEyeTex ("Eye Atlas uv offset", vector) = (0,0,0,0)
	_UvScaleEyeTex ("Eye Atlas uv scale", vector) = (1,1,0,0) 
	
	_MouthTex ("Mouth Atlas", 2D) = "black" {}		//�촽
	_UvOffsetMouthTex ("Mouth Atlas uv offset", vector) = (0,0,0,0)
	_UvScaleMouthTex ("Mouth Atlas uv scale", vector) = (1,1,0,0)
	
	_EyeBrowTex ("EyeBrow Atlas", 2D) = "black" {}	//üë
	_UvOffsetEyeBrowTex ("EyeBrow Atlas uv offset", vector) = (0,0,0,0)
	_UvScaleEyeBrowTex ("EyeBrow Atlas uv scale", vector) = (1,1,0,0)
	
	_TattooTex ("Tattoo Atlas", 2D) = "black" {}	//���ϵĻ���
	_UvOffsetTattooTex ("Tattoo Atlas uv offset", vector) = (0,0,0,0)
	_UvScaleTattooTex ("Tattoo Atlas uv scale", vector) = (1,1,0,0)
	
	_MustacheTex("Mustache Atlas", 2D) = "black" {}	//����
    _UvOffsetMustacheTex("Mustache Atlas uv offset", vector) = (0,0,0,0)
    _UvScaleMustacheTex("Mustache Atlas uv scale", vector) = (1,1,0,0)

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

		#pragma shader_feature DIFFUSE_ON
		#pragma shader_feature SPEC_ON
		#pragma shader_feature ENVLIGHT_ON
		#define SKIN_ON
		
		#pragma multi_compile_fwdbase

		#define MAKS_TEST_MODE	//����ģʽ�£���������ͼ����ÿ������һ��ͼƬ
		#define MASK_EYE_TEX
		#define MASK_MOUTH_TEX
		#define MASK_EYEBROW_TEX
		#define MASK_TATTOO_TEX
		#define MASK_MUSTACHE_TEX
	
		
		#include "TestActorBrdfCore.cginc"		

		ENDCG
		
	}

	UsePass "Dodjoy/Actor/ActorShdow/SHADOW"
}

}

