Shader "JianpingWang/MMO/Scene/Diffuse"
{
    Properties
    {
        _MainTex("Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"			
            #include "Lighting.cginc"

            #include "DodFog.cginc"
            #pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR
            #pragma multi_compile _ DOD_SUN_ON

            

            sampler2D _MainTex;
            half4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 light : TEXCOORD2;
                DOD_FOG_COORDS(6)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.light = max(0, dot(UnityObjectToWorldNormal(v.normal), UnityWorldSpaceLightDir(o.worldPos)));
                

                DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                
                col.rgb = _LightColor0.rgb * i.light * col.rgb + col.rgb;

                DOD_APPLY_FOG(i.fogCoord, i.worldPos, col.rgb);
                return col;
            }
            ENDCG
        }
    }
}
