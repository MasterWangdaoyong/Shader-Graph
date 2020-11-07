Shader "MMO/Scene/Scene_Nature_Tree"    //JianpingWang //20200328  //20200408      
{
   Properties
    {	
		[NoScaleOffset] [Header(Base)]
		_MainColor ("Main Color(RGB)", Color) = (1,1,1,1)
        _MainTex ("Texture(RGBA)", 2D) = "white" {}		
		_LightmapScale("LightmapScale", Range(0, 1.0)) = 0.1     
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

		[Space(20)] [Header(VetexAnimation)]			
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0
		_Direction("Swing Direction", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", float) = 1
		_TimeDelay("TimeDelay",float) = 1	
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
		Cull Off 
		LOD 600
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM

			#define DOD_SUN_ON
			#define SWING_ON
			#define DOD_FOG_LINEAR
			#define HIGHTFOG
			#define LINEARCOLOR
            #pragma vertex Naturevert
            #pragma fragment Naturefrag   

			#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing	
			#include "DodNatureCore.cginc"
			ENDCG
        }
    }

	 SubShader
    {
        Tags { "RenderType"="TransparentCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
		Cull Off 
		LOD 300
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM

			#define SWING_ON
			#define DOD_FOG_LINEAR
            #pragma vertex Naturevert
            #pragma fragment Naturefrag   

			#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing	
			#include "DodNatureCore.cginc"
			ENDCG
        }
    }

	SubShader
    {
        Tags { "RenderType"="TransparentCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
		Cull Off 
		LOD 200
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM

            #pragma vertex Naturevert
            #pragma fragment Naturefrag   
			#define DOD_FOG_LINEAR
			#pragma multi_compile_fwdbase
			#pragma multi_compile_instancing	
			#include "DodNatureCore.cginc"
			ENDCG
        }
    }
	
}