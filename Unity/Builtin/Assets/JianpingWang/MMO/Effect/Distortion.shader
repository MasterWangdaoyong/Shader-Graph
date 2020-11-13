// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dodjoy/Effect/Distortion" {
Properties {
	_NoiseTex ("Noise Texture (RG)", 2D) = "white" {}
	_MainTex ("Alpha (A)", 2D) = "white" {}
	_HeatTime  ("Heat Time", range (0,1.5)) = 1
	_HeatForce  ("Heat Force", range (0,2)) = 0.1
}

Category {
	Tags { "Queue"="Transparent+1" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater .01
	Cull Off Lighting Off ZWrite Off
	

	SubShader {


		Pass {
			Name "BASE"
			Tags { "LightMode" = "Always" }
			
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest
#pragma multi_compile __ UNITY_UI_CLIP_RECT
#include "UnityCG.cginc"
#include "UnityUI.cginc"

struct appdata_t {
	float4 vertex : POSITION;
	fixed4 color : COLOR;
	float2 texcoord: TEXCOORD0;
};

struct v2f {
	float4 vertex : POSITION;
	float4 uvgrab : TEXCOORD0;
	float2 uvmain : TEXCOORD1;
	#ifdef UNITY_UI_CLIP_RECT
	float4 worldPosition : TEXCOORD2;
	#endif
};

float _HeatForce;
float _HeatTime;
float4 _MainTex_ST;
float4 _NoiseTex_ST;
sampler2D _NoiseTex;
sampler2D _MainTex;
float4 _ClipRect;

v2f vert (appdata_t v)
{
	v2f o;
	#ifdef UNITY_UI_CLIP_RECT
	o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
	#endif
	o.vertex = UnityObjectToClipPos(v.vertex);
	#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
	#else
	float scale = 1.0;
	#endif
	o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
	o.uvgrab.zw = o.vertex.zw;
	o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
	return o;
}

//sampler2D _GrabTexture;
sampler2D _DodGrapTexture;

half4 frag( v2f i ) : COLOR
{

	//noise effect
	half4 offsetColor1 = tex2D(_NoiseTex, i.uvmain + _Time.xz*_HeatTime);
    half4 offsetColor2 = tex2D(_NoiseTex, i.uvmain - _Time.yx*_HeatTime);
	i.uvgrab.x += ((offsetColor1.r + offsetColor2.r) - 1) * _HeatForce;
	i.uvgrab.y += ((offsetColor1.g + offsetColor2.g) - 1) * _HeatForce;
	

	half4 col = tex2Dproj(_DodGrapTexture, UNITY_PROJ_COORD(i.uvgrab));
	//Skybox's alpha is zero, don't know why.
	col.a = 1.0f;
	half4 tint = tex2D( _MainTex, i.uvmain);

	#ifdef UNITY_UI_CLIP_RECT
    col.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
    #endif
	return col*tint;
}
ENDCG
		}
}

	// ------------------------------------------------------------------
	// Fallback for older cards and Unity non-Pro
	
	SubShader {
		Blend DstColor Zero
		Pass {
			Name "BASE"
			SetTexture [_MainTex] {	combine texture }
		}
	}
}
}
