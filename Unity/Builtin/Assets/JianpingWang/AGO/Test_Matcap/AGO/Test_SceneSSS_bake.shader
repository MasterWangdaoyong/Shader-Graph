Shader "JianpingWang/Test/Test_SceneSSS_bake" 
{
	Properties 
	{
		[Header(Base)]		
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[NoScaleOffset]
		_BumpScale("BumpScale", Range(0, 1)) = 1
		[NORMAL]_BumpMap ("Normal (Normal)", 2D) = "bump" {}
		
		[NoScaleOffset][Space(20)][Header(SSS)]
		_SubColor ("SSS Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_ThicknessScale ("ThicknessScale", Range(0, 3)) = 1.5
		_Thickness ("Thickness (R)", 2D) = "bump" {}
		_SSSMask ("SSSMask", 2D) = "white" {}
		

		[Space(20)][Header(Others)]
		_SpecColora ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125			
	}  

	SubShader 
	{
		Tags { "RenderType"="Opaque" }

		Pass 
		{
			Tags { "LightMode"="ForwardBase" } 
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 

			#pragma multi_compile_fwdbase
			#pragma multi_compile SHADOWS_SHADOWMASK;  

			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"


			sampler2D _MainTex, _BumpMap, _Thickness, _SSSMask;
			float4 	_MainTex_ST;
			half _Scale, _Power, _Distortion , _ThicknessScale, _BumpScale, _Shininess;
			fixed4 _Color, _SubColor, _SpecColora;

			struct appdata
			{
				float4 vertex 	 : POSITION;
				float2 texcoord  : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
				float3 normal 	 : Normal;
				float4 tangent 	 : Tangent; 
			};

			struct v2f 
			{
				float4 pos  	: SV_POSITION;
				float2 uv 		: TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uvLM 	: TEXCOORD2;
				float4 TtoW0 	: TEXCOORD3;
				float4 TtoW1 	: TEXCOORD4;
				float4 TtoW2 	: TEXCOORD5;
			};

		

			inline half4 LightingTranslucent (half3 Albedo,half Alpha,half Gloss, half Specular, half3 Normal, half3 lightDir, half3 viewDir, half atten, float _Distortion, half4 _SubColor,half4 _SpecColora,  half3 lm, half3 SSSMask)
			{	
				viewDir 	= normalize ( viewDir );
				lightDir 	= normalize ( lightDir );
			
				half3 	transAlbedo2   = Albedo * Alpha * _SubColor.rgb * SSSMask;

				half3 h 	= normalize (lightDir + viewDir);
				half diff 	= max (0, dot (Normal, lightDir));
				half nh 	= max (0, dot (Normal, h));
				half spec 	= pow (nh, Specular*128.0) * Gloss;
				half3 diffAlbedo =  Albedo * lm  + (_LightColor0.rgb * Albedo * diff  + _LightColor0.rgb  * _SpecColora.rgb * spec) * atten;				
				
				half4 c;
				c.rgb 	= transAlbedo2 + diffAlbedo;
				c.a 	= 1;

				return c;
			}

			v2f vert (appdata v) 
			{
				v2f o;

				o.uv 	= TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;

				o.pos 	= UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);                                   
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;                        

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

				return o;
			}




			half4 frag (v2f i) : SV_Target  
			{
				half4 finiColor;

				half3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
				half3 viewDir = UnityWorldSpaceViewDir(i.worldPos);

				half3 lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
				lm = lm * lm;     //???????????????????   待深入测试烘焙效果
				half backatten = UnitySampleBakedOcclusion(i.uvLM, i.worldPos);

				half4 tex = tex2D(_MainTex, i.uv);   
				
				tex.rgb = pow(tex.rgb, 2.2);   //1、运算前的矫正   Remove Gamma Correction

				half3 Albedo = tex.rgb * _Color.rgb;

				half3 bump = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy , bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				  
				half Alpha = tex2D(_Thickness, i.uv).r * _ThicknessScale;  //可以尝试把此图放进其他图的通道里，节省资源
				half Gloss = tex.a;
				half Specular = _Shininess;

				half3 SSSMask = tex2D(_SSSMask, i.uv).r;		

				finiColor = LightingTranslucent (Albedo, Alpha, Gloss, Specular, bump, lightDir, viewDir, backatten, _Distortion,  _SubColor, _SpecColora, lm, SSSMask);

				finiColor.rgb =  pow(finiColor.rgb, 0.45);    //2、所有运算后的矫正 Gamma Correction   //分两步完成运算。  

				return finiColor;
			}
		ENDCG
		}
	}	
}











																//http://www.slideshare.net/colinbb/colin-barrebrisebois-gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurfacescattering-look-7170855
