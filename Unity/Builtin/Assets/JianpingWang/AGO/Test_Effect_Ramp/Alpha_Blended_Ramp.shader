
Shader "JianpingWang/Effect/Alpha_Blended_Ramp"    //JianpingWang  //20200225 //0331    溶解
{					
	Properties
	{
		_MainColor("MainColor(RGBA)", Color) = (1,1,1,1)
		_MainTex("MainTex(RGBA)", 2D) = "white" {}
		_NoiseTex("NoiseTex(RGB)", 2D) = "white" {}     //黑白图，只用了一个通道；如果增加功能时可用
		[NoScaleOffset]
		_RampTex("RampTex(RGBA)", 2D) = "white" {}			//注意此贴图的格式
		_NoiseClip("NoiseClip", Range( 0 , 2)) = 0.3
		_EdgeColor("EdgeColor(RGB)", Color) = (1,1,1,1)
		_EdgeWidth("EdgeWidth", Range( 0 , 1)) = 0.3
		_GLOW("GLOW", Range( 1 , 5)) = 2
	}
	
	SubShader
	{			
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
		LOD 100			
		
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		Cull Off
		ColorMask RGB
		ZWrite Off		
		
		Pass
		{
			
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"			

			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float2 texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float2 uv : TEXCOORD0;
				float2 NoiseUV : TEXCOORD1;
				float4 color : COLOR;
			};

			uniform sampler2D _RampTex, _NoiseTex, _MainTex;
			uniform float4 _MainTex_ST, _NoiseTex_ST;
			uniform half _NoiseClip, _EdgeWidth, _GLOW;
			uniform fixed4 _EdgeColor, _MainColor;
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.NoiseUV = v.texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				o.color = v.color;				
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				
				fixed4 finalColor = fixed4(0,0,0,0);
				fixed4 NoiseTex = tex2D( _NoiseTex, i.NoiseUV );				

				float RampU = saturate((((NoiseTex.r + 1.0) - _NoiseClip) - (1.0 - _EdgeWidth)) / _EdgeWidth);
				half2 RampUv = half2(RampU , 0.0);
				fixed4 RampTex = tex2D( _RampTex, RampUv );	

				fixed4 MainTex = tex2D( _MainTex, i.uv );

				finalColor = lerp( ( ( RampTex * _EdgeColor ) * _GLOW ) , ( _MainColor * MainTex * i.color ) , RampTex.a);
				finalColor = fixed4(finalColor.rgb , saturate( _MainColor.a * MainTex.a * i.color.a * RampU));			
				
				return finalColor;
			}
			ENDCG
		}
	}
	
}
