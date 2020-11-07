
Shader "Dodjoy/Scene/SceneItemSSS"      //JianpingWang //自定义SSS效果  //只供场景特殊物件使用  //20200416 //0428  //0513 //20200608
{
	Properties 
	{
		[Header(Base)]
		[NoScaleOffset]
		_MainTex ("Base (RGB)", 2D) = "gray" {}		
		_BumpScale("BumpScale", Range(0, 1)) = 1
		[NoScaleOffset]
		[NORMAL]_BumpMap ("Normal", 2D) = "bump" {}
		
		[Space(20)][Header(SSS)]
		_SubColor ("SSS Color(RBGA)", Color) = (1.0, 1.0, 1.0, 1.0)   //A通道控制整体亮度
		_ThicknessScale ("ThicknessScale", Range(1, 3)) = 1.5
		[NoScaleOffset]
		_Thickness ("ThicknessMask (RGB)", 2D) = "bump" {}		      //R通道为产生SSS效果区域蒙板图    //G通道为Thickness图    //B为粗糙图
		[NoScaleOffset]
		_MatCap ("MatCap (RGB)", 2D) = "white" {}		        	  //可带颜色     

		[Space(20)][Header(Others)]
		_SpecColora ("Specular Color(RBG)", Color) = (0.5, 0.5, 0.5, 1.0)   
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125		
	}  

	SubShader 
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "true"}   

		Cull Back
		LOD 600

		Pass
		{
			Tags { "LightMode"="ForwardBase" } 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 

			#define LIGHTMAP
			#define TIER3andTIER2
			#define TIER3
			#define DOD_FOG_LINEAR
			#include "SceneItemSSS.cginc"
			#pragma shader_feature DOD_PLATFORM_PC DOD_PLATFORM_MOBILE				
			// #pragma multi_compile_fwdbase
			ENDCG  
		}
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "true"}   

		Cull Back
		LOD 300

		Pass
		{
			Tags { "LightMode"="ForwardBase" } 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 

			#define LIGHTMAP
			#define TIER3andTIER2
			#define TIER2
			#define DOD_FOG_LINEAR
			#include "SceneItemSSS.cginc"
			#pragma shader_feature DOD_PLATFORM_PC DOD_PLATFORM_MOBILE				
			// #pragma multi_compile_fwdbase
			ENDCG  
		}
	}

	SubShader 
	{
		Tags { "RenderType"="Opaque" "IgnoreProjector" = "true"}   

		Cull Back
		LOD 200

		Pass
		{
			Tags { "LightMode"="ForwardBase" } 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 

			#define LIGHTMAP
			#define TIER3andTIER2
			#define TIER1
			#define DOD_FOG_LINEAR
			#include "SceneItemSSS.cginc"
			#pragma shader_feature DOD_PLATFORM_PC DOD_PLATFORM_MOBILE				
			// #pragma multi_compile_fwdbase
			ENDCG  
		}		
	}
    Fallback "Dodjoy/FallBack"
}














