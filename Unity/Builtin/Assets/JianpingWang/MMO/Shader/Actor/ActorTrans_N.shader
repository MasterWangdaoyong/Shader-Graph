Shader "MMO/Actor/ActorTrans_N"
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpTex("Normal", 2D) = "bump" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecularScale("Specular Scale", Range(0, 10)) = 1
		_Gloss("Gloss", Range(8, 256)) = 8
		_Transparency("Transparency", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+1" "IgnoreProjector"="True" }

		//仅仅写入深度缓冲
		Pass
		{
			ZWrite On
			ColorMask 0
		}

		//正常渲染
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
			Cull off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
				float3 bitangentDir : TEXCOORD4;
               
            };
			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpTex;
			fixed4 _SpecularColor;
			float _SpecularScale;
			float _Gloss;

			fixed _Transparency;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0)).xyz);
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 halfDir = normalize(lightDir + viewDir);

				float3x3 tangentTransform = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
				float3 normalLocal = UnpackNormal(tex2D(_BumpTex, i.uv));
				float3 normalDir = normalize(mul(normalLocal, tangentTransform));

				float NoL = saturate(dot(normalDir, lightDir));
				float NoH = saturate(dot(normalDir, halfDir));

				fixed4 albedo = tex2D(_MainTex, i.uv);

				float3 diffuse = (NoL * 0.5 + 0.5) * _LightColor0.rgb * albedo * _Color.rgb * 2.0;

				float3 specular = pow(NoH, _Gloss) * _SpecularScale * _LightColor0.rgb * _SpecularColor.rgb;
				
				fixed4 finalColor = (fixed4)1.0;
				finalColor.rgb = diffuse + specular;
				finalColor.a = albedo.a * _Transparency;

                return finalColor;
            }
            ENDCG
        }
    }
}
