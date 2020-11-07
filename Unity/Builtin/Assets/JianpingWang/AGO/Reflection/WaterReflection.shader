//正确的反射方案 //Jianpingwang 20200908
Shader "JianpingWang/Reflection" 
{
    Properties 
    {
        _Tex("tex", 2D) = "gray" {}
        _ReflectionsIntensity ("ReflectionsIntensity", Range(0, 1)) = 0.3
        _ReflectionTex ("ReflectionTex", 2D) = "white" {}
        _BlurSize ("Blur Size", Range(0, 0.5)) = 0.07
    }
    SubShader 
    {
        Tags {  "IgnoreProjector"="True"   "Queue"="Transparent"  "RenderType"="Transparent"  "PreviewType"="Plane" }

        GrabPass{ "Refraction" }

        Pass 
        {
            // Name "FORWARD"
            Tags { "LightMode"="ForwardBase"  }
            // Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x n3ds wiiu 
            #pragma target 3.0

            uniform sampler2D _ReflectionTex; uniform float4 _ReflectionTex_ST;
            float _ReflectionsIntensity;
            sampler2D _Tex;
            float _BlurSize;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 screenPos : TEXCOORD3;
                float4 projPos : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
 
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);

                COMPUTE_EYEDEPTH(o.projPos.z);
                o.screenPos = o.pos;
                
                return o;
            }
            float4 frag(VertexOutput i) : COLOR
             {
                float4 texcolor = tex2D(_Tex, i.uv0);

                #if UNITY_UV_STARTS_AT_TOP
                    float grabSign = -_ProjectionParams.x;
                #else
                    float grabSign = _ProjectionParams.x;
                #endif
                i.screenPos.xy = i.screenPos.xy / i.screenPos.w;
                i.screenPos.y *= _ProjectionParams.x;
                float2 sceneUVs = float2(1,grabSign) * i.screenPos.xy * 0.5 + 0.5;

                //-------- Blur
                float weight[3] = {0.4026, 0.2442, 0.0545};
                half2 uv[5];
                uv[0] = sceneUVs;
                uv[1] = sceneUVs + float2(0.0, _ReflectionTex_ST.y * 0.1) * _BlurSize;
                uv[2] = sceneUVs - float2(0.0, _ReflectionTex_ST.y * 0.1) * _BlurSize;
                uv[3] = sceneUVs + float2(0.0, _ReflectionTex_ST.y * 0.2) * _BlurSize;
                uv[4] = sceneUVs - float2(0.0, _ReflectionTex_ST.y * 0.2) * _BlurSize;
                half2 uv2[5];
                uv2[0] = sceneUVs;
                uv2[1] = sceneUVs + float2(_ReflectionTex_ST.x * 0.05, 0.0) * _BlurSize;
                uv2[2] = sceneUVs - float2(_ReflectionTex_ST.x * 0.05, 0.0) * _BlurSize;
                uv2[3] = sceneUVs + float2(_ReflectionTex_ST.x * 0.1, 0.0) * _BlurSize;
                uv2[4] = sceneUVs - float2(_ReflectionTex_ST.x * 0.1, 0.0) * _BlurSize;



                fixed3 finalRGBA = tex2D(_ReflectionTex, sceneUVs) * weight[0];

                for (int it = 1; it < 3; ++it) 
                {
                    finalRGBA += tex2D(_ReflectionTex, uv[it*2-1]).rgb * weight[it];
                    finalRGBA += tex2D(_ReflectionTex, uv2[it*2-1]).rgb * weight[it];
                    finalRGBA += tex2D(_ReflectionTex, uv[it*2]).rgb * weight[it];
                    finalRGBA += tex2D(_ReflectionTex, uv2[it*2]).rgb * weight[it];
                }      

                finalRGBA = clamp(finalRGBA, 0.3, 1);          
                //--------
                

                finalRGBA = texcolor.rgb + texcolor.rgb * finalRGBA * _ReflectionsIntensity;

                return fixed4(finalRGBA, 1);
            }
            ENDCG
        }
    }
}
