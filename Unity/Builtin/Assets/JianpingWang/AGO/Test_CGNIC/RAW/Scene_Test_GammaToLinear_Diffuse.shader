Shader "JianpingWang/MainDraw/Scene_Test_GammaToLinear_Diffuse"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
    }
    SubShader
    {
        Pass 
        {
            Tags {"LightMode" = "ForwardBase" "RenderType"="Opaque"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag 

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
            #pragma multi_compile SHADOWS_SHADOWMASK;
            #pragma multi_compile_fwdbase
            #pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
            // #include "DodFog.cginc"
            // #include "DodScenePbsCore.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float2 texcoord2 : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvLM : TEXCOORD4;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                // DOD_FOG_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.texcoord;
                o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                // DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
                return o;
            }

            half4 frag ( v2f i ) : SV_TARGET
            {
                half4 tex = tex2D(_MainTex, i.uv);
                tex.rgb = pow(tex.rgb, 2.2);  //GammaToLinear 
                half3 albedo = tex.rgb;


                half3 worldNormal = normalize(i.worldNormal);
				half3 worldPos = normalize(i.worldPos);
				half3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				half3 ndl = max(0.0,dot(worldNormal,worldLightDir)); 

                
                half4 Lm;
                Lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
                // Lm = pow(Lm, 2.2);
                
                Lm *= Lm;
				fixed backatten = UnitySampleBakedOcclusion(i.uvLM,i.worldPos);
                
                
                tex.rgb *= Lm;
                tex.rgb = tex.rgb + albedo * _LightColor0.rgb * ndl * backatten;
                tex.rgb *= 3;
                // tex.rgb = lerp(tex.rgb, tex.rgb * tex.rgb, 0.1);
                
                // tex.rgb = pow(tex.rgb, 0.45);
                tex.rgb = tex.rgb/(half3(0.237,0.237,0.237)+tex.rgb)*1.065;   //LinearToGamma
                
                // DOD_APPLY_FOG(i.fogCoord, i.worldPos, tex.rgb);

                return tex;
            }


            ENDCG
        }
    }
}