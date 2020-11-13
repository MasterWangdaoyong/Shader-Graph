Shader "Dodjoy/Effect/DodParticle" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	 [HideInInspector]SrcMode ("SrcMode", int) = 5
     [HideInInspector]DstMode ("DstMode", int) = 1
	_MaskTex ("Masked Texture", 2D) = "white" {}
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend [SrcMode] [DstMode]
	ColorMask RGB
	Cull Off 
	Lighting Off 
	ZWrite Off
	
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_fog
			#pragma multi_compile BlendAdd BlendAlpha BlendMul BlendMul2
			#pragma multi_compile _ MASK_R_CHANNEL
			#pragma multi_compile __ UNITY_UI_CLIP_RECT

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;

			fixed4 _TintColor;
			float4 _ClipRect;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				#ifdef UNITY_UI_CLIP_RECT
				float4 worldPosition : TEXCOORD3;
				#endif
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			float4 _MainTex_ST;
			float4 _MaskTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				#ifdef UNITY_UI_CLIP_RECT
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				#endif
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

				o.texcoord1 = TRANSFORM_TEX(v.texcoord, _MaskTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{				
				fixed4 res = 2.0 * i.color * tex2D(_MainTex, i.texcoord);
				res.rgb = res.rgb * _TintColor.rgb;

				#ifdef BlendAdd
					UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(0,0,0,0)); 
				#endif
				#ifdef BlendAlpha
					UNITY_APPLY_FOG(i.fogCoord, res);
				#endif

				#ifdef BlendMul
					res = 0.5 * res;
					res = lerp(half4(1,1,1,1), res, res.a);
					UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(1,1,1,1)); // fog towards white due to our blend mode
				#endif
				
				#ifdef BlendMul2
					res = lerp(half4(0.5,0.5,0.5,0.5), res, res.a);
					UNITY_APPLY_FOG_COLOR(i.fogCoord, res, half4(0.5,0.5,0.5,0.5)); // fog towards gray due to our blend mode
				#endif				

				res.a = res.a * _TintColor.a;

				#ifdef MASK_R_CHANNEL
					res.a *= tex2D(_MaskTex, i.texcoord1).r;
				#else
					res.a *= tex2D(_MaskTex, i.texcoord1).a;
				#endif

				#ifdef UNITY_UI_CLIP_RECT
                res.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
                
				return res;
			}
			ENDCG 
		}
	}	
}
 CustomEditor "DodParticleInspector"
}