// Shader "Dodjoy/Scene/Scene_Nature_Tree"    //JianpingWang //20200302
// {
//    Properties
//     {
//         _MainTex ("Texture", 2D) = "white" {}
// 		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
// 		_AmbientScale("AmbientScale", Range(0, 1)) = 0.2				
// 		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0	
// 		_TimeDelay("TimeDelay", Range(1, 4)) = 1	
// 		_VaniScale("VaniScale", Range(0.1, 0.3)) = 0.2
// 		_BendStrength("Bend Strength", Range(0.0, 0.1)) = 0.05		

// 		_BackColor("BackColor", Color) = (1,1,1,1)	
//     }
//     SubShader
//     {
//         Tags { "RenderType"="TransparetnCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
// 		Cull Off

//         Pass
//         {
// 			Tags{"LightMode"="ForwardBase"}
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag   

// 			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
// 			#pragma multi_compile_fwdbase
// 			#pragma multi_compile __ SWING_ON
// 			#pragma multi_compile SHADOWS_SHADOWMASK;

// 			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
// 			#pragma multi_compile_instancing
// 			#include "UnityCG.cginc"
// 			#include "Lighting.cginc"
// 			// #include "CustomFog.cginc"
// 			#include "AutoLight.cginc"

// 			///////////////////////////////////////////////vertex animation JianpingWang
// 			inline	half4 SmoothCurve( half4 x ) 
// 			{
//     			return x * x * ( 3.0 - 2.0 * x );
// 			}

// 			inline	half4 TriangleWave( half4 x ) 
// 			{
// 					return abs( frac( x + 0.5) * 2.0 - 1.0 );
// 			}

// 			inline	half4 SmoothTriangleWave( half4 x )
// 			{
// 					return SmoothCurve( TriangleWave( x ) );
// 			}

// 			inline	float3 VertexAnimationSet(float3 position, float3 origin, float3 normal, half leafStiffness, half branchStiffness, half phaseOffset, float bendStrength, float vertexAnimation, float TimeDelay)
// 			{
// 					///////主混合
// 					float fBendScale = bendStrength;//混合强度
// 					float fLength = length(position);//距离
// 					float2 vWind = float2(sin(_Time.y + origin.x + origin.y) * vertexAnimation, sin(_Time.y + origin.z) * vertexAnimation);//动态方向					
					
// 					float fBF = position.y * fBendScale;										
// 					fBF += 1.0;
// 					fBF *= fBF;
// 					fBF = fBF * fBF - fBF;					
// 					float3 vNewPos = position;
// 					vNewPos.xz += vWind.xy * fBF;					
// 					position = normalize(vNewPos.xyz) * fLength;

// 					////////小混合
// 					float fSpeed = 0.5;
// 					float fDetailFreq = 0.5;
// 					float fEdgeAtten = leafStiffness;
// 					float fDetailAmp = 0.05;
// 					float fDetailPhase = phaseOffset * 1.2;
// 					float fBranchAtten = 1 - branchStiffness;
// 					float fBranchAmp = 0.35;
// 					float fBranchPhase = phaseOffset * 3.3;
					
// 					float fObjPhase = dot(origin, 1);
// 					fBranchPhase += fObjPhase;
// 					float fVtxPhase = dot(position, fDetailPhase + fBranchPhase);
// 					float2 vWavesIn = _Time.y + float2(fVtxPhase, fBranchPhase );					
// 					float4 vWaves = (( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0 ) * fSpeed * fDetailFreq * TimeDelay;
// 					vWaves = SmoothTriangleWave( vWaves );
// 					float2 vWavesSum = vWaves.xz + vWaves.yw;					
// 					return position + vWavesSum.xyx * float3(fEdgeAtten * fDetailAmp * normal.x, fBranchAtten * fBranchAmp, fEdgeAtten * fDetailAmp * normal.z);
// 			}
// 			///////////////////////////////////////////////vertex animation   


//             struct a2v
//             {
//                 float3 vertex : POSITION;
// 				float3 normal : NORMAL;
//                 float2 texcoord : TEXCOORD0;
// 				float2 texcoord2 : TEXCOORD1;
// 				fixed4 color : COLOR;
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             struct v2f
//             {
// 				float4 pos : SV_POSITION;
// 				float3 worldNormal : TEXCOORD0;
// 				float3 worldPos : TEXCOORD1;
//                 float2 uv : TEXCOORD2;
// 				float4 diff : COLOR0;
// 				// CUSTOM_FOG_COORDS(3)
// 			#ifdef LIGHTMAP_ON
// 				float2 uvLM : TEXCOORD4;
// 			#endif			
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             sampler2D _MainTex;
//             float4 _MainTex_ST;
// 			fixed _Cutoff;
			
