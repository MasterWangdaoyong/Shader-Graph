Shader "Darkgold/Unlit/sample_Normal"
{                         //模型顶点shader控制示范   
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NormalStrange("Model NormalStrange", Range(-0.1, 0.1)) = 0
		[Header(Wave Visuals)]
		_Wave_Speed("Wobble Speed", float) = 1
		_Wave_Distance("Wave Distance", float) = 1
		_Wave_Frequency("Wave Frequency", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{   
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;    //模型信息存储
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;   //控制地砖大小
			float _NormalStrange;
			
			float _Wave_Speed;
			float _Wave_Distance;
			float _Wave_Frequency;




			v2f vert (appdata v)       
			{
				v2f o;
				v.vertex.xyz += v.normal.xyz * _NormalStrange;    //顶点函数需要的模型法线信息，调用它，数据存储在struct  里面
				//o.vertex = UnityObjectToClipPos(v.vertex);

				float waveTime = _Time.y * _Wave_Speed;
				float waveRipples = v.vertex.y * _Wave_Frequency;
				v.vertex.x += sin(waveTime + waveRipples) * _Wave_Distance;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target     
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
