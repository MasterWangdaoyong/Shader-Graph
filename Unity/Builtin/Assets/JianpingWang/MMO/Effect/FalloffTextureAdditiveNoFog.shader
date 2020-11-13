Shader "Dodjoy/Effect/FalloffTextureAdditiveNodeFog" {        //JianpingWang   //20200402   fixedalpha
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Color ("Main Color", Color) = (1,1,1,1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth ("Rim Width", Range(0, 10)) = 0.7

		_TintColor("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_AdditiveTex("Particle Texture", 2D) = "white" {}
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_USpeed("U Speed", float) = 0
		_VSpeed("V Speed", float) = 0
    }
    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
	    ColorMask RGB
	    Lighting Off ZWrite Off
        // Cull Off

        Pass 
        {
       		Lighting Off
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
				#pragma target 2.0 
				#pragma multi_compile_particles
				#pragma multi_compile_fog
                #include "UnityCG.cginc"
				#include "UnityUI.cginc"

                struct appdata {
                    float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
                    float3 normal : NORMAL;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    fixed3 color : COLOR;
					fixed4 additiveColor : COLOR1;
					float2 texcoord : TEXCOORD01;
#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
#endif

                };

                uniform float4 _MainTex_ST;
                uniform fixed4 _RimColor;
                float _RimWidth;

				sampler2D _AdditiveTex;
				float4 _AdditiveTex_ST;
				fixed4 _TintColor;
				float4 _ClipRect;
				float _USpeed;
				float _VSpeed;

                v2f vert (appdata v) {
                    v2f o;
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                    o.pos = UnityObjectToClipPos (v.vertex);
					
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos(o.pos);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif

                    half3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                    half dotProduct = 1 - dot(v.normal, viewDir);
                   
                    o.color = smoothstep(1 - _RimWidth, 1.0, dotProduct);
                    o.color *= _RimColor;

					o.additiveColor = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord, _AdditiveTex) + frac(half2(_USpeed, _VSpeed) * _Time.y);
					o.uv = v.texcoord.xy;
                    return o;
                }

                uniform sampler2D _MainTex;
                uniform fixed4 _Color;
				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;

                fixed4 frag(v2f i) : COLOR {

					#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.additiveColor.a *= fade;
					#endif

					fixed4 additiveColor = 2.0f * i.additiveColor * _TintColor * tex2D(_AdditiveTex, i.texcoord);
					additiveColor.a = saturate(additiveColor.a); // alpha should not have double-brightness applied to it, but we can't fix that legacy behavior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)

                    fixed4 texcol = tex2D(_MainTex, i.uv);
                    texcol.rgb = _Color.rgb * texcol.rgb;
                    texcol.rgb += i.color.rgb;
					texcol.rgb += (additiveColor * additiveColor.a);
                    texcol.a = _Color.a;
					return texcol;
                }
            ENDCG
        }
    }
}