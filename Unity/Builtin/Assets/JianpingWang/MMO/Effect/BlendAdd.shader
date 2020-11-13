Shader "Dodjoy/Effect/BlendAdd" {
    Properties {
        _TintColor("Tint Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 2)) = 1
        _MainTex("Texture", 2D) = "white" {}
    }

    SubShader {
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        Blend One OneMinusSrcAlpha
        Cull Off Lighting Off ZWrite Off
        
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
                            
            sampler2D _MainTex; 
            float4 _MainTex_ST; 
            fixed4 _TintColor; 
            float _Intensity; 
            
            struct appdata_t {
                float4 vertex : POSITION; 
                float2 texcoord : TEXCOORD0; 
                fixed4 color : COLOR; 
            }; 
            
            struct v2f {
                float4 vertex : POSITION; 
                float2 texcoord : TEXCOORD0; 
                fixed4 color : COLOR; 
            }; 
            
            
            v2f vert(appdata_t v)
            {
                v2f o = (v2f)0; 
                o.vertex = UnityObjectToClipPos(v.vertex); 
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex); 
                o.color = v.color * _Intensity * _TintColor; 
                return o; 
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = i.color * tex2D(_MainTex, i.texcoord); 
                return col; 
            }
            ENDCG
        }
    }
}