// 			half _TimeDelay;
// 			float _VaniScale;
// 			float _BendStrength;

// 			float _AmbientScale;

// 			fixed4 _BackColor;

//             v2f vert (a2v v)
//             {
//                 v2f o;
// 				UNITY_SETUP_INSTANCE_ID(v);
//                 UNITY_TRANSFER_INSTANCE_ID(v, o);

// 			#ifdef SWING_ON
// 				float4 objectOrigin = UNITY_MATRIX_M[1];
//                 v.vertex = VertexAnimationSet(v.vertex, objectOrigin.xyz, v.normal, v.color.x, v.color.z, v.color.y, _BendStrength, _VaniScale, _TimeDelay);
// 			#endif
// 				o.pos = UnityObjectToClipPos(v.vertex);
// 				o.worldNormal = UnityObjectToWorldNormal(v.normal);
// 				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

// 			#ifdef LIGHTMAP_ON
// 				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
// 			#endif

// 				o.diff = max(0, dot(o.worldNormal, _WorldSpaceLightPos0.xyz)) * _LightColor0;              
//                 o.diff.rgb += ShadeSH9(half4(o.worldNormal,1));		

// 				// CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target
//             {
// 				fixed4 col = tex2D(_MainTex, i.uv);
// 				clip(col.a - _Cutoff);
// 				fixed4 albedo = col;

// 				fixed3 worldNormal = normalize(i.worldNormal);
// 				fixed3 worldPos = normalize(i.worldPos);
// 				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
// 				fixed3 Ndl = max(0.0,dot(worldNormal,worldLightDir)) + 0.5 * 0.5;
// 				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo.rgb;				
// 			#ifdef LIGHTMAP_ON
// 				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM)));
// 				fixed backatten = UnitySampleBakedOcclusion(i.uvLM, worldPos);

// 				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * Ndl * backatten;
// 				col.rgb = diffuse + ambient;
// 				col.rgb = col.rgb * saturate(col.rgb + lm) * lerp(i.diff, saturate(i.diff), _AmbientScale);

				
// 				fixed3 Bkcolor = lerp(_BackColor,0,clamp(lm.r-0.3, 0.4, 1));
// 				col.rgb = col.rgb + Bkcolor;
// 			#else
// 				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * Ndl;
// 				col.rgb = diffuse + ambient;
// 			#endif							
// 				fixed4 finalColor = col;
// 				finalColor.a = col.a;				
// 				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
//                 return finalColor;
//             }
//             ENDCG
//         }
//     }
	
// }


// Shader "Dodjoy/Scene/Scene_Nature_Tree"    //JianpingWang //20200302
// {
//    Properties
//     {
//         _MainTex ("Texture", 2D) = "white" {}
// 		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
// 		_AmbientScale("AmbientScale", Range(0, 1)) = 0.2				
// 		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0	
// 		_Pos("Position",Vector) = (0,0,0,0)
// 		_Direction("Swing Direction", Vector) = (0,0,0,0)
// 		_TimeScale("Time Scale", float) = 1
// 		_TimeDelay("TimeDelay",float) = 1
// 		// _TimeDelay("TimeDelay", Range(1, 4)) = 1	
// 		// _VaniScale("VaniScale", Range(0.1, 0.3)) = 0.2
// 		// _BendStrength("Bend Strength", Range(0.0, 0.1)) = 0.05	
// 		_LightmapScale("LightmapScale", Range(0, 0.5)) = 0.25
// 		_LightmapScale2("LightmapScale2", Range(0, 0.5)) = 0.25
// 		_EnvironmentScale("EnvironmentScale", Range(0, 0.5)) = 0.5		
//     }
//     SubShader
//     {
//         Tags { "RenderType"="TransparetnCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
// 		Cull Off

//         Pass
//         {
// 			Tags{"LightMode"="ForwardBase"}
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag   

// 			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
// 			#pragma multi_compile_fwdbase
// 			#pragma multi_compile __ SWING_ON
// 			#pragma multi_compile SHADOWS_SHADOWMASK;

// 			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
// 			#pragma multi_compile_instancing
// 			#include "UnityCG.cginc"
// 			#include "Lighting.cginc"
// 			// #include "CustomFog.cginc"
// 			#include "AutoLight.cginc"

