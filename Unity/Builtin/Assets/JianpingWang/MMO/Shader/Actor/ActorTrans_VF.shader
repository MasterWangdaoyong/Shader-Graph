Shader "MMO/Actor/ActorTrans_VF"
{
    Properties
    {
		_Color("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
		//_MaskTex("Mask (R-Spec, G-Emission, B-Reflect)", 2D) = "black" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1

    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" }

		//仅仅写入深度缓冲
		Pass
		{
			ZWrite On
			ColorMask 0
		}

		//正常渲染
        Pass
        {
			Tags{"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
               
            };
			fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _MaskTex;
			fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
				o = UNITY_INITIALIZE_OUTPUT(v2f, o);
				
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 albedo = col.rgb * _Color.rgb;
				fixed4 finalColor = fixed4(albedo, col.a * _AlphaScale);
                return finalColor;
            }
            ENDCG
        }
    }
}
