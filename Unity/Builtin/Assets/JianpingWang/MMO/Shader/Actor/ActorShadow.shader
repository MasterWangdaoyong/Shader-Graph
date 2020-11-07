Shader "MMO/Actor/ActorShdow" 
{
	SubShader
	{
		Tags {"LightMode" = "ShadowCaster"}
		Pass 
		{
			Name "SHADOW"
			ZWrite On ZTest LEqual
			CGPROGRAM
			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			#include "ActorShadowCaster.cginc"
			
			ENDCG
		}

		Pass 
		{
			Name "SHADOW_CUTOFF"
			ZWrite On ZTest LEqual
			CGPROGRAM
			#pragma multi_compile_shadowcaster

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			#define CUT_OFF
			#include "ActorShadowCaster.cginc"
			
			ENDCG
		}
	}
}

