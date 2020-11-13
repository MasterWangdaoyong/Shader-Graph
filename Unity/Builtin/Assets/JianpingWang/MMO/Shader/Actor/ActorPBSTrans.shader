Shader "Dodjoy/Actor/ActorTransPBR" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpTex("Normal", 2D) = "bump" {}
		_RoughTex("Rough", 2D) = "white"{}
		_Smoothness("Smoothness", Range(0, 1)) = 0
	}

	SubShader{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		Cull off
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha:fade exclude_path:prepass noshadowmask nolightmap nodynlightmap nodirlightmap nometa novertexlights nolppv noforwardadd 

		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D _RoughTex;
		half _Smoothness;

		struct Input {
			float2 uv_MainTex;
		};

		void surf(Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;

			o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex));
			o.Smoothness = tex2D(_RoughTex, IN.uv_MainTex).r * _Smoothness;
		}
		ENDCG
	}
}

