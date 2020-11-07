Shader "MMO/Actor/TestActorTrans" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "grey" {}
		_DiffScale("Diffuse Scale", Range(0, 2)) = 1
		_Transparency("Transparency", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags{"Queue"="Transparent" "RenderType"="Transparent" "IgnorProjector"="true"}
		
		pass
		{
			ZWrite On
			Cull Back
			ZTest Equal
			ColorMask 0
		}

		Pass
		{
			Tags{"LigitMode"="ForwardBase"}
			ZWrite Off
			Cull Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "UnityCg.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 wNormal : TEXCOORD1;
				float3 wLightDir : TEXCOORD2;
			};
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _DiffScale;
			float _Transparency;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				float worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.wLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				o.wNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject).xyz);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half halfLambert = saturate(dot(i.wNormal, i.wLightDir)) * 0.5 + 0.5;
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 finalColor = (fixed4)0;
				finalColor.rgb = col * _DiffScale * halfLambert * _Color;
				finalColor.a = col.a * _Transparency;
				return finalColor;
			}
			ENDCG
		}
	}
}

