
Shader "Dodjoy/Effect/AdditiveEx" {
    Properties {
        _MainTex ("particle tex", 2D) = "white" {}
        _UOffset ("UOffset", Range(-1, 1)) = 0.2239312
        _MaskTex ("mask tex", 2D) = "white" {}
        _xuanzhuan ("xuanzhuan", Range(-10, 10)) = -10
        [HDR]_TintColor ("Color", Color) = (0.5,0.5,0.5,1)
		_USpeed("U Speed", float) = 0
		_VSpeed("V Speed", float) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma multi_compile_fog
            #pragma target 3.0

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;
            uniform float _UOffset;
            uniform sampler2D _MaskTex; 
            uniform float4 _MaskTex_ST;
            uniform float _xuanzhuan;
            uniform float4 _TintColor;

			float _USpeed;
			float _VSpeed;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv = v.texcoord0 + frac(half2(_USpeed, _VSpeed) * _Time.y);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                float4 mask = tex2D(_MaskTex,TRANSFORM_TEX(i.uv, _MaskTex));
                float angle = (mask.r * _xuanzhuan);
                float cosVal = cos(angle);
                float sinVal = sin(angle);

                float2 offset = float2(0.5,0.5);
                float2 uv = mul(i.uv - offset, float2x2(cosVal, -sinVal, sinVal, cosVal)) + offset;
                uv = uv*2.0 - 1.0;
                uv = float2(length(uv) + _UOffset, (atan2(uv.g, uv.r)/6.28318530718) + 0.5);

                float4 color = tex2D(_MainTex,TRANSFORM_TEX(uv, _MainTex));
                color.rgb = (color.rgb * mask.r * _TintColor.rgb);
                color.a = 1;
                UNITY_APPLY_FOG(i.fogCoord, color);
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
