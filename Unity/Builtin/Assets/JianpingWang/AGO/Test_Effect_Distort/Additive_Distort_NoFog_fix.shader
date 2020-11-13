//JianpingWang      //20200806


Shader "Dodjoy/Effect/Additive_Distort_NoFog_fix" 
{
    Properties 
    {
        _TintColor ("Tint Color(RGB)", Color) = (1,1,1,1)
        _MainTex ("MainTex(RGBA)", 2D) = "white" {}
        _DisortTex ("niuqu_tex(RGB)", 2D) = "white" {}
        _DistortStrangth ("QD", Float ) = 0.05
        _GLOW ("GLOW", Float ) = 1
        _SpeedV ("V速度", Float ) = 0
        _SpeedU ("U速度", Float ) = 0

        
        _DisortMaskTex ("niuqu_tex_Mask(R)", 2D) = "white" {}
        _DisortTexMaskStrangth ("niuqu_tex_MaskStrangth", Float ) = 0.05
    }
    SubShader 
    {
        Tags 
        {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
		
		Fog {Mode Off}
		
        LOD 100
        Pass 
        {
            Name "FORWARD"
            Tags {   "LightMode"="ForwardBase"    }

            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbase

            uniform sampler2D _MainTex; 
            uniform float4 _MainTex_ST;

            uniform float4 _TintColor;

            uniform sampler2D _DisortTex; 
            uniform float4 _DisortTex_ST;

            uniform float _DistortStrangth;
            uniform float _GLOW;
            uniform float _SpeedV;
            uniform float _SpeedU;

            sampler2D _DisortMaskTex;
            float4 _DisortMaskTex_ST;
            float _DisortTexMaskStrangth;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }

            fixed4 frag(VertexOutput i) : COLOR 
            {
                half t = _Time.y;

                half4 mask = tex2D(_DisortMaskTex, i.uv1);

				half2 distortUV = (half2((_SpeedU*t),(_SpeedV*t))+i.uv0);
				half4 distortColor = tex2D(_DisortTex,TRANSFORM_TEX(distortUV, _DisortTex));
				half2 mainUV = ((distortColor.r*_DistortStrangth * mask.r)+i.uv0);

				half4 color = tex2D(_MainTex,TRANSFORM_TEX(mainUV, _MainTex));
				half3 emissive = (((2.0*distortColor.rgb) * color.rgb) * (color.rgb * i.vertexColor.rgb * (_TintColor.rgb * _GLOW) * color.a * i.vertexColor.a));

                emissive = clamp(emissive * (1 - (1-emissive) * _DisortTexMaskStrangth), 0, 2);

                return fixed4(emissive , color.a);

            }

            ENDCG
        }
    }

}
