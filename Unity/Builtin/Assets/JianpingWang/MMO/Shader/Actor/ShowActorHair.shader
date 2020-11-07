Shader "MMO/Actor/Show/ActorHair" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB)", 2D) = "grey" {}
	_DiffScale("Diffuse Scale", float) = 1
	_DiffWrap("Diffuse Wrap", range(0, 10)) = 0.5
	
	_MaskTex ("Mask Tex(R-Spec1 Mask,G-Spec2 Mask ,B-AnisoRand)", 2D) = "white" {}
	
	_AnisoSpecColor1("Specular1 Color", Color) = (1,1,1,1)
	_AnisoCtrl("Specular1 Ctrl(X-Tangent Roughness, Y-Binormal Roughness, Z-SpecScale, W-AnisoOffset)", vector) = (0.1,0.1,1)	
	_AnisoRandScale("Specular1 random scale", float) = 1
	
	_AnisoSpecColor2("Specular2 Color", Color) = (1,1,1,1)
	_AnisoCtrl2("Specular2 Ctrl2(X-Tangent Roughness, Y-Binormal Roughness, Z-SpecScale, W-AnisoOffset)", vector) = (0.1,0.1,1)
	_AnisoRandScale2("Specular2 random scale", float) = 1
	
	_AnisoTex ("Aniso Random Map", 2D) = "gray" {}
	_Cutoff("Cut off", Range(0, 1)) = 0.5
	
}


SubShader { 
	
	Tags { "Queue"="Transparent+10" "IgnoreProjector"="True" "RenderType"="Transparent"}
	

	Pass { 
	
	Cull Off
	ZWrite On
	//ColorMask 0
	
	CGPROGRAM
	#include "UnityCG.cginc"
 
    #pragma vertex vert_mask ?
    #pragma fragment frag_mask ?
		
    sampler2D _MainTex;
    float4 _MainTex_ST;
    fixed _Cutoff;
	fixed4 _Color;
 
    struct a2v {
    float4 vertex : POSITION;
    float4 texcoord : TEXCOORD0;
    };
 
    struct v2f {
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD2;
    };
	
    v2f vert_mask(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		return o;
    }
    fixed4 frag_mask(v2f i) : SV_Target{
		fixed4 texColor = tex2D(_MainTex, i.uv);
		//AlphaTest
		clip(texColor.a - _Cutoff);

		return _Color * (1 - texColor.a);
    }
	
	ENDCG
	
	}

	
	Pass
	{
		Cull  Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		
		#pragma vertex BrdfVert
		#pragma fragment BrdfFrag
				
		#define DIFFUSE_ON
		#define SPEC_ON
		#define ENVLIGHT_ON
		#define _ANISO_ON
		#define TEX_HIGH
		
		
		#define CUSTOM_ENV_LIGHT_ON
		
		#pragma multi_compile_fwdbase
		
		#define USE_DOD_SHADOW	
		#include "ActorBrdfCore.cginc"		

		ENDCG
		
	}	
	
	// ------------------------------------------------------------------
	//  Additive forward pass (one light per pass)
	
	Pass
	{
		Name "FORWARD_DELTA"
		Tags { "LightMode" = "ForwardAdd" }
		Blend One One
		Fog { Color (0,0,0,0) } // in additive pass fog should be black
		ZWrite Off
		ZTest LEqual

		CGPROGRAM
		
		#pragma vertex BrdfVert
		#pragma fragment BrdfFrag
		
		#pragma multi_compile_fwdadd
		
		#define DIFFUSE_ON
		#define TEX_HIGH
		
		#include "ActorBrdfCore.cginc"		
		
		ENDCG
	}
	
}

}

