Shader "MMO/Actor/DodShaderCaster" {
	Properties{
	}

	SubShader{
		Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque"}

		// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass {
			Name "ShadowCaster"

			CGPROGRAM

			#pragma multi_compile_shadowcaster			

			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster

			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			#include "UnityGlobalIllumination.cginc"
			#include "AutoLight.cginc"

			float _DodShadowBias;


		struct v2f_shadowcaster { 
			float4 pos : SV_POSITION;
		};
		
		
		float4 DodApplyLinearShadowBias(float4 clipPos)
		{
			float2 xy = clipPos.xy / clipPos.w;
			half2 trigger = 0.9;
			half2 mask = (1-step(trigger, xy)) * (1-step(xy, -trigger));
			half maskTerm = mask.x * mask.y;
			
		#if defined(UNITY_REVERSED_Z)
			// We use max/min instead of clamp to ensure proper handling of the rare case
			// where both numerator and denominator are zero and the fraction becomes NaN.
			//clipPos.z += max(-1, min(_DodShadowBias / clipPos.w, 0));
			clipPos.z -= _DodShadowBias * clipPos.w;
			float clamped = min(clipPos.z, clipPos.w*UNITY_NEAR_CLIP_VALUE);
			
			clamped = lerp(0, clamped, maskTerm);
			
		#else
			//clipPos.z += saturate(_DodShadowBias/clipPos.w);
			clipPos.z += _DodShadowBias * clipPos.w;
			float clamped = max(clipPos.z, clipPos.w*UNITY_NEAR_CLIP_VALUE);
			
			clamped = lerp(1, clamped, maskTerm);
		#endif
			
			clipPos.z = clamped;//lerp(clipPos.z, clamped, _DodShadowBias.y);
			return clipPos;
		}

		v2f_shadowcaster vertShadowCaster(appdata_base v)
		{
			v2f_shadowcaster o;
			o.pos = DodApplyLinearShadowBias(UnityObjectToClipPos(v.vertex));
			return o;
		}

		float4 fragShadowCaster(v2f_shadowcaster i) : SV_Target
		{
			return 0;
		}
		
		ENDCG
	}
}


}

