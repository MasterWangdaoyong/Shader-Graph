
Shader "MMO/Scene/SceneNorlmal"
{
    Properties
    {
		_MainColor ("Main Color(RGB)", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_NormalTex("Normal", 2D) = "white" {}
		_Metallic("Metallic",range(0,1)) = 0.8
		_roughness ("Roughness",range(0,1)) = 0.8
		_reflect("Reflect",range(0,1)) = 0.0
		_Emission("Emission",range(1,6)) = 1.0
		_MaskTex ("Mask Texture", 2D) = "black" {}
		[Toggle(DOD_SUN_ON)]_SunOn("Sun on", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
		
		Cull Back
		LOD 600
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex SceneVert
            #pragma fragment SceneFrag   

			#define SHADOW_ON
			#define DOD_SUN_ON
			#define HIGHTFOG
			#define LINEARCOLOR
			#define NORMAL_ON
			#define PRSLIGHT_ON
			#pragma multi_compile_fwdbase
			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR
			#pragma multi_compile LIGHTMAP_ON
			#pragma multi_compile DOD_PLATFORM_PC DOD_PLATFORM_MOBILE
			#pragma multi_compile_instancing
			#include "DodScenePbsCore.cginc"

            ENDCG
        }
    }

	SubShader
    {
        Tags { "RenderType"="Opaque" }
		
		Cull Back
		LOD 300
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex SceneVert
            #pragma fragment SceneFrag   

			#define MIDLIGHT_ON
			#define SHADOW_ON
			#define DOD_FOG_LINEAR
			#define NORMAL_ON
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_ON

			#pragma multi_compile DOD_PLATFORM_PC DOD_PLATFORM_MOBILE
			#pragma multi_compile_instancing
			#include "DodScenePbsCore.cginc"

            ENDCG
        }
    }

	SubShader
    {
        Tags { "RenderType"="Opaque" }
		
		Cull Back
		LOD 200
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex SceneVert
            #pragma fragment SceneFrag   

			#define SIMPLELIGHT_ON
			#define DOD_FOG_LINEAR
			#pragma multi_compile_fwdbase
			#pragma multi_compile LIGHTMAP_ON

			#pragma multi_compile DOD_PLATFORM_PC DOD_PLATFORM_MOBILE
			#pragma multi_compile_instancing
			#include "DodScenePbsCore.cginc"

            ENDCG
        }
    }
	
}