// Shader "Custom/Translucent" {                 //完整代码     //https://farfarer.com/blog/2012/09/11/translucent-shader-unity3d/
// 	Properties {
// 		_MainTex ("Base (RGB)", 2D) = "white" {}
// 		_BumpMap ("Normal (Normal)", 2D) = "bump" {}
// 		_Color ("Main Color", Color) = (1,1,1,1)
// 		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
// 		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125

// 		//_Thickness = Thickness texture (invert normals, bake AO).
// 		//_Power = "Sharpness" of translucent glow.
// 		//_Distortion = Subsurface distortion, shifts surface normal, effectively a refractive index.
// 		//_Scale = Multiplier for translucent glow - should be per-light, really.
// 		//_SubColor = Subsurface colour.
// 		_Thickness ("Thickness (R)", 2D) = "bump" {}
// 		_Power ("Subsurface Power", Float) = 1.0
// 		_Distortion ("Subsurface Distortion", Float) = 0.0
// 		_Scale ("Subsurface Scale", Float) = 0.5
// 		_SubColor ("Subsurface Color", Color) = (1.0, 1.0, 1.0, 1.0)
// 	}
// 	SubShader {
// 		Tags { "RenderType"="Opaque" }
// 		LOD 200

// 		CGPROGRAM
// 		#pragma surface surf Translucent
// 		#pragma exclude_renderers flash

// 		sampler2D _MainTex, _BumpMap, _Thickness;
// 		float _Scale, _Power, _Distortion;
// 		fixed4 _Color, _SubColor;
// 		half _Shininess;

// 		struct Input {
// 			float2 uv_MainTex;
// 		};

// 		void surf (Input IN, inout SurfaceOutput o) {
// 			fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
// 			o.Albedo = tex.rgb * _Color.rgb;
// 			o.Alpha = tex2D(_Thickness, IN.uv_MainTex).r;
// 			o.Gloss = tex.a;
// 			o.Specular = _Shininess;
// 			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
// 		}

// 		inline fixed4 LightingTranslucent (SurfaceOutput s, fixed3 lightDir, fixed3 viewDir, fixed atten)
// 		{		
// 			// You can remove these two lines,
// 			// to save some instructions. They're just
// 			// here for visual fidelity.
// 			viewDir = normalize ( viewDir );
// 			lightDir = normalize ( lightDir );

// 			// Translucency.
// 			half3 transLightDir = lightDir + s.Normal * _Distortion;
// 			float transDot = pow ( max (0, dot ( viewDir, -transLightDir ) ), _Power ) * _Scale;
// 			fixed3 transLight = (atten * 2) * ( transDot ) * s.Alpha * _SubColor.rgb;
// 			fixed3 transAlbedo = s.Albedo * _LightColor0.rgb * transLight;

// 			// Regular BlinnPhong.
// 			half3 h = normalize (lightDir + viewDir);
// 			fixed diff = max (0, dot (s.Normal, lightDir));
// 			float nh = max (0, dot (s.Normal, h));
// 			float spec = pow (nh, s.Specular*128.0) * s.Gloss;
// 			fixed3 diffAlbedo = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * _SpecColor.rgb * spec) * (atten * 2);

// 			// Add the two together.
// 			fixed4 c;
// 			c.rgb = diffAlbedo + transAlbedo;
// 			c.a = _LightColor0.a * _SpecColor.a * spec * atten;
// 			return c;
// 		}

// 		ENDCG
// 	}
// 	FallBack "Bumped Diffuse"
// }















