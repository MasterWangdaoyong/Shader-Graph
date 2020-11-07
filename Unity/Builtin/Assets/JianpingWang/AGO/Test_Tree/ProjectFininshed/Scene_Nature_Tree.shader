Shader "Project/Scene/Scene_Nature_Tree"    //JianpingWang //20200328  //20200408      
{
   Properties
    {	
		[NoScaleOffset] [Header(Base)]
        _MainTex ("Texture(RGBA)", 2D) = "white" {}		
		_LightmapScale("LightmapScale", Range(0, 0.5)) = 0.1     
		_DiffuseLight("SunLight", Range(0.5, 1.5)) = 1
		_TextureLight("TextureLight", Range(0.7, 1.5)) = 1.15
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

		[Space(20)] [Header(VetexAnimation)]			
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0
		_Direction("Swing Direction", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", float) = 1
		_TimeDelay("TimeDelay",float) = 1	
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
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
			#pragma multi_compile SHADOWS_SHADOWMASK

			// #pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
			#pragma multi_compile_instancing
			// #pragma shader_feature DOD_SUN_ON 
			#pragma hardware_tier_variants d3d11 glcore gles3 metal
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			// #include "DodFog.cginc"
			#include "AutoLight.cginc"
			// #include "DodScenePbsCore.cginc"		

			///////////////////////////////////////////////fragment 
			inline half3 CustomLerpColor(half Ndl, fixed3 albedo, half2 uvLM, half3 worldPos, half _LightmapScale, half _TextureLight, half _DiffuseLight)
			{
				fixed3 finalColor = fixed3(1,1,1);				
				fixed3 lm 		  = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvLM)));
				float backatten   = UnitySampleBakedOcclusion(uvLM, worldPos);				
				fixed3 diffuse    = _LightColor0.rgb * albedo * Ndl * clamp(backatten + 0.5, 0.3, 1);
				fixed3 LMdiffuse  = lm * albedo;
				fixed lum = 0.2125 * lm.r + 0.7154 * lm.g + 0.0721 * lm.b;
				fixed3 InvertLM = fixed3(1,1,1) - fixed3(lum, lum, lum);
				fixed3 Xlerp    = LMdiffuse + albedo * InvertLM * _LightmapScale;			
				finalColor      = Xlerp * _TextureLight + diffuse * _DiffuseLight;
				return finalColor;
			}  
			///////////////////////////////////////////////fragment 


            struct a2v
            {
                float4 vertex    : POSITION;  
				float3 normal    : NORMAL;
                float2 texcoord  : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
				fixed4 color     : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos         : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos    : TEXCOORD1;
                float2 uv          : TEXCOORD2;
				// DOD_FOG_COORDS(3)
			#ifdef LIGHTMAP_ON
				float2 uvLM : TEXCOORD4;
			#endif			
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			half _DiffuseLight, _Cutoff, _LightmapScale, _EnvironmentScale, _LightmapScale2, _TextureLight;

			half4 _Direction;
			half _TimeScale, _TimeDelay;

            v2f vert (a2v v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

			#ifdef SWING_ON
				half dis      = distance(v.vertex, half4(0, 0, 0, 0)) * v.color.b;  
				half time     = (_Time.y + _TimeDelay) * _TimeScale;
				v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;
			#endif
				o.pos		  = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos	  = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv       	  = TRANSFORM_TEX(v.texcoord, _MainTex);

			#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			#endif	
				// DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);

				fixed3 worldNormal   = normalize(i.worldNormal);
				fixed3 worldPos      = normalize(i.worldPos);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				half Ndl = max(0, dot(worldNormal, worldLightDir) * 0.6 + 0.4); 
								
			#ifdef LIGHTMAP_ON
				col.rgb = CustomLerpColor(Ndl, col.rgb, i.uvLM, worldPos, _LightmapScale, _TextureLight, _DiffuseLight);			
			#else
				col.rgb = _LightColor0.rgb * col.rgb * Ndl;
			#endif							
				fixed4 finalColor = col;
				finalColor.a      = col.a;
				// DOD_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
                return finalColor;
            }
            ENDCG
        }
    }
	
}