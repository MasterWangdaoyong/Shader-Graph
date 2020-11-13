Shader "JianpingWang/Test_GammaToLinear"
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
            // #include "DodScenePbsCore.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            half4 frag ( v2f i ) : SV_TARGET
            {
                half4 tex = tex2D(_MainTex, i.uv);
                
                tex.rgb = pow(tex.rgb, 2.2);  //GammaToLinear 方案一

                // half r = (tex.r <= 0.04045) ? tex.r * (1/12.92) : pow(((tex.r + 0.055) / 1.055), 2.4);  //GammaToLinear  //方案二   从SD中学习
                // half g = (tex.g <= 0.04045) ? tex.g * (1/12.92) : pow(((tex.g + 0.055) / 1.055), 2.4);
                // half b = (tex.b <= 0.04045) ? tex.b * (1/12.92) : pow(((tex.b + 0.055) / 1.055), 2.4);
                // tex.rgb = half3(r,g,b);

                return tex;
            }


            ENDCG
        }
    }
}