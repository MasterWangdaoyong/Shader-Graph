

Shader "Dodjoy/Effect/Mask_Alpha_Blend"               //	//添加UV动画     //20200319			//JianpingWang
{

Properties 
{	
	[Header(Base)] 
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex("Particle Texture (A = Transparency)", 2D) = "white"{}
	_SpeedV ("V速度", Float ) = 0
    _SpeedU ("U速度", Float ) = 0

	[Space(20)] [Header(Mask)] 
	_MaskColor ("MaskColor", Color) = (1,1,1,1)
	_MaskTex ("Masked Texture", 2D) = "gray" {}
	_SpeedV2 ("V速度", Float ) = 0
    _SpeedU2 ("U速度", Float ) = 0

	[Space(20)] [Header(Other)] 
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	_MskkType ("Masked UV Select", Range(0,1)) = 0	
}

Category 
{

	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

	Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater .01
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off
	BindChannels 
	{
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	// ---- Fragment program cards
	SubShader 
	{
		Pass 
		{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile __ UNITY_UI_CLIP_RECT
			
			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			fixed4 _TintColor, _MaskColor;
			float _MskkType;		//ѡ��Mask��UV
			float4 _ClipRect;
			
			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;			
				float2 texcoord1 : TEXCOORD1;	
				float2 texcoord2 : TEXCOORD2;
				#ifdef UNITY_UI_CLIP_RECT
				float4 worldPosition : TEXCOORD3;
				#endif
			};
			
			float4 _MainTex_ST;
			float4 _MaskTex_ST;

			uniform float _SpeedV;
            uniform float _SpeedU;
			uniform float _SpeedV2;
            uniform float _SpeedU2;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				#ifdef UNITY_UI_CLIP_RECT
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				half t = _Time.y;
				half2 MainTexUV = (half2 ((_SpeedU * t), (_SpeedV * t)) + v.texcoord);
				half2 MaskTexUV = (half2 ((_SpeedU2 * t), (_SpeedV2 * t)) + v.texcoord);

				o.texcoord = TRANSFORM_TEX(MainTexUV,_MainTex);
				o.texcoord1 = TRANSFORM_TEX(MaskTexUV,_MaskTex);
				o.texcoord2 = v.texcoord;
				return o;
			}

			sampler2D _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : COLOR
			{				
				float4 col = 2.0f * _TintColor * tex2D(_MainTex, i.texcoord) * _MaskColor;
				col.a *= (tex2D(_MaskTex, i.texcoord2).a * _MskkType + tex2D(_MaskTex, i.texcoord1).a * (1 - _MskkType));
				#ifdef UNITY_UI_CLIP_RECT
                col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
				return col;
			}
			ENDCG 
		}
	} 	
	
	// ---- Dual texture cards
	SubShader {
		Pass {
			SetTexture [_MainTex] {
				constantColor [_TintColor]
				combine constant * primary
			}
			SetTexture [_MainTex] {
				combine texture * previous DOUBLE
			}
		}
	}
	
	// ---- Single texture cards (does not do color tint)
	SubShader {
		Pass {
			SetTexture [_MainTex] {
				combine texture * primary
			}
		}
	}
}
}
