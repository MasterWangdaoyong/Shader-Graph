Shader "JianpingWang/Transparent-AlphaBlend"      //存在瑕疵   20191225
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex("Mask(R-Specular, G-Emission)", 2D) = "black" {}
		_Specular("Specular Color", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0, 256.0)) = 8.0
		_SpecularScale("Specular Scale", Float) = 1		
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
					
		Pass{
			Tags { "LightMode" = "ForwardBase"}
			
			Cull Front
			ZWrite On

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"			
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			struct a2v 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target 
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));				
				fixed4 texColor = tex2D(_MainTex, i.uv);				
				fixed3 albedo = texColor.rgb * _Color.rgb;				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;			
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				return fixed4(ambient + diffuse, texColor.a);
			}
			
			ENDCG


		}

        Pass
        {
			Tags{"LightMde" = "ForwardBase"}
			
			Cull Back 
			ZWrite On
			Blend  SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
						
			#pragma multi_compile __ LIGHTMAP_ON

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;

				#ifdef LIGHTMAP_ON
					float2 uvLM : TEXCOORD1;
				#endif
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
               
                float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD2;
				float3 worldPos : TEXCOORD3;

				#ifdef LIGHTMAP_ON
					float2 uvLM : TEXCOORD4;
				#endif
				
            };

			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _MaskTex;
			fixed4 _Specular;
			half _Gloss;
			half _SpecularScale;
			
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				#ifdef LIGHTMAP_ON
					o.uvLM = v.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				half3 worldPos = normalize(i.worldPos);
				half3 worldNormal = normalize(i.worldNormal);
				half3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				half3 halfDir = normalize(viewDir + worldLightDir);
				
                fixed4 col = tex2D(_MainTex, i.uv);				
				fixed4 mask = tex2D(_MaskTex, i.uv);

				fixed3 finalColor = 1.0;
				
				#ifdef LIGHTMAP_ON
					fixed shadowMaskAtten = UnitySampleBakedOcclusion(i.uvLM, worldPos);	
					fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM)));
					finalColor = col.rgb * (lm / 0.85);					
				#else					
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * col.rgb;
					finalColor =  col.rgb * max(0, dot(worldNormal, worldLightDir)) * _LightColor0.rgb + ambient;
				#endif

				finalColor += mask.g * col.rgb;				
				finalColor += _LightColor0 * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss) * _SpecularScale * mask.r;				
                
                return fixed4(finalColor * _Color.rgb, col.a);
            }
            ENDCG
        }
    }
}