// Shader "JianpingWang/Test_SceneSSS_bake"            //20200415 copy备份
// {
// 	Properties 
// 	{
// 		[Header(Base)]		
// 		_Color ("Main Color", Color) = (1,1,1,1)
// 		_MainTex ("Base (RGB)", 2D) = "white" {}
// 		[NoScaleOffset]
// 		_BumpScale("BumpScale", Range(0, 1)) = 1
// 		[NORMAL]_BumpMap ("Normal (Normal)", 2D) = "bump" {}
		
// 		[NoScaleOffset][Space(20)][Header(SSS)]
// 		_SubColor ("SSS Color", Color) = (1.0, 1.0, 1.0, 1.0)
// 		_ThicknessScale ("ThicknessScale", Range(0, 3)) = 1.5
// 		_Thickness ("Thickness (R)", 2D) = "bump" {}
// 		_SSSMask ("SSSMask", 2D) = "white" {}
		

// 		[Space(20)][Header(Others)]
// 		_SpecColora ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
// 		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125			
// 	}  

// 	SubShader 
// 	{
// 		Tags { "RenderType"="Opaque" }

// 		Pass 
// 		{
// 			Tags { "LightMode"="ForwardBase" } 
			
// 			CGPROGRAM
// 			#pragma vertex vert
// 			#pragma fragment frag 

// 			#pragma multi_compile_fwdbase
// 			#pragma multi_compile SHADOWS_SHADOWMASK;  
// 			//shadowmask 的调用

// 			#include "UnityCG.cginc"
// 			#include "AutoLight.cginc"
// 			#include "Lighting.cginc"


// 			sampler2D _MainTex, _BumpMap, _Thickness, _SSSMask;
// 			float4 	_MainTex_ST;
// 			half _Scale, _Power, _Distortion , _ThicknessScale, _BumpScale, _Shininess;
// 			fixed4 _Color, _SubColor, _SpecColora;

// 			struct appdata
// 			{
// 				float4 vertex 	 : POSITION;
// 				float2 texcoord  : TEXCOORD0;
// 				float2 texcoord2 : TEXCOORD1;
// 				float3 normal 	 : Normal;
// 				float4 tangent 	 : Tangent; 
// 			};

// 			struct v2f 
// 			{
// 				float4 pos  	: SV_POSITION;
// 				float2 uv 		: TEXCOORD0;
// 				float3 worldPos : TEXCOORD1;
// 				float2 uvLM 	: TEXCOORD2;
// 				float4 TtoW0 	: TEXCOORD3;
// 				float4 TtoW1 	: TEXCOORD4;
// 				float4 TtoW2 	: TEXCOORD5;
// 			};

		

// 			inline half4 LightingTranslucent (half3 Albedo,half Alpha,half Gloss, half Specular, half3 Normal, half3 lightDir, half3 viewDir, half atten, float _Distortion, half4 _SubColor,half4 _SpecColora,  half3 lm, half3 SSSMask)
// 			{	
// 				viewDir 	= normalize ( viewDir );
// 				lightDir 	= normalize ( lightDir );

// 				// // Translucency.  //高品质版
// 				// half3 	transLightDir = lightDir + Normal * _Distortion;
// 				// half 	transDot 	  = pow ( max (0, dot ( viewDir, - transLightDir ) ), _Power ) * _Scale;
// 				// fixed3 	transLight 	  = (transDot) * Alpha * _SubColor.rgb ;
// 				// fixed3 	transAlbedo   = Albedo * _LightColor0.rgb * transLight;

// 				// Translucency.  简化版
// 				// fixed3 	transAlbedo2   = Albedo * _LightColor0.rgb * Alpha * _SubColor.rgb * SSSMask;
// 				// fixed3 	transAlbedo2   = Albedo * _LightColor0.rgb * Alpha * _SubColor.rgb * SSSMask * (1 - atten);
// 				// fixed3 	transAlbedo2   = Albedo * Alpha * _SubColor.rgb * SSSMask * (1 - atten);
// 				half3 	transAlbedo2   = Albedo * Alpha * _SubColor.rgb * SSSMask;

