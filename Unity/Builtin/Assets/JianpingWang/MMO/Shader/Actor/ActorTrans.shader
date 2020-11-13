Shader "Dodjoy/Actor/ActorTrans" {
	Properties {
		[Enum(Off, 0.0, On, 1.0)]_ZWrite("ZWrite", Float) = 1.0
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_FadeAlpha("Alpha Scale", Range(0, 1)) = 1
		_Luminance("Luminance", Range(0, 2)) = 1
	}


	SubShader 
	{
		Tags {"Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		 Pass
		{
			ZWrite [_ZWrite]
			ColorMask 0
		}
		
		Pass
		{
			Cull off
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			
			
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
			fixed4 _Color;
			float _FadeAlpha;
			float _Luminance;
			v2f vert(appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 albedo = tex2D(_MainTex, i.uv);
				float alpha = max(0.1, albedo.a);

				fixed4 finalColor = (fixed4)0;
				finalColor.rgb = albedo.rgb * _Color * _Luminance;
				finalColor.a = albedo.a * _FadeAlpha;
				return finalColor;
			}
			ENDCG
		}
	}
}

