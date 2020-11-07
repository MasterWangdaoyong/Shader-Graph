Shader "Unlit/Test"
{
	Properties
	{
		_MainColor("MainColor",COLOR) = (0,0,0,1)
		[NoScaleOffset]_MainCUBE("MainCUBE", CUBE) = "white" {}
		_RefStreng("RefStreng",Range(0,2.0)) = 0
		_Enviorenment("Enviorenment",Range(0,2.0)) = 0
		_Emission("Emission",Range(0,2.0)) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Cull Front
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 uv : TEXCOORD0;
				float3 n:NORMAL;
			};


			struct v2f
			{
				float3 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			samplerCUBE _MainCUBE;
			float4 _MainColor;
			float _Enviorenment;
			float _Emission;


			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				o.uv = -reflect(viewDir,v.n);
				o.uv = mul(unity_ObjectToWorld,float4(o.uv,0));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 col = texCUBE(_MainCUBE,i.uv)*_MainColor;
				float4 refColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,i.uv);
				refColor.rgb = DecodeHDR(refColor,unity_SpecCube0_HDR);
				float3 mulColor = refColor.rgb*_Enviorenment + _Emission;
				col = float4(col.rgb*mulColor,1);
				return col;
			}
			ENDCG
		}
		pass
		{
			Tags { "LightMode" = "LightweightForward" }

			Cull Off
			ZWrite On
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 pos:SV_POSITION;
				float3 uv:TEXCOORD0;
				float rim : TEXCOORD1;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				o.uv = -reflect(viewDir,v.normal);
				o.uv = mul(unity_ObjectToWorld,float4(o.uv,0));
				o.rim = 1.0 - saturate(dot(v.normal,viewDir));
				return o;
			}
			
			samplerCUBE _MainCUBE;
			float4 _MainColor;
			float _Enviorenment;
			float _Emission;
			float _RefStreng;

			fixed4 frag(v2f i) :SV_Target
			{
				float4 col = texCUBE(_MainCUBE,i.uv)*_MainColor;
				float4 refColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0,i.uv);
				refColor.rgb = DecodeHDR(refColor,unity_SpecCube0_HDR);
				float3 refColor2 = refColor * _RefStreng*i.rim;
				float3 mulColor = refColor * _Enviorenment + _Emission;
				col = float4(refColor2 + col.rgb*mulColor,1);
				return col;
			}
			ENDCG
		}
		UsePass "VertexLit/SHADOWCASTER"
		}

}
