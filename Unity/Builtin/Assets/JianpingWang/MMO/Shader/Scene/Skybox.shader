
Shader "JianpingWang/MMO/Scene/Skybox" 
{
    Properties 
    {      
        [NoScaleOffset] _Tex ("Cubemap   (HDR)", Cube) = "grey" {}
        _Tint("Tint Color", color) = (0.5, 0.5, 0.5, 1.0)
        _Exposure("Exposure", range(0, 4)) = 1.0    
    }

    SubShader 
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        Pass 
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag      

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR 
            #define FOG_SKY_BOX            
            #pragma multi_compile _ DOD_SUN_ON 
            #include "DodFog.cginc"

            samplerCUBE _Tex;
            half4 _Tex_HDR;
            half4 _Tint;
            half _Exposure;      
        
            struct appdata_t 
            {
                float4 vertex : POSITION;
            };

            struct v2f 
            {
                float4 pos : SV_POSITION;
                float3 vertex : TEXCOORD0;            
                float4 worldPos : TEXCOORD1;
                DOD_FOG_COORDS(3)     
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.vertex = v.vertex.xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                DOD_TRANSFER_FOG(o.fogCoord, v.vertex);

                return o;
            }


            

            fixed4 frag (v2f i) : SV_Target
            {
                half4 tex = texCUBE (_Tex, i.vertex);
                half3 c = DecodeHDR (tex, _Tex_HDR);
                c = c * c;
                c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
                c *= _Exposure;   
                            

                
                #if defined(DOD_SUN_ON)	                    
                    c = skyboxFogAndSun(i.vertex, i.worldPos, c);
                #endif


                
                DOD_APPLY_FOG(i.fogCoord, i.worldPos, c);
                c = LinearToGamma(c);

                return half4(c, 1);
            }
            ENDCG
        }
    }
}
