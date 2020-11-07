// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Dodjoy/Scene/Scene_Sky"
{
	Properties {
		_MainTex ("Base layer (RGB)", 2D) = "white" {}
		_LensColor("Lens Color", Color) =(1,1,1,0)
		_LensBrightness("Lens Brightness", Float) = 1
	}
	
	SubShader {
	
		Tags {"RenderType"="Overlay" "Queue"="Overlay"}
		
		ZWrite Off

		//ZTest 
		Fog {Mode Off}
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha 
		ColorMask RGB
		
		Pass {	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2

			#include "UnityCG.cginc"
			//#include "CustomFog.cginc"

			sampler2D _MainTex;
			fixed3 _LensColor;
			fixed  _LensBrightness;
			
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				//float2 fogCoord : TEXCOORD1;
			};

			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				//CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);
				return o;
			}
		
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.texcoord);
				c.rgb = c.rgb * _LensColor * _LensBrightness;
				//CUSTOM_APPLY_FOG(i.fogCoord, c.rgb);
				return c;
			}
			ENDCG 
		}
	}
}