// 			// ///////////////////////////////////////////////vertex animation JianpingWang
// 			// inline	half4 SmoothCurve( half4 x ) 
// 			// {
//     		// 	return x * x * ( 3.0 - 2.0 * x );
// 			// }

// 			// inline	half4 TriangleWave( half4 x ) 
// 			// {
// 			// 		return abs( frac( x + 0.5) * 2.0 - 1.0 );
// 			// }

// 			// inline	half4 SmoothTriangleWave( half4 x )
// 			// {
// 			// 		return SmoothCurve( TriangleWave( x ) );
// 			// }

// 			// inline	float3 VertexAnimationSet(float3 position, float3 origin, float3 normal, half leafStiffness, half branchStiffness, half phaseOffset, float bendStrength, float vertexAnimation, float TimeDelay)
// 			// {
// 			// 		///////主混合
// 			// 		float fBendScale = bendStrength;//混合强度
// 			// 		float fLength = length(position);//距离
// 			// 		float2 vWind = float2(sin(_Time.y + origin.x + origin.y) * vertexAnimation, sin(_Time.y + origin.z) * vertexAnimation);//动态方向					
					
// 			// 		float fBF = position.y * fBendScale;										
// 			// 		fBF += 1.0;
// 			// 		fBF *= fBF;
// 			// 		fBF = fBF * fBF - fBF;					
// 			// 		float3 vNewPos = position;
// 			// 		vNewPos.xz += vWind.xy * fBF;					
// 			// 		position = normalize(vNewPos.xyz) * fLength;

// 			// 		////////小混合
// 			// 		float fSpeed = 0.5;
// 			// 		float fDetailFreq = 0.5;
// 			// 		float fEdgeAtten = leafStiffness;
// 			// 		float fDetailAmp = 0.05;
// 			// 		float fDetailPhase = phaseOffset * 1.2;
// 			// 		float fBranchAtten = 1 - branchStiffness;
// 			// 		float fBranchAmp = 0.35;
// 			// 		float fBranchPhase = phaseOffset * 3.3;
					
// 			// 		float fObjPhase = dot(origin, 1);
// 			// 		fBranchPhase += fObjPhase;
// 			// 		float fVtxPhase = dot(position, fDetailPhase + fBranchPhase);
// 			// 		float2 vWavesIn = _Time.y + float2(fVtxPhase, fBranchPhase );					
// 			// 		float4 vWaves = (( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0 ) * fSpeed * fDetailFreq * TimeDelay;
// 			// 		vWaves = SmoothTriangleWave( vWaves );
// 			// 		float2 vWavesSum = vWaves.xz + vWaves.yw;					
// 			// 		return position + vWavesSum.xyx * float3(fEdgeAtten * fDetailAmp * normal.x, fBranchAtten * fBranchAmp, fEdgeAtten * fDetailAmp * normal.z);
// 			// }
// 			// ///////////////////////////////////////////////vertex animation   


//             struct a2v
//             {
//                 float3 vertex : POSITION;
// 				float3 normal : NORMAL;
//                 float2 texcoord : TEXCOORD0;
// 				float2 texcoord2 : TEXCOORD1;
// 				fixed4 color : COLOR;
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             struct v2f
//             {
// 				float4 pos : SV_POSITION;
// 				float3 worldNormal : TEXCOORD0;
// 				float3 worldPos : TEXCOORD1;
//                 float2 uv : TEXCOORD2;
// 				float4 diff : COLOR0;
// 				// CUSTOM_FOG_COORDS(3)
// 			#ifdef LIGHTMAP_ON
// 				float2 uvLM : TEXCOORD4;
// 			#endif			
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             sampler2D _MainTex;
//             float4 _MainTex_ST;
// 			fixed _Cutoff;
			
// 			half4 _Pos;
// 			half4 _Direction;
// 			half _TimeScale;
// 			half _TimeDelay;
// 			// half _TimeDelay;
// 			// float _VaniScale;
// 			// float _BendStrength;

// 			float _AmbientScale;

// 			fixed4 _BackColor;
// 			float _LightmapScale, _EnvironmentScale, _LightmapScale2;

//             v2f vert (a2v v)
//             {
//                 v2f o;
// 				UNITY_SETUP_INSTANCE_ID(v);
//                 UNITY_TRANSFER_INSTANCE_ID(v, o);

