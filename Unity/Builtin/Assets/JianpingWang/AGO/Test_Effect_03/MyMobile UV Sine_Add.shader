// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyMobile/UV/Sine_Add" {
	Properties {
		_MainTex ("Base layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_Color("Color", Color) = (1,1,1,1)
		_MMultiplier ("Layer Multiplier", Float) = 2.0
		_Conform("Conform",float) = 0
		_Height("Height",range(0,1)) = 0
	}
	SubShader {
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
	
		Blend SrcAlpha One
		ZWrite Off 
		Cull Off
		
	CGINCLUDE   
	#include "UnityCG.cginc"
	sampler2D _MainTex;
	sampler2D _DetailTex;

	fixed4 _MainTex_ST;
	fixed4 _DetailTex_ST;
	
	fixed _ScrollX;
	fixed _ScrollY;
	fixed _Scroll2X;
	fixed _Scroll2Y;
	fixed _MMultiplier;
	fixed4 _Color;
	fixed _Conform;
	fixed _Height;

	struct appdata
	{
		fixed4 vertex : POSITION;
		fixed4 texcoord : TEXCOORD0;
		fixed4 color : COLOR;
	};

	struct v2f {
		fixed4 pos : SV_POSITION;
		fixed4 uv : TEXCOORD0;
		fixed4 color : TEXCOORD1;
	};

	v2f vert (appdata v)
	{
		v2f o;

		o.pos = UnityObjectToClipPos(v.vertex);
		//o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex) + frac(fixed2(_ScrollX, _ScrollY) * _Time);
		o.uv.zw = TRANSFORM_TEX(v.texcoord.xy,_DetailTex) + frac(fixed2(_Scroll2X, _Scroll2Y) * _Time);
		
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
		fixed4 frag (v2f i) : COLOR
		{
			fixed4 o;
			fixed4 tex = tex2D (_MainTex, i.uv.xy);
			fixed4 tex2 = tex2D (_DetailTex, i.uv.zw);
			
			o = tex * tex2 * _Color* i.color;
			//o = sqrt(o);
						
			return o;
		}
		ENDCG 
	}

	} 
}
