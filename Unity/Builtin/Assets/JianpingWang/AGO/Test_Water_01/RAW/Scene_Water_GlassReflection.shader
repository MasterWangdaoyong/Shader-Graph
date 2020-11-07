
Shader "Dodjoy/Scene/Scene_Water_GlassReflection"       ////Scene_Water_L更改名称为Scene_Water_GlassReflection  //20200405
{
    Properties
    {
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Opaque"}

		//折射图
		// GrabPass
		// {
		// 	"_RefractionTex"
		// }
		
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 screenPos : TEXCOORD0;
				float4 bumpCoords : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float2 uv : TEXCOORD3;
            };

			sampler2D _WaveTex, _Gradient, _ReflectionTex;
			float _WaveScale, _MainScale, _GradientMaskScale;
			float4 _WaveDireciotn, _WaveTiling;

			fixed4 _MainColor;

			float3 PerPixelNormal(sampler2D bumpMap, float4 coords, float bumpStrength)
			{
				float2 bump = UnpackNormal(tex2D(bumpMap, coords.xy));
				bump += UnpackNormal(tex2D(bumpMap, coords.xy * 2));
				bump += UnpackNormal(tex2D(bumpMap, coords.xy * 8));
 
				float3 worldNormal = float3(0,0,0);
				worldNormal.xz = bump.xy * bumpStrength;
				worldNormal.y = 1;
				return worldNormal;
			}

			half FastFresnel(float3 I, float3 N, float R0)
			{
				float icosIN = saturate(1 - dot(I, N));
				float i2 = icosIN * icosIN;
				float i4 = i2 * i2;
				return R0 + (1 - R0) * (i4 * icosIN);
			}

            v2f vert (appdata v)
            {
                v2f o;		
                o.pos = UnityObjectToClipPos(v.vertex);
				o.screenPos = ComputeScreenPos(o.pos);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//法线uv动画
				o.bumpCoords = (o.worldPos.xzxz + _Time.yyyy * _WaveDireciotn.xyzw) * _WaveTiling.xyzw;
				o.uv = v.uv;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 worldPos = i.worldPos;
                float3 viewDir = normalize(worldPos.xyz - _WorldSpaceCameraPos.xyz);

				float3 worldNormal = normalize(PerPixelNormal(_WaveTex,i.bumpCoords, _WaveScale));
				float2 offsets = worldNormal.xz * viewDir.y;
				float2 screenUV = i.screenPos.xy / i.screenPos.w + offsets;	

				float3 reflColor = tex2D(_ReflectionTex, screenUV);

				fixed4 tex = tex2D(_Gradient, i.uv);
				fixed3 finalColor = lerp(tex.rgb , tex.rgb * reflColor , tex.a *_GradientMaskScale) * _MainColor * _MainScale;

				return fixed4(finalColor, 1);
            }
            ENDCG
        }
    }
}
