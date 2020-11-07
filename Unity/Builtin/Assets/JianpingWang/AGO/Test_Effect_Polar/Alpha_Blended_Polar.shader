
Shader "JianpingWang/Effect/Alpha_Blended_Polar"      //JianpingWang  //20200225  //0319  //0331 极坐标与极坐标		//资源贴图中需要把MIPMAP关了
{												
	Properties
	{	
		_MainColor("Color(RGBA)", Color) = (1,1,1,1)
		[NoScaleOffset]
		_MainTex("MainTex(RGBA)", 2D) = "white" {}
		[NoScaleOffset]
		_MaskTex("MaskTex(RGB)", 2D) = "white" {}			//黑白图，只用了一个通道；如果增加功能时可用
		_ScaleOffset("ScaleOffset", Vector) = (1,1,0,0)
		_Scale("Scale", Float) = 1
		_Rotator("Rotator", Float) = 0		
		_GLOW ("GLOW", Float ) = 1
		// _SpeedV ("V速度", Float ) = 0
        // _SpeedU ("U速度", Float ) = 0
	}
	
	SubShader
	{		
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}
		Pass
		{
			
			Tags { "LightMode"="ForwardBase" }

			Blend SrcAlpha OneMinusSrcAlpha
    		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;	
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex, _MaskTex;
			float4 _MainTex_ST, _ScaleOffset;
			half _Rotator, _Scale, _GLOW;
			fixed4 _MainColor;			

			inline float2 OffUV(float2 uv, float4 _MainTex_ST, half _Rotator, half _Scale, float4 _ScaleOffset)
			{
				float2 texUv = uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				//旋转矩阵
				float  As = ((1.0 - length(texUv*2.0 -1.0)) * 2.0 * _Rotator ) * UNITY_PI ;
				float CosA = cos(As);
				float SinA = sin(As);
				float2 rotator2 = mul(texUv - float2( 0.5,0.5 ) , float2x2( CosA , -SinA , SinA , CosA )) + float2( 0.5,0.5 );  

				float2 tempUv = (rotator2 * 2.0 -1.0);  
				
				float2 fixUvA = (float2(pow( length( tempUv ) , _Scale ) , (( atan2( tempUv.y , tempUv.x ) / ( 2.0 * UNITY_PI )) + 0.5 )));
				float2 fixUvB = (float2(_ScaleOffset.x , _ScaleOffset.y));
				float2 fixUvc = (float2(_ScaleOffset.z , _ScaleOffset.w));
				
				return fixUvA * fixUvB + fixUvc;
			}

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.uv.xy = v.texcoord.xy;

				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				
				float2 OffsetUv = OffUV(i.uv, _MainTex_ST, _Rotator, _Scale, _ScaleOffset);   //可优化，可以放在顶点函数里面计算 07272020  但是存在问题，顶点数量不够

				float2 fixUV = (float2(OffsetUv.y , OffsetUv.x));  //修改贴图的竖直还是平水载入

				fixed4 mask = tex2D(_MaskTex, i.uv);
				float4 col = 2.0f * tex2D(_MainTex, fixUV) * _MainColor * _GLOW;
				
				
				col.a = saturate(col.a * mask.r * _MainColor.a);			

				return col;
			}
			ENDCG
		}
	}	
	
}
