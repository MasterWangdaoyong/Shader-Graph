Shader "Dodjoy/Effect/Diffuse_HighLight_Alpha" 
{
	Properties 
	{
		_Ambient ("Ambient Color", Color) = (1, 1, 1, 1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_HightLightShift("HL On or Off", Float) = 0.0
		_HighLightColor("Actor Hight Light", Vector) = (2.0,2.0,2.0,1.0)
		_DiffFactor("Factor for Lighten More", Float) = 1.0
		_AlphaFactor("Factor for Alpha Blending", Float) = 1.0
		_Shininess("Shininess", Range(8.0, 128.0)) = 16.0
	}

	SubShader 
	{
		Tags 
		{
			"RenderType"="Transparent"
			"Queue"="Transparent"
		}
		LOD 20

		Pass{
		ZWrite On
        ColorMask 0
		Cull Back
		}


		CGPROGRAM
		//#pragma surface surf Lambert addshadow alpha
		#pragma surface surf XSpecular addshadow alpha noambient

		sampler2D _MainTex;
		uniform float _HightLightShift;
		uniform float4 _HighLightColor;

		uniform float4 _ActorPos;
		float _DiffFactor;
		float _AlphaFactor;
		half _Shininess;
		fixed4 _Ambient;

		struct Input 
		{
			float2 uv_MainTex;
		};

		half4 LightingXSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) 
		{
			half3 h = normalize (lightDir + viewDir);
			half diff = max (0, dot (s.Normal, lightDir));
			half nh = max (0, dot (s.Normal, h));
			half spec = pow (nh, 1) * s.Specular;
			half4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2) + s.Albedo*_Ambient;
			c.a = s.Alpha;
			
			return c;
      	}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			// base texture
			fixed4 cBase = tex2D(_MainTex, IN.uv_MainTex);

			// high light color
			fixed3 cHightLight = cBase.rgb * _HighLightColor.rgb * _HightLightShift;

			o.Albedo = ( cBase.rgb + cHightLight ) * _DiffFactor;
			o.Alpha = cBase.a * _AlphaFactor;
		}
		ENDCG
	}
	
	Fallback "Mobile/Diffuse"
}
