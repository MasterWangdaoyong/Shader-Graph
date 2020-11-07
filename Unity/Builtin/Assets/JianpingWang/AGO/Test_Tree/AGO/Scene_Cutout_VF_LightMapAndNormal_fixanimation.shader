Shader "JianpingWang/Test/Scene_Cutout_VF_LightMapAndNormal-fixanimation"
{
   Properties
    {
		
//		_Saturation("Saturation", float) = 1//饱和度添加
        _MainTex ("Texture", 2D) = "white" {}
		_FrontColor("Front Color", Color) = (1, 1, 1, 1)
		_BackColor("BackColor", Color) = (0.3, 0.3, 0.3, 1)
		_LightScale("LightScale",Range(0,  4)) = 1.4
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0
		
		_Pos("Position",Vector) = (0,0,0,0)
		_Direction("Swing Direction", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", float) = 1
		_TimeDelay("TimeDelay",float) = 1
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5	

		_Lm ("LM", Range(0, 10)) = 1
		_S ("S", Range(0, 20)) = 1
		_B ("B" ,Range(0, 1)) = 1

		_BumpMap("normal", 2D) = "white" {}

		_BendStrength("Bend Strength", Range(0.00, 0.20)) = 0.05
		
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

			///////////////////////////////////////////////vertex animation 
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

			inline	float3 VegetationDeformation(float3 position, float3 origin, float3 normal, half leafStiffness, half branchStiffness, half phaseOffset, float bendStrength)
			{
					///////主混合
					float fBendScale = bendStrength;//混合强度
					float fLength = length(position);//距离
					float2 vWind = float2(sin(_Time.y + origin.x + origin.y) * 0.1, sin(_Time.y + origin.z) * 0.1);//动态方向
					
					
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
					float4 vWaves = (( vWavesIn.xxyy * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0 ) * fSpeed * fDetailFreq;
					vWaves = SmoothTriangleWave( vWaves );
					float2 vWavesSum = vWaves.xz + vWaves.yw;					
					return position + vWavesSum.xyx * float3(fEdgeAtten * fDetailAmp * normal.x, fBranchAtten * fBranchAmp, fEdgeAtten * fDetailAmp * normal.z);
			}
			///////////////////////////////////////////////vertex animation   



			///////////////////////////////////////////////SSS Emission
			// inline float3 TexTangentNormalToWorldNormal(float3 texNormal, float3 a, float3 b, float c)
			// {
			// 	float3 TexWorldNormal = float3(0, 0, 0);

			// 	TexWorldNormal = normalize(half3 (dot(a, texNormal), dot(b, texNormal), dot(c, texNormal)));


			// 	return TexWorldNormal;
			// }
			
			// inline	fixed3 SSS( float3 worldPos, float3 vertexNormal, float4 vertexColor, fixed4 texColor, float3 texNormal )
			// {
			// 	//mainlight
			// 	float3 Direction = UnityWorldSpaceLightDir(worldPos);   
			// 	float3 Color = _LightColor0.rgb;						
			// 	float  ShadowAtten = 1;
				
			// 	float3 AMultiply = Color * ShadowAtten;              //向量  Multiply(ina, inb)     Multiply(Color, ShadowAtten)

			// 	//ssslight
			// 	float3 worldTexNormal = TexTangentNormalToWorldNormal(texNormal);             //TtoWorldNormal(texnormal)
			// 	float3 worldVertexNormal = UnityObjectToWorldNormal(vertexNormal);
			// 	float3 normalAffectsss = normalAffectSSS(worldTexNormal, worldVertexNormal);    //normalAffectSSS(ina, inb)  

			// 	//SSS mask 
			// 	float SAMultiply = Multiply(vertexColor.g);										//Multiply(ina)   变体输入1，输出1
			// 	float minimum = min(SAMultiply, SAMultiply);                                  //Minimum(ina)    	Out = min(A, B);
			// 	float4 SBMultiply = Multiply(minimum, texColor.rgba);

			// 	float Occlusion = vertexColor.a;
			
			// 	float dotProduct = dot(Negate(Direction), normalAffectsss);                // Negate(ina)
			// 	float SadotProduct = saturate(dotProduct);                            
			// 	float3 BMultiply = Multiply(SadotProduct, AMultiply);
			// 	float3 CMultiply = Multiply(BMultiply, SBMultiply.rgb);
			// 	fixed3 DMultiply = Occlusion * CMultiply);

			// 	return DMultiply;
			// }	

			inline float Negate(float In)               //Negate(ina)
			{
				return float (-1 * In);
			}

			inline float3 normalAffectSSS(float Ina, float Inb)
			{
				return float3(1,1,1);
			}

			

			// void MainLight_half(float3 WorldPos, out half3 Direction, out half3 Color, out half DistanceAtten, out half ShadowAtten)
			// {				
			// 		#if SHADOWS_SCREEN
			// 			half4 clipPos = TransformWorldToHClip(WorldPos);
			// 			half4 shadowCoord = ComputeScreenPos(clipPos);
			// 		#else
			// 			half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
			// 		#endif
			// 			Light mainLight = GetMainLight(shadowCoord);
			// 			Direction = mainLight.direction;
			// 			Color = mainLight.color;
			// 			DistanceAtten = mainLight.distanceAttenuation;
			// 			ShadowAtten = mainLight.shadowAttenuation;				
			// }

			///////////////////////////////////////////////SSS Emission
			


            struct a2v
            {
                float3 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;    
				float2 texcoord2 : TEXCOORD1;
				fixed4 color : COLOR;  //修改 缺少顶点色输入
				float4 tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
				float4 vvertex : COLOR0;
				//CUSTOM_FOG_COORDS(3)
#ifdef LIGHTMAP_ON
				float2 uvLM : TEXCOORD4;
#endif			
//				SHADOW_COORDS(5)
				float3 vertexNormal : TEXCOORD5;
				float4 vertexColor : COLOR1;
				float3 a : TEXCOORD6;
				float3 b : TEXCOORD7;
				float3 c : TEXCOORD8;

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
			sampler2D _BumpMap;

			float _Lm;
			float _S;
			float _B;
//			half _Saturation;

			float _BendStrength;

            v2f vert (a2v v)
            {
                v2f o;  
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
#ifdef SWING_ON
				// half dis = distance(v.vertex, _Pos) * v.color.b;
				// half time = (_Time.y + _TimeDelay) * _TimeScale;
				// v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;

				float4 objectOrigin = UNITY_MATRIX_M[1];
                v.vertex = VegetationDeformation(v.vertex, objectOrigin.xyz, v.normal, v.color.x, v.color.z, v.color.y, _BendStrength);

#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.vvertex = v.color;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
#ifdef LIGHTMAP_ON
				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
				
				//CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);
				o.vertexNormal = v.normal;
				o.vertexColor = v.color;

				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(o.worldNormal, worldTangent) * v.tangent.w;

				o.a = float3(worldTangent.x, worldBinormal.x, o.worldNormal.x);
				o.b = float3(worldTangent.y, worldBinormal.y, o.worldNormal.y);
				o.c = float3(worldTangent.z, worldBinormal.z, o.worldNormal.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutoff);

				fixed4 albedo = col;


				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldPos = normalize(i.worldPos);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 Ndl = max(0.0,dot(worldNormal,worldLightDir)) + 0.5 * 0.5;       

				fixed3 texNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				texNormal = normalize(half3 (dot(i.a, texNormal), dot(i.b, texNormal), dot(i.c, texNormal)));


				
#ifdef LIGHTMAP_ON
				fixed3 lm = (DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM)));
				fixed backatten = UnitySampleBakedOcclusion(i.uvLM, worldPos);

				fixed3 ambient = lerp(_BackColor * UNITY_LIGHTMODEL_AMBIENT.xyz, albedo.rgb *_BackColor * UNITY_LIGHTMODEL_AMBIENT.xyz, 0.4);
				fixed3 diffuse = lerp(_FrontColor , _FrontColor * _LightColor0.rgb * albedo.rgb * Ndl * lm, 0.9);
							
				col.rgb =diffuse + ambient ;
#else
				fixed3 fcolor = _LightColor0.rgb * Ndl * _FrontColor;
				fixed3 bcolor = (1-Ndl)*_BackColor;
				col.rgb *= (fcolor + bcolor) ;
#endif


				float3 Direction = UnityWorldSpaceLightDir(worldPos);   
				float3 Color = _LightColor0.rgb;						
				float  ShadowAtten = 1;
				
				float3 AMultiply = Color * ShadowAtten;           

				//ssslight
				float3 worldTexNormal = texNormal;            
				float3 worldVertexNormal = UnityObjectToWorldNormal(i.vertexNormal);
				float3 normalAffectsss = normalAffectSSS(worldTexNormal, worldVertexNormal);   

				//SSS mask 
				float SAMultiply = i.vertexColor.g;										
				float minimum = min(SAMultiply, SAMultiply);                                 
				float4 SBMultiply = minimum * albedo.rgba;

				float Occlusion = i.vertexColor.a;
			
				float dotProduct = dot(Negate(Direction), normalAffectsss);               
				float SadotProduct = saturate(dotProduct);                            
				float3 BMultiply = SadotProduct * AMultiply;
				float3 CMultiply = BMultiply * SBMultiply.rgb;
				fixed3 DMultiply = Occlusion * CMultiply;


				
				fixed4 finalColor = col;
				finalColor.a = col.a;
				
				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
				// return fixed4(backAtten, 1);
                return fixed4(i.vvertex.a, i.vvertex.a, i.vvertex.a, 1);
            }
            ENDCG
        }
		
    }
	
}
