// 时间来回 20201114

Shader "Custom/Examples/Time Shader"{

	Properties{

		[Header(Main Visuals)]
		[NoScaleOffset]_MainTexture("Main Texture (RGBA)", 2D) = "white" {}

		[Header(Wave Visuals)]
		_Wave_Speed("Wobble Speed", float) = 1
		_Wave_Distance("Wave Distance", float) = 1
		_Wave_Frequency("Wave Frequency", float) = 1

	}

	SubShader{

		Pass{

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
			};

			struct v2f{
				float4 position : SV_POSITION;
				float2 uv0 : TEXCOORD0;
			};

			sampler2D _MainTexture;

			float _Wave_Speed;
			float _Wave_Frequency;
			float _Wave_Distance;

			v2f vert(appdata IN){
				v2f OUT;

				float waveTime = _Time.y * _Wave_Speed;
				float waveRipples = IN.vertex.y * _Wave_Frequency;

				IN.vertex.x += sin(waveTime + waveRipples) * _Wave_Distance;

				OUT.position = UnityObjectToClipPos(IN.vertex);
				
				OUT.uv0 = IN.uv0;

				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target{

				fixed4 mainTextureColor = tex2D(_MainTexture, IN.uv0);
				return mainTextureColor;
				
			}

			ENDCG
		}
	}

}
