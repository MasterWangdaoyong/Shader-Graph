// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Dodjoy/Actor/ActorTransPBR" {
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpTex("Normal", 2D) = "bump" {}
		//_MatelTex("Matel Tex", 2D) = "white" {}
		_RoughTex("Rough Tex", 2D) = "white"{}
		_Smoothness("Smoothness", Range(0, 1)) = 0
		_Transparency("Transparency", Range(0, 1)) = 0.5
	}

		SubShader{
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

			
			//仅写入深度
			Pass{
				ZWrite On
				ColorMask 0
			}
			
			//正常渲染
			Pass{
				Tags{"LightMode"="ForwardBase"}
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha
				Cull off
			
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				#define PI 3.14159265359

				struct a2v {
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
				};

				struct v2f{
					float4 pos : SV_POSITION;
					float2 uv0 : TEXCOORD0;
					float4 worldPos : TEXCOORD1;
					float3 normalDir : TEXCOORD2;
					float3 tangentDir : TEXCOORD3;
					float3 bitangentDir : TEXCOORD4;
					LIGHTING_COORDS(5,6)
				};

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				//sampler2D _MatelTex;
				sampler2D _RoughTex;
				float _Smoothness;
				float _Transparency;

				v2f vert(a2v v)
				{
					v2f o = (v2f)0;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv0 = TRANSFORM_TEX(v.uv, _MainTex);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex);

					o.normalDir = UnityObjectToWorldNormal(v.normal);
					o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
					o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

					TRANSFER_VERTEX_TO_FRAGMENT(o);

					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

					float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
					float3 normalLocal = UnpackNormal(tex2D(_BumpTex, i.uv0));
					float3 normalDir = normalize(mul(normalLocal, tangentTransform));

					//fixed4 matelTex = tex2D(_MatelTex, i.uv0);
					//float matellic = matelTex.r *  _Smoothness;

					fixed4 roughTex = tex2D(_RoughTex, i.uv0);
					float roughness = roughTex.r;

					float matellic = (1 - roughness) * _Smoothness;

					//float f0 = matelTex.r;
					float f0 = 1.0;
					float3 h = normalize(lightDir + viewDir);
					float a = roughness * roughness;
					float a2 = a * a;

					float NoL = saturate(dot(normalDir, lightDir));
					float NoV = saturate(dot(normalDir, viewDir));
					float NoH = saturate(dot(normalDir, h));
					float VoH = saturate(dot(viewDir, h));

					float3 atten = LIGHT_ATTENUATION(i) * _LightColor0.xyz;
					fixed4 albedo = tex2D(_MainTex, i.uv0);

					//diffuse
					float3 directDiff = (NoL*0.5 +0.5) * atten * _Color * 2.0;
					float3 indirectDiff = UNITY_LIGHTMODEL_AMBIENT.rgb;
					float3 diffuse = (directDiff + indirectDiff) * albedo * (1 - matellic);

					//specular
					float sqrtD = rcp(NoH * NoH * (a2 - 1) + 1);
					float D = a2 * sqrtD * sqrtD / 4;
					float k = (a2 + 1) * (a2 + 1) / 8;

					//G(l,v,h) / (n·l)(n·v)
					float GV = (NoV * (1 - k) + k);
					float GL = (NoL * (1 - k) + k);

					//F(v,h)
					float f = f0 + (1 - f0) * pow(2, (-5.55473 * VoH - 6.98316) * VoH);
					
					fixed3 specularTerm = D * f * rcp(GV * GL);
					fixed3 specular = albedo * atten * (1 / PI + specularTerm) * NoL * matellic;

					fixed4 finalColor = (fixed4)0;
					finalColor.rgb = diffuse + specular;
					finalColor.a = albedo.a * _Transparency;
					return finalColor;
				}
				ENDCG
			}
		}
}