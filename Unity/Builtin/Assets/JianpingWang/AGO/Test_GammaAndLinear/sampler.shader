Shader "JianpingWang/sampler"
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

            fixed4 frag ( v2f i ) : SV_TARGET
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                return tex;
            }


            ENDCG
        }
    }
}

// SD所得
// //LinearToSrgb
// half3 tex;
// input = tex.r;  //分别都等于他，多次调用   //精准，最高消耗，影视所用，或者是贴图成品静态使用
// input = tex.g;
// input = tex.b;
// half r  = (tex.r <= 0.00031308) ? tex.r * 12.92 : pow(tex.r, (1/2.4)) * 1.055 - 0.055;
// half3 LinearToSrgb = half3 (r, g, b);


// //SrgbToLinear
// half3 tex;
// input = tex.r;  //分别都等于他，多次调用   //精准，最高消耗，影视所用，或者是贴图成品静态使用
// input = tex.g;
// input = tex.b;
// half if(input <= 0.04045) ? input * (1/12.92) : pow(((input + 0.055) / 1.055), 2.4);
// half3 SrgbToLinear = half3 (lu, lu, lu);


//float3 RGB = sRGB *（sRGB *（sRGB * 0.305306011 + 0.682171111）+ 0.012522878）；