// 			#ifdef SWING_ON
// 				// float4 objectOrigin = UNITY_MATRIX_M[1];
//                 // v.vertex = VertexAnimationSet(v.vertex, objectOrigin.xyz, v.normal, v.color.x, v.color.z, v.color.y, _BendStrength, _VaniScale, _TimeDelay);
// 				half dis = distance(v.vertex, _Pos) * v.color.b;
// 				half time = (_Time.y + _TimeDelay) * _TimeScale;
// 				v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;
// 			#endif
// 				o.pos = UnityObjectToClipPos(v.vertex);
// 				o.worldNormal = UnityObjectToWorldNormal(v.normal);
// 				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

// 			#ifdef LIGHTMAP_ON
// 				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
// 			#endif

// 				o.diff = max(0, dot(o.worldNormal, _WorldSpaceLightPos0.xyz));              
//                 o.diff.rgb += ShadeSH9(half4(o.worldNormal,1));		

// 				// CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target
//             {
// 				fixed4 col = tex2D(_MainTex, i.uv);
// 				clip(col.a - _Cutoff);
// 				fixed4 albedo = col;

// 				fixed3 worldNormal = normalize(i.worldNormal);
// 				fixed3 worldPos = normalize(i.worldPos);
// 				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
// 				half3 Ndl = max(0.0,dot(worldNormal,worldLightDir)) + 0.5 * 0.5;
								
// 			#ifdef LIGHTMAP_ON
// 				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM)));
// 				float backatten = UnitySampleBakedOcclusion(i.uvLM, worldPos);

// 				half3 _Ndl = half3(1,1,1) - Ndl;
// 				fixed3 Adiffuse = albedo.rgb *  _Ndl;
				
// 				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * Ndl * backatten;
// 				fixed3 ambient = i.diff * albedo.rgb;
// 				fixed3 LMdiffuse = lm * albedo.rgb;
// 				fixed3 LMback = lerp(albedo.rgb * (fixed3(1,1,1) - lm), lm * albedo.rgb * (fixed3(1,1,1) - lm), _LightmapScale2);
// 				// col.rgb = diffuse + ambient ;
// 				// col.rgb = col.rgb * saturate(col.rgb + lm) * lerp(i.diff, saturate(i.diff), _AmbientScale);

// 				// fixed3 Bkcolor = lerp(_BackColor,0,clamp(lm.r-0.3, 0.4, 1));
// 				// col.rgb = col.rgb + Bkcolor;
// 				// fixed4 cColor = fixed4((Adiffuse + diffuse) * backatten + ambient + LMdiffuse,1);
// 				// fixed4 cColor = fixed4(lerp((Adiffuse + diffuse) * backatten + LMdiffuse, (Adiffuse + diffuse) * backatten + LMdiffuse +ambient, _A), 1);
// 				// fixed4 cColor = fixed4(lerp(diffuse + LMdiffuse, ambient, _A),1);
// 				// fixed4 cColor = fixed4(lerp(LMdiffuse, LMdiffuse + LMback, _A) + diffuse,1);
// 				fixed4 cColor = fixed4(lerp(lerp(LMdiffuse, LMdiffuse + LMback, _LightmapScale), lerp(LMdiffuse, LMdiffuse + LMback, _LightmapScale) * ambient , _EnvironmentScale)+ diffuse,1);
				
// 			#else
// 				fixed4 cColor = 1;
// 				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * Ndl;
// 				col.rgb = diffuse ;
// 			#endif							
// 				fixed4 finalColor = col;
// 				finalColor.a = col.a;				
// 				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
//                 return cColor;
//             }
//             ENDCG
//         }
//     }
	
// }