// 				// Regular BlinnPhong.
// 				half3 h 	= normalize (lightDir + viewDir);
// 				half diff 	= max (0, dot (Normal, lightDir));
// 				half nh 	= max (0, dot (Normal, h));
// 				half spec 	= pow (nh, Specular*128.0) * Gloss;
// 				half3 diffAlbedo =  Albedo * lm  + (_LightColor0.rgb * Albedo * diff  + _LightColor0.rgb  * _SpecColora.rgb * spec) * atten;

// 				// Add the two together.
// 				half4 c;
// 				c.rgb 	= transAlbedo2 + diffAlbedo;
// 				c.a 	= 1;

// 				return c;
// 			}

// 			v2f vert (appdata v) 
// 			{
// 				v2f o;

// 				o.uv 	= TRANSFORM_TEX(v.texcoord, _MainTex);
// 				o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;

// 				o.pos 	= UnityObjectToClipPos(v.vertex);
// 				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			
// 				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
// 				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);                                   
// 				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;                        

// 				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
// 				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
// 				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

// 				return o;
// 			}




// 			half4 frag (v2f i) : SV_Target  
// 			{
// 				half4 finiColor;

// 				half3 lightDir = UnityWorldSpaceLightDir(i.worldPos);
// 				half3 viewDir = UnityWorldSpaceViewDir(i.worldPos);

// 				half3 lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
// 				lm = lm * lm;     //???????????????????   待深入测试烘焙效果
// 				half backatten = UnitySampleBakedOcclusion(i.uvLM, i.worldPos);

// 				half4 tex = tex2D(_MainTex, i.uv);   
				
// 				tex.rgb = pow(tex.rgb, 2.2);   //1、运算前的矫正   Remove Gamma Correction

// 				half3 Albedo = tex.rgb * _Color.rgb;

// 				half3 bump = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
// 				bump.xy *= _BumpScale;
// 				bump.z = sqrt(1.0 - saturate(dot(bump.xy , bump.xy)));
// 				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				  
// 				half Alpha = tex2D(_Thickness, i.uv).r * _ThicknessScale;  //可以尝试把此图放进其他图的通道里，节省资源
// 				half Gloss = tex.a;
// 				half Specular = _Shininess;

// 				half3 SSSMask = tex2D(_SSSMask, i.uv).r;		

// 				finiColor = LightingTranslucent (Albedo, Alpha, Gloss, Specular, bump, lightDir, viewDir, backatten, _Distortion,  _SubColor, _SpecColora, lm, SSSMask);

// 				finiColor.rgb =  pow(finiColor.rgb, 0.45);    //2、所有运算后的矫正 Gamma Correction   //分两步完成运算。  

// 				return finiColor;
// 			}
// 		ENDCG
// 		}
// 	}	
// }




// Shader "Dodjoy/Scene/Scene_Item_SSS"      //JianpingWang //自定义SSS效果  //只供场景特殊物件使用  //20200416
// {
// 	Properties 
// 	{
// 		[Header(Base)]
// 		[NoScaleOffset]
// 		_MainTex ("Base (RGB)", 2D) = "white" {}		
// 		_BumpScale("BumpScale", Range(0, 1)) = 1
// 		[NoScaleOffset]
// 		[NORMAL]_BumpMap ("Normal", 2D) = "bump" {}
		
// 		[Space(20)][Header(SSS)]
// 		_SubColor ("SSS Color(RBG)", Color) = (1.0, 1.0, 1.0, 1.0)
// 		_ThicknessScale ("ThicknessScale", Range(1, 3)) = 1.5
// 		[NoScaleOffset]
// 		_Thickness ("ThicknessMask (RGB)", 2D) = "bump" {}		//R通道为产生SSS效果区域蒙板图    //G通道为Thickness图    //B为粗糙图
// 		[NoScaleOffset]
// 		_MatCap ("MatCap (RGB)", 2D) = "white" {}		            //可带颜色

// 		[Space(20)][Header(Others)]
// 		_SpecColora ("Specular Color(RBG)", Color) = (0.5, 0.5, 0.5, 1)
// 		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		
// 	}  

