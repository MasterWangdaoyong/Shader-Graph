Shader "MMO/Actor/TestActorEye" {
Properties {
	[Toggle(DIFFUSE_ON)]_DiffuseOpen("Diffuse open", float) = 1
	[Toggle(SPEC_ON)]_SpecularOpen("Specular open", float) = 1
	[Toggle(REFLECT_MAP_ON)]_ReflectOn("Reflect open", float) = 1
	[Toggle(ENVLIGHT_ON)]_ENVLIGHT_ON("Env light open", float) = 1
	
	_MainColor("Eye Color (A-Color blend)", Color) = (0,0,0,1)
	_MainTex ("Base (RGB)", 2D) = "grey" {}
	
	_SpecTex("Specluar Map", 2D) = "white"{}
	_EyeColorMask("Eye Color Map", 2D) = "white"{}
	_ReflectTex("Reflect Map", 2D) = "white"{}

	_ReflectMatcap("Reflect Matcap", 2D) = "black"{}

	_DiffScale("Diffuse Scale", Range(0, 5)) = 1
	_DiffWrap("Diffuse Wrap", Range(0, 2)) = 1
	_SpecScale("Specular Scale", Range(0, 10)) = 1
	_SpecOffsetX("Specluar offsetX", Range(-2, 2)) = 0
	_SpecOffsetY("Specluar offsetY", Range(-2, 2)) = 0
	_ReflScale ("Reflect Scale", Range(0, 10)) = 1
	_ShadowScale("Shadow Scale", Range(0, 1)) = 1

}

SubShader 
{ 
	Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}

	Pass
	{
		Name "FORWARD" 
		Tags { "LightMode" = "ForwardBase" }
		
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment frag
		
		#pragma shader_feature DIFFUSE_ON
		#pragma shader_feature SPEC_ON
		#pragma shader_feature REFLECT_MAP_ON
		#pragma shader_feature ENVLIGHT_ON
		
		#pragma multi_compile_fwdbase nolightmap nodynlightmap nodirlightmap noshadowmask
		
		#include "DodPBSUtils.cginc"

		struct a2v{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f{
			float4 pos : SV_POSITION;
			float3 wPos : TEXCOORD0;
			half3 wNormal : TEXCOORD1;
			half2 uv : TEXCOORD2;
			half2 reflUV : TEXCOORD3;

		};

		fixed4 _MainColor;
		sampler2D _MainTex;
		float4 _MainTex_ST;

		sampler2D _SpecTex;
		sampler2D _EyeColorMask;
		sampler2D _ReflectTex;

		sampler2D _ReflectMatcap;

		float _DiffScale;
		float _DiffWrap;
		float _SpecScale;
		float _ReflScale;
		float _ShadowScale;

		float _SpecOffsetX;
		float _SpecOffsetY;

		v2f vert(a2v v)
		{
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

			o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			o.wNormal = UnityObjectToWorldNormal(v.normal);

			float3 normalDir = normalize ( v.normal);
			o.reflUV = float2(dot(normalize( UNITY_MATRIX_IT_MV[0].xyz), normalDir), dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalDir)) * 0.5 + 0.5;
			return o;
		}

		fixed4 frag(v2f i) : SV_TARGET
		{
			half3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
			half3 viewDir = (UnityWorldSpaceViewDir(i.wPos));
			half3 halfDir = normalize(viewDir + lightDir);
			half3 normalDir = normalize(i.wNormal);

			half NdotL = saturate(dot(normalDir, lightDir));
			half NdotH = saturate(dot(normalDir, halfDir));
			half VdotL = dot(viewDir, lightDir);
			
			fixed4 albedo = tex2D(_MainTex, i.uv);
			fixed4 speMask = tex2D(_SpecTex, i.uv);
			fixed4 eyeMask = tex2D(_EyeColorMask, i.uv);
			fixed4 relMask = tex2D(_ReflectTex, i.uv);

			half3 ambient = DOD_LIGHTMODEL_AMBIENT(normalDir) * albedo;

			float wrap = (NdotL + _DiffWrap) / (1 + _DiffWrap);
			float diff = LIGHTCOLOR.rgb * wrap * _DiffScale;

			fixed3 diffColor = diff * albedo * (1 - eyeMask);
			fixed3 eyeColor = lerp(diff * albedo, _MainColor, _MainColor.a) * eyeMask;
			diffColor = diffColor + eyeColor;

			float2 uv = i.reflUV + float2(_SpecOffsetX, _SpecOffsetY) * 0.1;
			fixed4 spec = tex2D(_ReflectMatcap, uv) * speMask;
			fixed3 specColor =  spec.a * _SpecScale;
				
			fixed4 reflMask = tex2D(_ReflectMatcap, i.reflUV);
			half3 reflColor = reflMask.rgb * relMask * _ReflScale;
			specColor += reflColor;

			fixed4 finalColor = 0;
			finalColor.rgb = diffColor + specColor + ambient;
			finalColor.a = albedo.a;

			return finalColor;
		}
		ENDCG
	}
}
}