Shader "JianpingWang/Test/Scene_Nature_Tree"    //JianpingWang //20200309   未采用，1、顶点动画算法太多  2、片元计算量太大
{
   Properties
    {	
		[NoScaleOffset] [Header(Base)]
        _MainTex ("Texture(RGBA)", 2D) = "white" {}		
		_LightmapScale("LightmapScale", Range(0, 0.5)) = 0.5
		_LightmapScale2("LightmapScale2", Range(0, 0.5)) = 0.1
		_EnvironmentScale("EnvironmentScale", Range(0, 0.5)) = 0.1
		_DiffuseLight("SunLight", Range(0, 1.5)) = 1
		_TextureLight("TextureLight", Range(1, 3)) = 1.2		
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

		[Space(20)] [Header(VetexAnimation)]			
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0	
		_TimeDelay("TimeDelay", Range(1, 4)) = 1.5	
		_VaniScale("VaniScale", Range(0.1, 0.3)) = 0.1
		_BendStrength("Bend Strength", Range(0.0, 0.1)) = 0.0		
    }
    SubShader
    {
        Tags { "RenderType"="TransparetnCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
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

			///////////////////////////////////////////////vertex animation JianpingWang
			inline	half4 SmoothCurve( half4 x ) 
			{
    			return x * x * ( 3.0 - 2.0 * x );
			}

			inline	half4 TriangleWave( half4 x ) 
			{
					return abs( frac( x + 0.5) * 2.0 - 1.0 );
			}

			inline	half4 SmoothTriangleWave( half4 x )
			{
					return SmoothCurve( TriangleWave( x ) );
			}

			inline	float3 VertexAnimationSet(float3 position, float3 origin, float3 normal, half leafStiffness, half branchStiffness, half phaseOffset, float bendStrength, float vertexAnimation, float TimeDelay)
			{
					///////主混合
					float fBendScale = bendStrength;//混合强度
					float fLength = length(position);//距离
					float2 vWind = float2(sin(_Time.y + origin.x + origin.y) * vertexAnimation, sin(_Time.y + origin.z) * vertexAnimation);//动态方向					
					
					float fBF = position.y * fBendScale;										
					fBF += 1.0;
					fBF *= fBF;
					fBF = fBF * fBF - fBF;					
					float3 vNewPos = position;
					vNewPos.xz += vWind.xy * fBF;					
					position = normalize(vNewPos.xyz) * fLength;

					////////小混合
					float fSpeed = 0.5;
					float fDetailFreq = 0.5;
					float fEdgeAtten = leafStiffness;
					float fDetailAmp = 0.05;
					float fDetailPhase = phaseOffset * 1.2;
					float fBranchAtten = 1 - branchStiffness;
					float fBranchAmp = 0.35;
					float fBranchPhase = phaseOffset * 3.3;
					
					float fObjPhase = dot(origin, 1);
					fBranchPhase += fObjPhase;
					float fVtxPhase = dot(position, fDetailPhase + fBranchPhase);
					float2 vWavesIn = _Time.y + float2(fVtxPhase, fBranchPhase );					
					float4 vWaves = (( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0 ) * fSpeed * fDetailFreq * TimeDelay;
					vWaves = SmoothTriangleWave( vWaves );
					float2 vWavesSum = vWaves.xz + vWaves.yw;					
					return position + vWavesSum.xyx * float3(fEdgeAtten * fDetailAmp * normal.x, fBranchAtten * fBranchAmp, fEdgeAtten * fDetailAmp * normal.z);
			}
			///////////////////////////////////////////////vertex animation   
			
			///////////////////////////////////////////////fragment 
			inline half3 CustomLerpColor(half3 Ndl, fixed3 albedo, fixed3 ambient, float2 uvLM, float3 worldPos, float _LightmapScale2, float _LightmapScale, float _EnvironmentScale, float _TextureLight, float _DiffuseLight)
			{
				

				fixed3 finalColor = fixed3(1,1,1);				
				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvLM)));
				float backatten = UnitySampleBakedOcclusion(uvLM, worldPos);				
				fixed3 diffuse = _LightColor0.rgb * albedo * Ndl * backatten;
				fixed3 diff = ambient;       //去掉基色，只为更干净减少杂色，通透；原写法fixed3 ambient = i.diff * albedo.rgb;
				fixed3 LMdiffuse = lm * albedo;
				fixed3 LMback = lerp(albedo * (fixed3(1,1,1) - lm), lm * albedo * (fixed3(1,1,1) - lm), _LightmapScale2);				
				finalColor = lerp(lerp(LMdiffuse, LMdiffuse + LMback, _LightmapScale), lerp(LMdiffuse, LMdiffuse + LMback, _LightmapScale) * diff , _EnvironmentScale) * _TextureLight + diffuse * _DiffuseLight;
				return finalColor;
			}


			// inline half3 CustomLerpColor(half3 Ndl, fixed3 albedo, float2 uvLM, float3 worldPos, float _LightmapScale, float _TextureLight, float _DiffuseLight)
// 			{    //整体性能优化写法
// 				fixed3 finalColor = fixed3(1,1,1);				
// 				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvLM)));
// 				float backatten = UnitySampleBakedOcclusion(uvLM, worldPos);				
// 				fixed3 diffuse = _LightColor0.rgb * albedo * Ndl * backatten;
// 				fixed3 LMdiffuse = lm * albedo;
// 				fixed lum = 0.2125 * lm.r + 0.7154 * lm.g + 0.0721 * lm.b; 
				// float c = saturate(lum + lum);	  //去色取反，得到最黑的Mask，这个好用    //20200319   //lum + lum相加得到更高的对比度Mask 如果相乘得到更宽面积更大区域  注意区分这两个不同之处
// 				fixed3 InvertLM = fixed3(1,1,1) - fixed3(lum, lum, lum);	
// 				InvertLM = fixed3(InvertLM.r, InvertLM.r, InvertLM.r);
// 				fixed3 Xlerp = LMdiffuse + albedo * InvertLM * _LightmapScale;			
// 				finalColor = lerp(Xlerp, Xlerp * UNITY_LIGHTMODEL_AMBIENT.xyz , 0.15) * _TextureLight + diffuse * _DiffuseLight;
// 				return finalColor;
// 			} 
			///////////////////////////////////////////////fragment 

            struct a2v
            {
                float3 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
				fixed4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
				float4 diff : COLOR0;
				// CUSTOM_FOG_COORDS(3)
			#ifdef LIGHTMAP_ON
				float2 uvLM : TEXCOORD4;
			#endif			
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _Cutoff;
			half _TimeDelay, _VaniScale, _BendStrength, _DiffuseLight, _LightmapScale, _EnvironmentScale, _LightmapScale2, _TextureLight;

            v2f vert (a2v v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

			#ifdef SWING_ON
				float4 objectOrigin = UNITY_MATRIX_M[1];
                v.vertex = VertexAnimationSet(v.vertex, objectOrigin.xyz, v.normal, v.color.x, v.color.z, v.color.y, _BendStrength, _VaniScale, _TimeDelay);

				// half dis = distance(v.vertex, _Pos) * v.color.b;   //短简版写法，只会左右移动，在需高美术效果下欠佳
				// half time = (_Time.y + _TimeDelay) * _TimeScale;
				// v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;
			#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
			#endif
				o.diff = max(0, dot(o.worldNormal, _WorldSpaceLightPos0.xyz));              
                o.diff.rgb += ShadeSH9(half4(o.worldNormal,1));		
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
				half3 Ndl = max(0.0,dot(worldNormal,worldLightDir)) + 0.5 * 0.5;								
			#ifdef LIGHTMAP_ON				
				col.rgb = CustomLerpColor(Ndl, col.rgb, i.diff, i.uvLM, worldPos, _LightmapScale2, _LightmapScale, _EnvironmentScale, _TextureLight, _DiffuseLight);		
			#else
				col.rgb = _LightColor0.rgb * col.rgb * Ndl + i.diff * col.rgb;
			#endif							
				fixed4 finalColor = col;
				finalColor.a = col.a;				
				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
                return finalColor;
            }
            ENDCG
        }
    }
	
}



