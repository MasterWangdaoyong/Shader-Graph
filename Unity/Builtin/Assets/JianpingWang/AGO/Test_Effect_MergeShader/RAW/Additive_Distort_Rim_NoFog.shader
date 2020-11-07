
Shader "Dodjoy/Effect/Additive_Distort_Rim_NoFog"   //合并两个shader到一个shader，节省资源和性能开支  //JianpingWang //20200328
{
    Properties 
    {   
        [Header(Base)]
        _TintColor ("TintColor(RGB)", Color) = (1,1,1,1)
        _MainTex ("MainTex(RGBA)", 2D) = "white" {}
        _DisortTex ("niuqu_tex(RGB)", 2D) = "white" {}
        [Space(10)][Header(TimeControl)]
        _DistortStrangth ("QD", Float ) = 0.05
        _GLOW ("GLOW", Float ) = 1
        _SpeedV ("V速度", Float ) = 0
        _SpeedU ("U速度", Float ) = 0
        [Space(10)][Header(Rim)]
        _RimBase ("RimBase(RGB)", Color) = (1,1,1,1)
        _RimColor ("RimColor(RGB)", Color) = (1, 1, 1, 1)
        _RimWidth ("RimWidth", Float) = 0.7
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
            Tags 
            {
                "LightMode"="ForwardBase"
            }

            Lighting Off
            // Blend One One
            // Blend One OneMinusSrcAlpha   
            // Blend SrcAlpha One
            // Cull Off
            // ZWrite Off
            
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

            uniform fixed4 _RimColor;
            float _RimWidth;
            uniform fixed4 _RimBase;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertexColor : COLOR;
            };

            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR0;
                fixed3 color : COLOR1;
            };

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );

                half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                half dotProduct = 1 - dot(v.normal, viewDir);
                o.color = smoothstep(1 - _RimWidth, 1.0, dotProduct);
                o.color *= _RimColor;


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

                finalColor = finalColor +  _RimBase.rgb;
                finalColor += i.color;                

                return fixed4(finalColor, color.a);
            }

            ENDCG
        }
    }

}
