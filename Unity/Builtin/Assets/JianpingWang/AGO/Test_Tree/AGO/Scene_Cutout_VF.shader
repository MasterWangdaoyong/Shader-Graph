// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "JianpingWang/Test/Scene_Cutout_VF"
{
    Properties
    {
		
//		_Saturation("Saturation", float) = 1//饱和度添加
        _MainTex ("Texture", 2D) = "white" {}
		_FrontColor("Front Color", Color) = (1, 1, 1, 1)
		_BackColor("BackColor", Color) = (0.3, 0.3, 0.3, 1)
		_LightScale("LightScale",Range(0,4.0)) = 1.4
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0
		
		_Pos("Position",Vector) = (0,0,0,0)
		_Direction("Swing Direction", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", float) = 1
		_TimeDelay("TimeDelay",float) = 1
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5	

    }
    SubShader
    {
        Tags { "RenderType"="TransparetnCutout" 
		"Queue" = "AlphaTest"
		"IgnoreProjector" = "true"}
		
		Cull Off

        Pass
        {
			Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag   

			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile_fwdbase
			#pragma multi_compile __ SWING_ON
			#pragma multi_compile SHADOWS_SHADOWMASK;

			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			// #include "CustomFog.cginc"
			#include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
				fixed4 color : COLOR;  //修改 缺少顶点色输入
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
				// CUSTOM_FOG_COORDS(3)
#ifdef LIGHTMAP_ON
				float2 uvLM : TEXCOORD4;
#endif			
//				SHADOW_COORDS(5)
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			fixed3 _FrontColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _Cutoff;
			fixed4 _BackColor;
			fixed _LightScale;
			half4 _Pos;
			half4 _Direction;
			half _TimeScale;
			half _TimeDelay;

//			half _Saturation;

            v2f vert (a2v v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
#ifdef SWING_ON
				half dis = distance(v.vertex, _Pos) * v.color.b;
				half time = (_Time.y + _TimeDelay) * _TimeScale;
				v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;

#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
				//UNITY_TRANSFER_FOG(o, o.pos);
				// CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldPos = normalize(i.worldPos);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 Ndl = max(0.0,dot(worldNormal,worldLightDir));               


				//fixed lum = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
				//fixed4 lumColor = fixed4(lum, lum, lum, col.a);
				//col = lerp(lumColor, col, _Saturation);
				////饱和度添加
			
				//col.rgb *= _Color.rgb;
//				fixed4 ambient = _AmbientColor * col;//环境补偿色

#ifdef LIGHTMAP_ON
				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM)));
				fixed backatten = UnitySampleBakedOcclusion(i.uvLM,worldPos);
				fixed3 lmcolor = (lm + max(0.1, Ndl)*_LightColor0.rgb * backatten) * _LightScale;
				fixed3 Bkcolor = lerp(_BackColor,0,clamp(0,1,lm.r-0.2));
				col.rgb *= lmcolor*_FrontColor + Bkcolor;
#else
				fixed3 fcolor = _LightColor0.rgb * Ndl * _FrontColor;
				fixed3 bcolor = (1-Ndl)*_BackColor;
				col.rgb *= (fcolor + bcolor) ;
#endif
				//half alpha = smoothstep(0, 1, col.a);
				//col.rgb *= alpha;
				fixed4 finalColor = col;
				finalColor.a = col.a;
				//UNITY_APPLY_FOG(i.fogCoord, finalColor);
				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);

                return finalColor;
            }
            ENDCG
        }
    }
	
}
