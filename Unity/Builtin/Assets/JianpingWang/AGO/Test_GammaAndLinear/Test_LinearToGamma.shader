Shader "JianpingWang/Test_LinearToGamma"
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

                tex.rgb = pow(tex.rgb, 0.45);     //Test_LinearToGamma    //方案一
                // tex.rgb = tex.rgb/(half3(0.237,0.237,0.237)+tex.rgb)*1.13;    //hack  待深入测试

                // half r  = (tex.r <= 0.00031308) ? tex.r * 12.92 : pow(tex.r, (1/2.4)) * 1.055 - 0.055;           /Test_LinearToGamma   //方案二
                // half g  = (tex.g <= 0.00031308) ? tex.g * 12.92 : pow(tex.g, (1/2.4)) * 1.055 - 0.055;
                // half b  = (tex.b <= 0.00031308) ? tex.b * 12.92 : pow(tex.b, (1/2.4)) * 1.055 - 0.055;
                // tex.rgb = half3(r,g,b);

                return tex;
            }


            ENDCG
        }
    }
}