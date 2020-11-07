Shader "MMO/Scene/SceneSkyboxCube"
{
    Properties
    {
		_Tint("Tint Color", color) = (0.5, 0.5, 0.5, 1.0)
		_MainColor ("Main Color(RGB)", Color) = (1,1,1,1)
        [Gamma]_Exposure("Exposure", range(0, 8)) = 1.0
		_Rotation("Rotation", range(0, 360)) = 0
		_Cubemap("Cubemap (HDR)", Cube) = "grey" {}
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
		Cull Off
		ZWrite Off
		LOD 600
        Pass
        {
            CGPROGRAM
            #pragma vertex Skyboxvert
            #pragma fragment Skyboxfrag
			#pragma multi_compile_fwdbase
			#define FOG_SKY_BOX
			#define LINEARCOLOR
			#define DOD_SUN_ON
			#define DOD_FOG_LINEAR
			#include "DodSkyboxCore.cginc"
			ENDCG
		}
    }
	    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
		Cull Off
		ZWrite Off
		LOD 300
        Pass
        {
            CGPROGRAM
            #pragma vertex Skyboxvert
            #pragma fragment Skyboxfrag
			#pragma multi_compile_fwdbase
			#define FOG_SKY_BOX
			#define DOD_FOG_LINEAR
			#include "DodSkyboxCore.cginc"
			ENDCG
		}
    }
	SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
		Cull Off
		ZWrite Off
		LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex Skyboxvert
            #pragma fragment Skyboxfrag
			#pragma multi_compile_fwdbase
			#define FOG_SKY_BOX
			#define DOD_FOG_LINEAR
			#include "DodSkyboxCore.cginc"
			ENDCG
		}
    }
}
