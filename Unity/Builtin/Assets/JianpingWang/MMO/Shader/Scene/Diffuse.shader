// 时间：20200813 
// 参考：Legacy Shaders/Transparent/Cutout/VertexLit 
// 功能：Gamma 空间下的 Linear渲染框架(Lightmap 效果）

Shader "JianpingWang/MMO/Scene/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            //fog
            #include "DodFog.cginc"
            #pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR
            #pragma multi_compile _ DOD_SUN_ON

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float3 normal : NORMAL;                  
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uvLM : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 worldNormal : TEXCOORD3;
                SHADOW_COORDS(5) 
                DOD_FOG_COORDS(6)     //fog
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                o.uvLM = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);       
                TRANSFER_SHADOW(o)    
                DOD_TRANSFER_FOG(o.fogCoord, v.vertex); //fog            
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 worldPos = normalize(i.worldPos);
                half3 worldNormal = normalize(i.worldNormal);
                half3 worldLight = UnityWorldSpaceLightDir(worldPos);

                half ndl = dot(worldLight, worldNormal);
                
                //lightmap
                half4 lightmap = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
                half4 bakedColor = half4(DecodeLightmap(lightmap), 1.0);
                bakedColor.rgb = GammaToLinearSpace(bakedColor.rgb);  //如果管线是gamma的那么，在解压时使用转线性
                //shadow
                fixed backatten = UnitySampleBakedOcclusion(i.uvLM, worldPos);
                fixed shadowatten = SHADOW_ATTENUATION(i);
                shadowatten = clamp(shadowatten, 0.5, 1); //阴影，但会跟shadowmask溶合（欠佳）
                //color blend
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = GammaToLinearSpace(col.rgb);  //贴图是gamma的，计算前使用转线性
                col.rgb = col.rgb * bakedColor.rgb * clamp(backatten, 0.6, 0.95) + col.rgb * (_LightColor0.rgb * 2) * max(0, ndl) * backatten;
                //烘焙间接光 + 直接光                                                    //特别注意 _LightColor0 * 2 的使用；整体思路：加重对比度，亮部提亮（太阳光，实时光部分），暗部压暗（增加阴影，并clamp控制阴影的强度），并采用线性计算 20200812
                
                col.rgb *= shadowatten;    //阴影，但会跟shadowmask溶合（欠佳的问题，在这解决）                                        
                
                DOD_APPLY_FOG(i.fogCoord, i.worldPos, col.rgb); //fog
                col.rgb = LinearToGammaSpace(col.rgb);  //所有计算完成后，转回gamma                  
                return col;
            }
            ENDCG
        }
    }
}


