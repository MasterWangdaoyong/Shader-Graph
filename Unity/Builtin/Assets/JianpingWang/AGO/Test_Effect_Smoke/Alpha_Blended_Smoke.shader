
Shader "JianpingWang/Effect/Alpha_Blended_Smoke"     //JianpingWang  //20200226  //0331  烟、雾、云 
{
	Properties
	{
		_MainTex("MainTex(RGBA)", 2D) = "white" {}
		_DirColor("DirColor(RGBA)", Color) = (1,1,1,1)
		_ShadowColor("ShadowColor(RGBA)", Color) = (0.5,0.5,0.5,1)
		_GLOW("GLOW", Range( 1 , 5)) = 2
	}
	
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "PreviewType"="Plane"}

		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off	

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma multi_compile_particles
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				half3 normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 uv : TEXCOORD0;	
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			
			half4 _ShadowColor;
			sampler2D _MainTex;
			half4 _MainTex_ST;
			half4 _DirColor;
			half _GLOW;
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half LDirdotN = dot(_WorldSpaceLightPos0.xyz , worldNormal );
				o.uv.z = (LDirdotN * 0.5 + 0.5);				//修改坐标位置
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);				
				fixed4 finalColor = fixed4(0,0,0,0);
				fixed4 tex = tex2D( _MainTex, i.uv.xy);

				half sResult = smoothstep( 0.4 , 0.6 , i.uv.z);
				finalColor.rgb = lerp(( _ShadowColor.rgb * tex.rgb) , ( _DirColor.rgb * tex.rgb ) , sResult) * _GLOW;
				finalColor.a = saturate(_ShadowColor.a * _DirColor.a * tex.a);
				
				return finalColor;
			}
			ENDCG
		}
	}

}