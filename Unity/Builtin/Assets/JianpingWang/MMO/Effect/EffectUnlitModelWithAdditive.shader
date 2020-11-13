// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dodjoy/Effect/EffectUnlitModelWithAdditive" {

	Properties {
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull Mode", Float) = 2.0
		_Color ("Base Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_USpeed1("U Speed", Float) = 0
		_VSpeed1("V Speed", Float) = 0
		_DiffuseScale ("Diffuse Scale", float) = 1.0

		[Space(20)]
		_LightColor("Light Color", Color) = (1,1,1,1)
		_LightTex ("LightTex (RGB)", 2D) = "white" {}
		_USpeed2("U Speed", Float) = 0
		_VSpeed2("V Speed", Float) = 0
		_LightScale ("Light Scale", float) = 1.0

		[Space(20)]
		//_RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        //_RimWidth ("Rim Width", Range(0.01, 1.0)) = 0.5
		_MaskTex ("MaskTex(RGB)", 2D) = "white" {}
		_USpeed3("U Speed", Float) = 0
		_VSpeed3("V Speed", Float) = 0
		_AlphaScale("fade Scale", Range(0, 1)) = 1.0

		[Space(20)]
		_TintColor("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_AdditiveTex ("Particle Texture", 2D) = "white" {}
		_USpeed4("U Speed", Float) = 0
		_VSpeed4("V Speed", Float) = 0

		[Space(20)]
		_AdditiveMaskTex ("Particle Masked Texture", 2D) = "gray" {}
		_USpeed5("U Speed", Float) = 0
		_VSpeed5("V Speed", Float) = 0
	}
	
	SubShader {
		
		LOD 100
		Tags {
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}
		Pass{
			Cull[_Cull]
			ZWrite on
			ColorMask 0
			ZTest Equal
		}
		
		Pass{		

			Lighting Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			ZWrite Off
			Cull[_Cull]

			CGPROGRAM

			#pragma vertex vert alpha noambient
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			half  _DiffuseScale;
			uniform fixed _AlphaScale;
			half4 _Color;
			uniform fixed4 _RimColor;
	        half _RimWidth;
	        uniform float4 _MainTex_ST;
			
			sampler2D _LightTex;
			sampler2D _MaskTex;

			half  _LightScale;
			half4 _LightColor;

	        uniform float4 _LightTex_ST;
	        uniform float4 _MaskTex_ST;
			
			sampler2D _AdditiveTex;
			fixed4 _TintColor;
			sampler2D _AdditiveMaskTex;
			float4 _AdditiveTex_ST;
			float4 _AdditiveMaskTex_ST;

			half _USpeed1;
			half _VSpeed1;
			half _USpeed2;
			half _VSpeed2;
			half _USpeed3;
			half _VSpeed3;
			half _USpeed4;
			half _VSpeed4;
			half _USpeed5;
			half _VSpeed5;

			struct v2f {
				float4 pos : POSITION;
				fixed4 color : COLOR;
				float4 uv_MainLightTex: TEXCOORD0;
				float4 uv_MaskAddTex: TEXCOORD1;
				float4 uv_MaskAddTex2 : TEXCOORD2;
			};


			half2 ComputeUV(half2 uv, half2 speedUV)
			{
				half t = _Time.y;
				return speedUV * t + uv;
			}

			v2f vert(appdata_full v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);								
				o.color = v.color;
				
				//half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				//half dotProduct = 1 - dot(v.normal, viewDir);
				//o.color.a = smoothstep(1.0h - _RimWidth, 1.0h, dotProduct);
				//o.color = smoothstep(1.0h - _RimWidth, 1.0h, dotProduct);
				//o.color *= _RimColor;

				o.uv_MainLightTex.xy = ComputeUV(TRANSFORM_TEX(v.texcoord, _MainTex), half2(_USpeed1, _VSpeed1));
				o.uv_MainLightTex.zw = ComputeUV(TRANSFORM_TEX(v.texcoord, _LightTex), half2(_USpeed2, _VSpeed2));
				o.uv_MaskAddTex.xy = ComputeUV(TRANSFORM_TEX(v.texcoord, _MaskTex), half2(_USpeed3, _VSpeed3));
				o.uv_MaskAddTex.zw = ComputeUV(TRANSFORM_TEX(v.texcoord,_AdditiveTex), half2(_USpeed4, _VSpeed4));
				o.uv_MaskAddTex2.xy = ComputeUV(TRANSFORM_TEX(v.texcoord, _AdditiveMaskTex), half2(_USpeed5, _VSpeed5));
				
				return o;
			}

			float4 frag(v2f input):Color
			{ 
				half4 c = tex2D (_MainTex, input.uv_MainLightTex.xy) * _Color;
				c.rgb = c.rgb * _DiffuseScale;
				//c.a = c.a * _AlphaScale;
				
				
				half4 light = tex2D (_LightTex, input.uv_MainLightTex.zw) * _LightColor * _LightScale;
				light.rgb = light.rgb * tex2D(_MaskTex, input.uv_MaskAddTex.xy).a * _AlphaScale;
				
				float4 add = 2.0f * input.color * _TintColor * tex2D(_AdditiveTex, input.uv_MaskAddTex.zw);
				add.a *= tex2D(_AdditiveMaskTex, input.uv_MaskAddTex2.xy).r;
				c.rgb += light.a * light.rgb + add.rgb * add.a;
				
				c.a *= _AlphaScale;
				
				return c;
			}
			ENDCG
		}
	}
}