// Shader "Dodjoy/Scene/Scene_Nature_Tree"    //JianpingWang //20200319 328 已采用       //如果出现闪屏；模型存在多面，需要删除其他面；应该可以在shader中解决。
// {
//    Properties
//     {	
// 		[NoScaleOffset] [Header(Base)]
//         _MainTex ("Texture(RGBA)", 2D) = "white" {}		
// 		_LightmapScale("LightmapScale", Range(0, 0.5)) = 0.1     
// 		_DiffuseLight("SunLight", Range(0.5, 1.5)) = 1
// 		_TextureLight("TextureLight", Range(0.7, 1.5)) = 1.15
// 		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5

// 		[Space(20)] [Header(VetexAnimation)]			
// 		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0
// 		_Direction("Swing Direction", Vector) = (0,0,0,0)
// 		_TimeScale("Time Scale", float) = 1
// 		_TimeDelay("TimeDelay",float) = 1	
//     }
//     SubShader
//     {
//         Tags { "RenderType"="TransparentCutout"  "Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
// 		Cull Off 

//         Pass
//         {
// 			Tags{"LightMode"="ForwardBase"}
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag   

// 			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
// 			#pragma multi_compile_fwdbase
// 			#pragma multi_compile __ SWING_ON
// 			#pragma multi_compile SHADOWS_SHADOWMASK;

// 			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
// 			#pragma multi_compile_instancing
// 			#include "UnityCG.cginc"
// 			#include "Lighting.cginc"
// 			#include "DodFog.cginc"
// 			#include "AutoLight.cginc"
// 			#include "DodScenePbsCore.cginc"		

