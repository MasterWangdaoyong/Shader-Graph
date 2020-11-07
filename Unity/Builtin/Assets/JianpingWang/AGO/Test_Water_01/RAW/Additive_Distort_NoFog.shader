// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Dodjoy/Effect/Additive_Distort_NoFog" {
    Properties {
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _MainTex ("MainTex", 2D) = "white" {}
        _DisortTex ("niuqu_tex", 2D) = "white" {}
        _DistortStrangth ("QD", Float ) = 0.05
        _GLOW ("GLOW", Float ) = 1
        _SpeedV ("V速度", Float ) = 0
        _SpeedU ("U速度", Float ) = 0
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
		
		Fog {Mode Off}
		
        LOD 100
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "UnityUI.cginc"

            #pragma multi_compile_fwdbase
			#pragma multi_compile __ UNITY_UI_CLIP_RECT

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;

            uniform float4 _TintColor;
			float4 _ClipRect;

            uniform sampler2D _DisortTex; 
            uniform float4 _DisortTex_ST;

            uniform float _DistortStrangth;
            uniform float _GLOW;
            uniform float _SpeedV;
            uniform float _SpeedU;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
				#ifdef UNITY_UI_CLIP_RECT
                float4 worldPosition : TEXCOORD1;
                #endif
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
				#ifdef UNITY_UI_CLIP_RECT
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                #endif
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR 
            {
                half t = _Time.y;
				half2 distortUV = (half2((_SpeedU*t),(_SpeedV*t))+i.uv0);
				half4 distortColor = tex2D(_DisortTex,TRANSFORM_TEX(distortUV, _DisortTex));
				half2 mainUV = ((distortColor.r*_DistortStrangth)+i.uv0);
				half4 color = tex2D(_MainTex,TRANSFORM_TEX(mainUV, _MainTex));
				half3 emissive = (((2.0*distortColor.rgb)*color.rgb)*(color.rgb*i.vertexColor.rgb*(_TintColor.rgb*_GLOW)*color.a*i.vertexColor.a));
				half3 finalColor = emissive;
				#ifdef UNITY_UI_CLIP_RECT
                finalColor *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif
                return fixed4(finalColor, color.a);
            }

            ENDCG
        }
    }

}
