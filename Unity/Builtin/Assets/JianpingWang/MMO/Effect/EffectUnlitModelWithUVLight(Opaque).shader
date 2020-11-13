// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dodjoy/Effect/EffectUnlitModelWithUVLight(Opaque)" {

	Properties {
		_Color ("Base Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DiffuseScale ("Diffuse Scale", float) = 1.0
		_LightColor("Light Color", Color) = (1,1,1,1)
		_LightTex ("LightTex (RGB)", 2D) = "white" {}
		_LightScale ("Light Scale", float) = 1.0
		_LightMaskTex("Light Mask Tex", 2D) = "white" {}
		_LightUSpeed("U speed ", float) = 0.1
		_LightVSpeed("V speed", float) = 0.1	
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
	}
	
	SubShader {
		
		Tags {
            "RenderType"="Opaque"
			"Queue" = "Geometry"
		}
		
		Pass{		

			Lighting Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;

			half  _DiffuseScale;
			half4 _Color;
	        uniform float4 _MainTex_ST;
			
			sampler2D _LightTex;

			half  _LightScale;
			half4 _LightColor;

			sampler2D _LightMaskTex;
	        uniform float4 _LightMaskTex_ST;

	        uniform float4 _LightTex_ST;
	        
			uniform float _LightUSpeed;
			uniform float _LightVSpeed;

			uniform float _AlphaScale;

			struct v2f {
				float4 pos : POSITION;
				fixed4 color : COLOR;
				float4 uv_MainLightTex: TEXCOORD0;
				float2 uv_MaskAddTex: TEXCOORD1;
			};

			v2f vert(appdata_full v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);								
				o.color = v.color;
				
				o.uv_MainLightTex.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv_MainLightTex.zw = TRANSFORM_TEX(v.texcoord, _LightTex);
				o.uv_MaskAddTex.xy = TRANSFORM_TEX(v.texcoord, _LightMaskTex);
				
				return o;
			}

			float4 frag(v2f input):Color
			{ 
				half4 c = tex2D (_MainTex, input.uv_MainLightTex.xy) * _Color;
				c.rgb = c.rgb * _DiffuseScale;
			
                float time = _Time.y;
				half2 lightUV = half2(_LightUSpeed * time, _LightVSpeed * time) + input.uv_MainLightTex.zw;	

				half4 light = tex2D (_LightTex, lightUV) * _LightColor * _LightScale;
				c.rgb += tex2D(_LightMaskTex, input.uv_MaskAddTex.xy).a * light.rgb;
				//c.rgb += light.a * light.rgb;

				return c;
			}
			ENDCG
		}
	}
}
