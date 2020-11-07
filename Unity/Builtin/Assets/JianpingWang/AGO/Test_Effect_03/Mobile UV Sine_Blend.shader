// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Mobile/UV/Sine_Blend" {
Properties {
	_MainTex ("Base layer (RGB)", 2D) = "white" {}
	_DetailTex ("2nd layer (RGB)", 2D) = "white" {}
	_ScrollX ("Base layer Scroll speed X", Float) = 1.0
	_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
	_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
	_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
	_Color("Color", Color) = (1,1,1,1)
	_MMultiplier ("Layer Multiplier", range(0.01,5)) = 2.0
}

	
SubShader {
	Tags { "IgnoreProjector"="True" "RenderType"="Transparent" }
	
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off 
	Lighting Off 
	ZWrite Off 
	
	LOD 100
	
	CGINCLUDE   
	#include "UnityCG.cginc"
	sampler2D _MainTex;
	sampler2D _DetailTex;

	half4 _MainTex_ST;
	half4 _DetailTex_ST;
	
	half _ScrollX;
	half _ScrollY;
	half _Scroll2X;
	half _Scroll2Y;
	half _MMultiplier;
	half4 _Color;
	half _Conform;
	half _Height;

	struct v2f {
		half4 pos : SV_POSITION;
		half4 uv : TEXCOORD0;
		half4 color : TEXCOORD1;
	};

	
	v2f vert (appdata_full v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
		o.uv.zw = TRANSFORM_TEX(v.texcoord.xy,_DetailTex) + frac(float2(_Scroll2X, _Scroll2Y) * _Time);
		o.color = _MMultiplier * _Color * v.color;
		return o;
	}
	ENDCG
 

	Pass {
		Name "SINE_BLEND"
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest		
		half4 frag (v2f i) : COLOR
		{
			half4 o;
			half4 tex = tex2D (_MainTex, i.uv.xy);
			half4 tex2 = tex2D (_DetailTex, i.uv.zw);
			
			o = tex * tex2 * _Color * i.color;
			
			o.a = tex.a * i.color.a * _MMultiplier;
			return o;
		}
		ENDCG 
	}	
}
}
