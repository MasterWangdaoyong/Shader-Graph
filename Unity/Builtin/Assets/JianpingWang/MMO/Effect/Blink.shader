Shader "Dodjoy/Effect/Blink"
{
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Map", 2D) = "white" {}
		_Speed("Blink Speed", Range(0, 10)) = 1
		_AlphaRange("Alpha Range", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Tags{"RenderType"="Transparent" "Queue"="Transparent" "IgnorProjector"="true"}

		pass
		{
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Speed;
			float _AlphaRange;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			float4 frag(v2f i) : SV_Target
			{
				float t = cos(_Time.y * _Speed) * 0.5  + 0.5;
				float4 color = tex2D(_MainTex, i.uv) * _Color;
				float alpha = _Color.a * t + _AlphaRange;
				alpha = clamp(0, 1, alpha);

				return float4(color.rgb, alpha);
			}
			ENDCG
		}
	}
	Fallback "Transparent/VertexLit"
}