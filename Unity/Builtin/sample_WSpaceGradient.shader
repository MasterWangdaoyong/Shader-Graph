Shader "Darkgold/Unlit/sample_WSpaceGradient"
{      //通过模型的世界坐标来控制相关shader
	Properties
	{                                 
		
		_LowColor("LowColor", Color) = (1,1,1,1)
		_HighColor("HighColor", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Gradient_Origin("Gradient Origin", float) = 1
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)    
				float4 vertex : SV_POSITION;
				float3 worldPosition : TEXCOORD2;            //如果TEXCOORD1报错，那么修改成2就对了，也就不跟fog有冲突了
				
			
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _LowColor;
			float4 _HighColor;
			float _Gradient_Origin;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);     //这是？      unity_ObjectToWorld？？
				UNITY_TRANSFER_FOG(o,o.vertex);  
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture  
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 gradientCol = lerp(_LowColor, _HighColor, i.worldPosition.y * _Gradient_Origin);     //lerp()???
				fixed4 col2 = col * gradientCol;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col2);             //为什么我不用FOG就对了？   因为上面跟FOG的叠加UV通道相冲突了
				return col2;
			}
			ENDCG
		}
	}
}
