Shader "JianpingWang/Test/Realtime_tree_sss"
{
    Properties 
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _MainColor ("Color", COLOR) = (1,1,1,1)
        _ShadowColor ("ShadowColor", Color) = (1,1,1,1)
        _MaskTex ("MaskTex", 2D) = "white"{}
        _EdgeLitRate ("EdgelightRate", Range(0, 2)) = 0.3
        _CutOff ("CutOff", Range(0, 1)) = 0.3

        _OffsetGradientStrength ("OffsetGradientStrength", Range(0, 1)) = 0.7
        _ShakeWindSpeed("_ShakeWindSpeed", float) = 0
        _ShakeBending ("_ShakeBending", float) = 0
        _WindDirRate ("_WindDirRate", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull Off
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbase_fullshadows
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 normal : NORMAL;
            };
            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float4 pos : SV_POSITION;
                fixed4 diff : COLOR0;
                LIGHTING_COORDS(2,3)
            };
            sampler2D _MainTex, _MaskTex;
            float4 _MainTex_ST, _MaskTex_ST;
            float4 _MainColor, _ShadowColor;
            float _OffsetGradientStrength, _ShakeBending, _EdgeLitRate, _ShakeWindSpeed, _WindDirRate;
            float _WindDirectionX, _WindDirectionZ, _WindStrength, _CutOff;
            void FastSinCos (float4 val, out float4 s, out float4 c)
            {
                val = val * 6.408849 - 3.1415927;

                float4 r5 = val * val;
                float4 r6 = r5 * r5;
                float4 r7 = r6 * r5;
                float4 r8 = r6 * r5;
                float4 r1 = r5 * val;
                float4 r2 = r1 * r5;
                float4 r3 = r2 * r5;

                float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841};
                float4 cos8 = {-0.5, 0.04166666, -0.0013888889, 0.000024801587};

                s = val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
                c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
            }

            v2f vert ( appdata v )
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.diff = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                fixed4 grandientCol = tex2Dlod(_MaskTex, float4 (TRANSFORM_TEX(v.texcoord, _MaskTex), 0.0, 0.0));
                float grandient = lerp (grandientCol.g, 1, 1 - _OffsetGradientStrength);
                float xyzOffset = o.uv.y * grandient;

                const float _WindSpeed = _ShakeWindSpeed;
                const float4 _waveXsize = float4 (0.048, 0.06, 0.24, 0.096);
                const float4 _waveZsize = float4 (0.024, 0.08, 0.08, 0.2);
                const float4 waveSpeed = float4 (1.2, 2, 1.6, 4.8);

                float4 _waveXmove = float4(0.024, 0.04, -0.12, 0.096);
                float4 _waveZmove = float4(0.006, 0.02, -0.02, 0.1);

                float4 waves;
                waves = v.vertex.x * _waveXsize;
                waves += v.vertex.z * _waveZsize;
                waves += _Time.x * waveSpeed * _WindSpeed + v.vertex.x + v.vertex.z;
                float4 s, c;
                waves = frac (waves);
                FastSinCos(waves, s, c);
                float waveAmount = v.texcoord.y * _ShakeBending;
                s *= waveAmount;
                s *= normalize(waveSpeed);
                float fade = dot (s, 1.3);
                float3 waveMove = float3 (0, 0, 0);
                float windDirX = _WindDirectionX * _WindStrength;
                float windDirZ = _WindDirectionZ * _WindStrength;
                float windDirY = _WindStrength;

                waveMove.x = dot (s, _waveXmove * windDirX);
                waveMove.z = dot (s, _waveZmove * windDirZ);
                waveMove.y = dot (s, _waveZmove * windDirY);

                float3 windDirOffset = float3 (windDirX, windDirY, windDirZ) * _WindDirRate * xyzOffset;
                float3 waveForce = -mul((float3x3)unity_WorldToObject, waveMove).xyz;
                v.vertex.xyz += waveForce;
                o.pos = UnityViewToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target 
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                fixed4 maskCol = tex2D(_MaskTex, i.uv);
                fixed4 col = fixed4(texCol.rgb * _MainColor.rgb, 1);
                fixed4 shadowCol = lerp(_ShadowColor, fixed4(1.4, 1.4, 1.4, 1), i.diff.r);
                fixed3 edgeCol = maskCol.r * _EdgeLitRate * (i.diff.r + 1) * fixed3(1,1,1);
                clip (texCol.a * _CutOff - 0.5);
                return texCol;

            }
            ENDCG
        }
        Pass 
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster"}
            Offset 1, 1
            Cull Off 
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag 
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_shadowcaster
            #include "AutoLight.cginc"
            
            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex, _MaskTex;
            float4 _MainTex_ST, _MaskTex_ST;            
            float _OffsetGradientStrength, _ShakeBending, _EdgeLitRate, _ShakeWindSpeed, _WindDirRate;
            float _WindDirectionX, _WindDirectionZ, _WindStrength, _CutOff;

            void FastSinCos (float4 val, out float4 s, out float4 c)
            {
                val = val * 6.408849 - 3.1415927;

                float4 r5 = val * val;
                float4 r6 = r5 * r5;
                float4 r7 = r6 * r5;
                float4 r8 = r6 * r5;
                float4 r1 = r5 * val;
                float4 r2 = r1 * r5;
                float4 r3 = r2 * r5;

                float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841};
                float4 cos8 = {-0.5, 0.04166666, -0.0013888889, 0.000024801587};

                s = val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
                c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
            }

            v2f vert ( appdata v) 
            {
                v2f o;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                fixed4 grandientCol = tex2Dlod(_MaskTex, float4 (TRANSFORM_TEX(v.uv, _MaskTex), 0.0, 0.0));
                float grandient = lerp (grandientCol.g, 1, 1 - _OffsetGradientStrength);
                float xyzOffset = o.uv.y * grandient;

                const float _WindSpeed = _ShakeWindSpeed;
                const float4 _waveXsize = float4 (0.048, 0.06, 0.24, 0.096);
                const float4 _waveZsize = float4 (0.024, 0.08, 0.08, 0.2);
                const float4 waveSpeed = float4 (1.2, 2, 1.6, 4.8);

                float4 _waveXmove = float4(0.024, 0.04, -0.12, 0.096);
                float4 _waveZmove = float4(0.006, 0.02, -0.02, 0.1);

                float4 waves;
                waves = v.vertex.x * _waveXsize;
                waves += v.vertex.z * _waveZsize;
                waves += _Time.x * waveSpeed * _WindSpeed + v.vertex.x + v.vertex.z;
                float4 s, c;
                waves = frac (waves);
                FastSinCos(waves, s, c);
                float waveAmount = v.uv.y * _ShakeBending;
                s *= waveAmount;
                s *= normalize(waveSpeed);
                float fade = dot (s, 1.3);
                float3 waveMove = float3 (0, 0, 0);
                float windDirX = _WindDirectionX * _WindStrength;
                float windDirZ = _WindDirectionZ * _WindStrength;
                float windDirY = _WindStrength;

                waveMove.x = dot (s, _waveXmove * windDirX);
                waveMove.z = dot (s, _waveZmove * windDirZ);
                waveMove.y = dot (s, _waveZmove * windDirY);

                float3 windDirOffset = float3 (windDirX, windDirY, windDirZ) * _WindDirRate * xyzOffset;
                float3 waveForce = -mul((float3x3)unity_WorldToObject, waveMove).xyz;
                v.vertex.xyz += waveForce;
                o.pos = UnityViewToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                TRANSFER_SHADOW_CASTER(o);
                return o;

            }
            
            float4 frag( v2f i) : COLOR
            {
                fixed4 texCol = tex2D(_MainTex, i.uv);
                clip(texCol.a * _CutOff - 0.5);
                // return texCol;
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
        
    }
}