// 	SubShader 
// 	{
// 		Tags { "RenderType"="Opaque" "IgnoreProjector" = "true"}   

// 		Cull Off

// 		Pass 
// 		{
// 			Tags { "LightMode"="ForwardBase" } 
			
// 			CGPROGRAM
// 			#pragma vertex vert
// 			#pragma fragment frag 

// 			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
// 			#pragma multi_compile_fwdbase
// 			#pragma multi_compile SHADOWS_SHADOWMASK;  

// 			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
// 			#pragma multi_compile DOD_PLATFORM_PC DOD_PLATFORM_MOBILE
// 			#pragma shader_feature DOD_SUN_ON 
// 			#pragma hardware_tier_variants d3d11 glcore gles3 metal

// 			#include "UnityCG.cginc"
// 			#include "AutoLight.cginc"
// 			#include "Lighting.cginc"

// 			#include "DodFog.cginc"
// 			#include "AutoLight.cginc"
// 			#include "DodScenePbsCore.cginc"


// 			sampler2D _MainTex, _BumpMap, _Thickness, _MatCap;
// 			float4 	_MainTex_ST;
// 			half _ThicknessScale, _BumpScale, _Shininess;
// 			fixed4 _SubColor, _SpecColora;
			


// 			struct appdata
// 			{
// 				float4 vertex 	 : POSITION;
// 				float2 texcoord  : TEXCOORD0;
// 				float2 texcoord2 : TEXCOORD1;
// 				float3 normal 	 : Normal;
// 				float4 tangent 	 : Tangent; 
// 			};

// 			struct v2f 
// 			{
// 				float4 pos  	: SV_POSITION;
// 				float2 uv 		: TEXCOORD0;
// 				float3 worldPos : TEXCOORD1;				
// 				float4 TtoW0 	: TEXCOORD2;
// 				float4 TtoW1 	: TEXCOORD3;
// 				float4 TtoW2 	: TEXCOORD4;				
// 				SHADOW_COORDS(5)
// 				DOD_FOG_COORDS(6)
// 				#ifdef LIGHTMAP_ON
// 					float2 uvLM 	: TEXCOORD7;					
// 				#endif
// 			};

		
// 			///////////////////////////////////////////////拟SSS 分级3  		
// 			inline half4 LightingTranslucent3 (half4 Talbedo, half SSS, half Specular, half3 Normal, half3 lightDir, half3 viewDir, half atten, half3 _SubColor, half3 _SpecColora,  half3 lm, sampler2D _MatCap)
// 			{	
// 				viewDir 	= normalize ( viewDir );
// 				lightDir 	= normalize ( lightDir );

// 				//---------采用matcap  不使用cubemap
// 				half2 matUV = half2(0,0);    
// 				matUV.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), Normal); 
//                 matUV.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), Normal); 
//                 matUV = matUV * 0.5 + 0.5; 
// 				fixed3 matCapColor = tex2D(_MatCap, half2(matUV.x, 1.0 - matUV.y)).rgb;
// 				//---------
			
// 				half3 	transAlbedo2   = Talbedo.rgb * SSS * _SubColor.rgb * matCapColor * 2;

// 				half3 h 	= normalize (lightDir + viewDir);
// 				half  diff 	= max (0, dot (Normal, lightDir));
// 				half  nh 	= max (0, dot (Normal, h));
// 				half  spec 	= pow (nh, Specular*128.0) * Talbedo.a;
// 				half3 diffAlbedo =  Talbedo.rgb * lm  + (Talbedo.rgb * diff  + _SpecColora * spec) * _LightColor0.rgb * atten;				
				
// 				half4 c;
// 				c.rgb 	= transAlbedo2 + diffAlbedo;
// 				c.a 	= 1;

// 				return c;
// 			}
// 			///////////////////////////////////////////////拟SSS 

// 			///////////////////////////////////////////////拟SSS 分级2  去掉matcap反射  去掉光滑
// 			inline half4 LightingTranslucent2 (half4 Talbedo, half SSS, half3 Normal, half3 lightDir, half atten, half3 _SubColor, half3 lm)
// 			{					
// 				lightDir = normalize ( lightDir );			
			
