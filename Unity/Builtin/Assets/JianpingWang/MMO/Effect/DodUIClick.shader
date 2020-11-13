Shader "Dodjoy/Effect/DodUIClick"
{
	Properties
	{
	   _Radius("Radius", Range(0,0.5)) = 0.1
	   [PerRendererData]_MainTex("Sprite Texture", 2D) = "white" {} 	

	    //unity Mask
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255
		_ColorMask("Color Mask", Float) = 15
	}

	SubShader
	{
		  Tags
		  {
			 "Queue" = "Transparent"			 
			 "CanUseSpriteAtlas" = "True"
		  }

		  Stencil
		  {
			  Ref[_Stencil]
			  Comp[_StencilComp]
			  Pass[_StencilOp]
			  ReadMask[_StencilReadMask]
			  WriteMask[_StencilWriteMask]
		  }

		  Pass
		  {

			  Cull Off			 			 
			  Blend SrcAlpha OneMinusSrcAlpha
			  ColorMask[_ColorMask]

			  CGPROGRAM
			  #pragma vertex vert
			  #pragma fragment frag

			  sampler2D _MainTex;
			  float _Radius;

			  struct Vertex
			  {
				  float4 vertex : POSITION;
				  float2 uv : TEXCOORD0;				  
				  float4 color : COLOR;
			  };

			  struct Fragment
			  {
				  float4 vertex : POSITION;
				  float2 uv : TEXCOORD0;
				  float4 color:COLOR;
			  };

			  Fragment vert(Vertex v)
			  {
				  Fragment o;
				  o.vertex = UnityObjectToClipPos(v.vertex);
				  o.uv = v.uv;
				  o.color = v.color;
				  return o;
			  }

			  float4 frag(Fragment IN) : COLOR
			  {			  	
				  float value = min(length(float2(0, 0) - IN.uv), length(float2(0, 1) - IN.uv));
				  value = min(value, min(length(float2(1, 0) - IN.uv), length(float2(1, 1) - IN.uv)));
				  float4 color = tex2D(_MainTex, IN.uv);
				  color.a = step(_Radius, value);
				  return color;
			  }

			  ENDCG
	      }
	}    
}