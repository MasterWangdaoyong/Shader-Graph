Shader "JianpingWang/Test_Shadow"                   //20200326   //深入理解阴影结构     //可能存在不兼容平台等问题   最好是调用官方的ShadowCaster
{
    Properties
    {
    }
    SubShader
    {
        Pass 
        {
            Tags {"LightMode" = "ForwardBase"}
            ColorMask RGBA
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            Fog {Mode Off}
            ZWrite On  ZTest Less Cull Off 
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma multi_compile SHADOWS_NATIVE SHADOW_CUBE
            // #pragma fragmentoption ARB_precision_hint_fastest     
            //不知道有啥用

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                //下面三个对应结构 V2F_SHADOW_CASTER
                float4 pos : SV_POSITION;
                float4 hpos : TEXCOORD1;
                float3 vec : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                //对应于 TRANSFER_SHADOW_CASTER(o) 
                o.vec = mul(unity_ObjectToWorld, v.vertex).xyz - _LightPositionRange.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.pos.z += unity_LightShadowBias.x;

                float clamped = max(o.pos.z, -o.pos.w);
                o.pos.z = lerp(o.pos.z, clamped, unity_LightShadowBias.y);
                o.hpos = o.pos;

                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                //对应于 SHADOW_CASTER_FRAGMENT(i)
                return EncodeFloatRGBA(length(i.vec) * (_LightPositionRange.w));
            }
            ENDCG
        }
    }
}