// 			///////////////////////////////////////////////fragment 
// 			inline half3 CustomLerpColor(half Ndl, fixed3 albedo, half2 uvLM, half3 worldPos, half _LightmapScale, half _TextureLight, half _DiffuseLight)
// 			{
// 				fixed3 finalColor = fixed3(1,1,1);				
// 				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, uvLM)));
// 				float backatten = UnitySampleBakedOcclusion(uvLM, worldPos);				
// 				fixed3 diffuse = _LightColor0.rgb * albedo * Ndl * backatten;
// 				fixed3 LMdiffuse = lm * albedo;
// 				fixed lum = 0.2125 * lm.r + 0.7154 * lm.g + 0.0721 * lm.b;
// 				fixed3 InvertLM = fixed3(1,1,1) - fixed3(lum, lum, lum);
// 				fixed3 Xlerp = LMdiffuse + albedo * InvertLM * _LightmapScale;			
// 				finalColor = lerp(Xlerp, Xlerp * UNITY_LIGHTMODEL_AMBIENT.xyz , 0.15) * _TextureLight + diffuse * _DiffuseLight;
// 				return finalColor;
// 			}  
// 			///////////////////////////////////////////////fragment 


//             struct a2v
//             {
//                 float4 vertex : POSITION;  
// 				float3 normal : NORMAL;
//                 float2 texcoord : TEXCOORD0;
// 				float2 texcoord2 : TEXCOORD1;
// 				fixed4 color : COLOR;
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             struct v2f
//             {
// 				float4 pos : SV_POSITION;
// 				float3 worldNormal : TEXCOORD0;
// 				float3 worldPos : TEXCOORD1;
//                 float2 uv : TEXCOORD2;
// 				DOD_FOG_COORDS(3)
// 			#ifdef LIGHTMAP_ON
// 				float2 uvLM : TEXCOORD4;
// 			#endif			
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
//             };

//             sampler2D _MainTex;
//             float4 _MainTex_ST;
// 			half _DiffuseLight, _Cutoff, _LightmapScale, _EnvironmentScale, _LightmapScale2, _TextureLight;

// 			half4 _Direction;
// 			half _TimeScale, _TimeDelay;

//             v2f vert (a2v v)
//             {
//                 v2f o;
// 				UNITY_SETUP_INSTANCE_ID(v);
//                 UNITY_TRANSFER_INSTANCE_ID(v, o);

// 			#ifdef SWING_ON
// 				half dis = distance(v.vertex, half4(0, 0, 0, 0)) * v.color.b;  
// 				half time = (_Time.y + _TimeDelay) * _TimeScale;
// 				v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;
// 			#endif
// 				o.pos = UnityObjectToClipPos(v.vertex);
// 				o.worldNormal = UnityObjectToWorldNormal(v.normal);
// 				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
//                 o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

// 			#ifdef LIGHTMAP_ON
// 				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
// 			#endif	
// 				DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
//                 return o;
//             }

//             fixed4 frag (v2f i) : SV_Target
//             {
// 				fixed4 col = tex2D(_MainTex, i.uv);
// 				clip(col.a - _Cutoff);

// 				fixed3 worldNormal = normalize(i.worldNormal);
// 				fixed3 worldPos = normalize(i.worldPos);
// 				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
// 				half Ndl = max(0, dot(worldNormal, worldLightDir) * 0.6 + 0.4); 
								
// 			#ifdef LIGHTMAP_ON
// 				col.rgb = CustomLerpColor(Ndl, col.rgb, i.uvLM, worldPos, _LightmapScale, _TextureLight, _DiffuseLight);			
// 			#else
// 				col.rgb = _LightColor0.rgb * col.rgb * Ndl;
// 			#endif							
// 				fixed4 finalColor = col;
// 				finalColor.a = col.a;
// 				DOD_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
//                 return finalColor;
//             }
//             ENDCG
//         }
//     }
	
// }






// // 实时透光SSS植物，未采用

// Shader "Nature/Tree Creator Leaves FastAAAA" {
// Properties {
//     _Color ("Main Color", Color) = (1,1,1,1)
//     _TranslucencyColor ("Translucency Color", Color) = (0.73,0.85,0.41,1) // (187,219,106,255)
//     _Cutoff ("Alpha cutoff", Range(0,1)) = 0.3
//     _TranslucencyViewDependency ("View dependency", Range(0,1)) = 0.7
//     // _ShadowStrength("Shadow Strength", Range(0,1)) = 1.0

//     _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}

//     // These are here only to provide default values
//     [HideInInspector] _TreeInstanceColor ("TreeInstanceColor", Vector) = (1,1,1,1)
//     [HideInInspector] _TreeInstanceScale ("TreeInstanceScale", Vector) = (1,1,1,1)
//     [HideInInspector] _SquashAmount ("Squash", Float) = 1
// }

