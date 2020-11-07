Shader "MMO/Actor/ActorUnlit" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_Luminance("Luminance", Range(0, 2)) = 1
	}


	SubShader { 
		Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"		

			struct appdata 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;				
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;	
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Luminance;

			v2f vert(appdata v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 albedo = tex2D(_MainTex, i.uv);
				albedo *= _Luminance;
				return fixed4(albedo, 1.0);
			}

			ENDCG
			
		}	
	}
}

