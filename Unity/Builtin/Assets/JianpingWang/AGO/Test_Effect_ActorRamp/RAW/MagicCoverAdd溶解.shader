
Shader "effect/MagicCoverAdd" 
{
    Properties {
        // _MainTex()
        _LB_Color ("LB_Color", Color) = (0.7205882,0.8728195,1,1)
        _LB_ColorVal ("LB_ColorVal", Float ) = 1
        _LiangBian ("LiangBian", 2D) = "white" {}
        _TW_Color ("TW_Color", Color) = (0.6764706,0.8929007,1,1)
        _TW_ColorVal ("TW_ColorVal", Float ) = 1
        _TuoWei ("TuoWei", 2D) = "white" {}
        _LBTW_yundong ("LB/TW_yundong", Float ) = 0.3
        _WenLi ("WenLi", 2D) = "white" {}
        _WenLi_yundong ("WenLi_yundong", Float ) = 0.05
        _WenLi_qiangdu ("WenLi_qiangdu", Float ) = 0.1
        _Fresnel_Color ("Fresnel_Color", Color) = (0.4882137,0.6204242,0.6323529,1)
        _FresnelColorVal ("FresnelColorVal", Float ) = 1
        _Fresnel_Val ("Fresnel_Val", Float ) = 3
        _GaoGuang_Color ("GaoGuang_Color", Color) = (0.3088235,0.7711966,1,1)
        _GaoGuang_qiangdu ("GaoGuang_qiangdu", Float ) = 0.1
        _GaoGuangFanWei ("GaoGuangFanWei", Float ) = 0.5
        _Mask ("Mask", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 200
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
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
            #pragma target 3.0
            uniform float4 _LightColor0;
            uniform float4 _Fresnel_Color;
            uniform sampler2D _LiangBian; uniform float4 _LiangBian_ST;
            uniform sampler2D _WenLi; uniform float4 _WenLi_ST;
            uniform float4 _LB_Color;
            uniform sampler2D _TuoWei; uniform float4 _TuoWei_ST;
            uniform float4 _TW_Color;
            uniform float _Fresnel_Val;
            uniform float _WenLi_qiangdu;
            uniform float _WenLi_yundong;
            uniform float _LBTW_yundong;
            uniform float4 _GaoGuang_Color;
            uniform float _GaoGuang_qiangdu;
            uniform float _GaoGuangFanWei;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _LB_ColorVal;
            uniform float _TW_ColorVal;
            uniform float _FresnelColorVal;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = 1;
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = _GaoGuangFanWei;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float3 specularColor = (_GaoGuang_Color.rgb*_GaoGuang_qiangdu);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
////// Emissive:
                float4 node_2859 = _Time;
                float2 node_1198 = (i.uv0+((node_2859.g*_WenLi_yundong)*2.0+-1.0)*float2(0,1));
                float4 _WenLi_var = tex2D(_WenLi,TRANSFORM_TEX(node_1198, _WenLi));
                float2 node_9058 = ((i.uv0+((node_2859.g*_LBTW_yundong)*-1.0+2.0)*float2(1,1))+(_WenLi_var.r*_WenLi_qiangdu));
                float4 _LiangBian_var = tex2D(_LiangBian,TRANSFORM_TEX(node_9058, _LiangBian));
                float4 _TuoWei_var = tex2D(_TuoWei,TRANSFORM_TEX(node_9058, _TuoWei));
                float node_870 = pow(1.0-max(0,dot(normalDirection, viewDirection)),_Fresnel_Val);
                float4 _Mask_var = tex2D(_Mask,TRANSFORM_TEX(i.uv0, _Mask));
                float3 emissive = (((((_LB_Color.rgb*_LB_ColorVal)*_LiangBian_var.rgb*_TuoWei_var.rgb)+(_TuoWei_var.rgb*(_TW_Color.rgb*_TW_ColorVal)))+(_Fresnel_Color.rgb*node_870*_FresnelColorVal))*_Mask_var.a);
/// Final Color:
                float3 finalColor = specular + emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "FORWARD_DELTA"
            Tags {
                "LightMode"="ForwardAdd"
            }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDADD
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdadd
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal d3d11_9x xboxone ps4 psp2 n3ds wiiu 
            #pragma target 3.0
            
            uniform float4 _LightColor0;
            uniform float4 _Fresnel_Color;
            uniform sampler2D _LiangBian; uniform float4 _LiangBian_ST;
            uniform sampler2D _WenLi; uniform float4 _WenLi_ST;
            uniform float4 _LB_Color;
            uniform sampler2D _TuoWei; uniform float4 _TuoWei_ST;
            uniform float4 _TW_Color;
            uniform float _Fresnel_Val;
            uniform float _WenLi_qiangdu;
            uniform float _WenLi_yundong;
            uniform float _LBTW_yundong;
            uniform float4 _GaoGuang_Color;
            uniform float _GaoGuang_qiangdu;
            uniform float _GaoGuangFanWei;
            uniform sampler2D _Mask; uniform float4 _Mask_ST;
            uniform float _LB_ColorVal;
            uniform float _TW_ColorVal;
            uniform float _FresnelColorVal;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                float3 lightColor = _LightColor0.rgb;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz,_WorldSpaceLightPos0.w));
                float3 lightColor = _LightColor0.rgb;
                float3 halfDirection = normalize(viewDirection+lightDirection);
////// Lighting:
                float attenuation = LIGHT_ATTENUATION(i);
                float3 attenColor = attenuation * _LightColor0.xyz;
///////// Gloss:
                float gloss = _GaoGuangFanWei;
                float specPow = exp2( gloss * 10.0 + 1.0 );
////// Specular:
                float NdotL = saturate(dot( normalDirection, lightDirection ));
                float3 specularColor = (_GaoGuang_Color.rgb*_GaoGuang_qiangdu);
                float3 directSpecular = attenColor * pow(max(0,dot(halfDirection,normalDirection)),specPow)*specularColor;
                float3 specular = directSpecular;
/// Final Color:
                float3 finalColor = specular;
                return fixed4(finalColor * 1,0);
            }
            ENDCG
        }
        
    }
}