// SubShader {
//     Tags {
//         "IgnoreProjector"="True"
//         "RenderType" = "TreeLeaf"
//     }
//     LOD 200 
//     Cull Off

//     Pass {
//         Tags { "LightMode" = "ForwardBase" }
//         Name "ForwardBase"

//     CGPROGRAM
//         // #include "UnityBuiltin3xTreeLibraryCOPY.cginc"
//         #include "UnityCG.cginc"
//         #include "Lighting.cginc"
//         #include "TerrainEngine.cginc"

//         #pragma vertex VertexLeaf
//         #pragma fragment FragmentLeaf

//         sampler2D _MainTex;
//         float4 _MainTex_ST;

//         fixed _Cutoff;
//         sampler2D _ShadowMapTexture;

//         //
//         fixed4 _Color;
//         fixed3 _TranslucencyColor;
//         fixed _TranslucencyViewDependency;
//         //

//         struct v2f_leaf 
//         {
//             float4 pos : SV_POSITION;
//             fixed3 diffuse : COLOR0;
//             fixed3 mainLight : COLOR1;
//             float2 uv : TEXCOORD0;        
//             float2 uvLM : TEXCOORD2;
//         };

//         //-----------------------------------------------------------
//         fixed3 ShadeTranslucentMainLight (float4 vertex, float3 normal)
//         {
//             float3 viewDir = normalize(WorldSpaceViewDir(vertex));
//             float3 lightDir = normalize(WorldSpaceLightDir(vertex));
//             fixed3 lightColor = _LightColor0.rgb;

//             float nl = dot (normal, lightDir);

//             // view dependent back contribution for translucency
//             fixed backContrib = saturate(dot(viewDir, -lightDir));

//             // normally translucency is more like -nl, but looks better when it's view dependent
//             backContrib = lerp(saturate(-nl), backContrib, _TranslucencyViewDependency);

//             // wrap-around diffuse
//             fixed diffuse = max(0, nl * 0.6 + 0.4);

//             return lightColor.rgb * (diffuse + backContrib * _TranslucencyColor);
//         }

//         fixed3 ShadeTranslucentLights (float4 vertex, float3 normal)
//         {
            
//             float3 viewDir = normalize(WorldSpaceViewDir(vertex));
//             float3 mainLightDir = normalize(WorldSpaceLightDir(vertex));
//             float3 frontlight = ShadeSH9 (float4(normal,1.0));
//             float3 backlight = ShadeSH9 (float4(-normal,1.0));
            

//             // view dependent back contribution for translucency using main light as a cue
//             fixed backContrib = saturate(dot(viewDir, -mainLightDir));
//             backlight = lerp(backlight, backlight * backContrib, _TranslucencyViewDependency);

//             // as we integrate over whole sphere instead of normal hemi-sphere
//             // lighting gets too washed out, so let's half it down
//             return 0.5 * (frontlight + backlight * _TranslucencyColor);
//         }

//         void TreeVertLeaf (inout appdata_full v)
//         {
//             v.normal = normalize(v.normal);
//         }
//         //-----------------------------------------------------------

//         v2f_leaf VertexLeaf (appdata_full v)
//         {
//             v2f_leaf o;
//             UNITY_SETUP_INSTANCE_ID(v);
//             UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
            
//             TreeVertLeaf(v);
//             o.pos = UnityObjectToClipPos(v.vertex);

//             float3 worldN = UnityObjectToWorldNormal (v.normal);

//             fixed3 mainLight = fixed3(0,0,0);
//             mainLight = ShadeTranslucentMainLight (v.vertex, worldN);
//             o.diffuse = ShadeTranslucentLights (v.vertex, worldN);
        
//             o.diffuse += mainLight;
            
//             o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//             o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
//             return o;
//         }

//         fixed4 FragmentLeaf (v2f_leaf IN) : SV_Target
//         {
//             fixed4 albedo = tex2D(_MainTex, IN.uv);
//             fixed alpha = albedo.a;
//             clip (alpha - _Cutoff);
        
//             half3 light = IN.diffuse;

//             fixed4 col = fixed4 (albedo.rgb * light, 0.0);

//             // fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.uvLM)));
//             // return fixed4(lerp(albedo.rgb * lm * col.rgb, col.rgb, 0.5), 1);

//             return col;
//         }
        

//     ENDCG
//     }
// }

// }