// 				half3 	transAlbedo2 = Talbedo.rgb * SSS * _SubColor.rgb;
				
// 				half  diff 	= max (0, dot (Normal, lightDir));
// 				half3 diffAlbedo =  Talbedo.rgb * lm  + (Talbedo.rgb * diff) * _LightColor0.rgb * atten;			
				
// 				half4 c;
// 				c.rgb 	= transAlbedo2 + diffAlbedo;
// 				c.a 	= 1;

// 				return c;
// 			}
// 			///////////////////////////////////////////////拟SSS 

// 			v2f vert (appdata v) 
// 			{
// 				v2f o;

// 				o.uv 	= TRANSFORM_TEX(v.texcoord, _MainTex);
// 				#ifdef LIGHTMAP_ON
// 					o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
// 				#endif

// 				o.pos 	   = UnityObjectToClipPos(v.vertex);
// 				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			
// 				fixed3 worldNormal   = UnityObjectToWorldNormal(v.normal);  
// 				fixed3 worldTangent  = UnityObjectToWorldDir(v.tangent.xyz);                                   
// 				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;                

// 				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
// 				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
// 				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);

// 				TRANSFER_SHADOW(o);
// 				DOD_TRANSFER_FOG(o.fogCoord, v.vertex);

// 				return o;
// 			}




// 			half4 frag (v2f i) : SV_Target  
// 			{
// 				half4 Albedo = tex2D(_MainTex, i.uv);
// 				half4 finiColor = Albedo;

// 				#if defined (UNITY_HARDWARE_TIER3) ||  defined (UNITY_HARDWARE_TIER2) 
// 					half3 viewDir  = UnityWorldSpaceViewDir(i.worldPos);
// 					half3 lightDir = _WorldSpaceLightPos0.xyz;				
// 					half3 bump     = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
// 					bump.xy *= _BumpScale;
// 					bump.z   = sqrt(1.0 - saturate(dot(bump.xy , bump.xy)));
// 					bump     = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
// 				#endif				
				
// 				#if defined (UNITY_HARDWARE_TIER3) ||  defined (UNITY_HARDWARE_TIER2) 						
// 					half3 SSStex   = tex2D(_Thickness, i.uv).rgb; 
// 					half4 Talbedo   = half4(G2L(Albedo.rgb), SSStex.b);
// 					half Thickness = SSStex.g * _ThicknessScale * SSStex.r;								
// 				#endif

// 				#ifdef LIGHTMAP_ON
// 					half3 lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
// 					lm = lm * 2;     
// 					half backatten = UnitySampleBakedOcclusion(i.uvLM, i.worldPos);

// 					#if defined (UNITY_HARDWARE_TIER3)	
// 						finiColor = LightingTranslucent3 (Talbedo, Thickness, _Shininess, bump, lightDir, viewDir, backatten, _SubColor.rgb, _SpecColora.rgb, lm, _MatCap);
// 					#elif defined (UNITY_HARDWARE_TIER2)
// 						finiColor = LightingTranslucent2 (Talbedo, Thickness, bump, lightDir, backatten, _SubColor.rgb, lm);				
// 					#elif defined (UNITY_HARDWARE_TIER1)
// 						finiColor.rgb = simpleLight (lm, Albedo, backatten);
// 						finiColor.a = 1;
// 					#endif

// 				#endif

// 				#if defined (UNITY_HARDWARE_TIER3) || (UNITY_HARDWARE_TIER2)	
// 					fixed shadow = SHADOW_ATTENUATION(i);
// 					shadow = FadeShadows(i.worldPos,shadow);
// 					shadow = clamp(shadow,0.5,1.0);
// 					finiColor *= shadow;
// 				#endif
				
// 				#ifdef LIGHTMAP_ON
// 					finiColor.rgb = pbrLightmapTmp(finiColor.rgb);	
// 				#endif
				
// 				DOD_APPLY_FOG(i.fogCoord, i.worldPos, finiColor.rgb);

// 				return finiColor;
// 			}
// 		ENDCG  
// 		}
// 	}	
    
// }





























