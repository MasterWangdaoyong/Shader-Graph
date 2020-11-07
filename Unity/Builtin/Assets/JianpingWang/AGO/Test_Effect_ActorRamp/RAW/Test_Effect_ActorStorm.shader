
Shader "JianpingWang/Test_Effect_ActorStorm-ASE-Surf"      //JianpingWang //角色溶解 ASE-Surf  //20200411
{
	Properties
	{		
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_L1Multiply("L1-Multiply", Range( 0 , 8)) = 1.3		
		_Speed("Speed", Range( -2 , 2)) = -0.5
		_L1Offset("L1-Offset", Range( 0 , 8)) = 0.52	
		_L1Color("L1-Color", Color) = (1,1,1,0)
		_L2Offset("L2-Offset", Range( 0 , 3)) = 0.55
		_L2Color("L2-Color", Color) = (0,0,0,0)
		_VertexY("VertexY", Range( -10 , 30)) = -0.05
		_TranProgress("Tran-Progress", Range( 0 , 1.5)) = 0
		[NoScaleOffset]_NoiseTex1("NoiseTex1", 2D) = "white" {}
		_NoiseScale("Noise-Scale", Range( 0.1 , 100)) = 30
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float2 uv2_texcoord2;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		float _TranProgress;
		float _L1Offset;
		float _VertexY;
		sampler2D _MainTex;
		float4 _L2Color;
		float _L2Offset;
		half4 _L1Color;
		sampler2D _NoiseTex1;
		float _NoiseScale;
		float _Speed;
		float _L1Multiply;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 worldPos = mul( unity_ObjectToWorld, v.vertex );
			float a = worldPos.y + (-5.0 + (_TranProgress - 0.0) * 5.0 );
			float3 d = float3(_VertexY , 0.0 , 0.0);
			v.vertex.xyz += ( saturate( a + _L1Offset ) * d );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			
			float2 noiseScale = _NoiseScale.xx;
			float timeSpeed = _Time.y * _Speed;

			
			float2 uv1 = i.uv2_texcoord2 * noiseScale + float2(1.0 , timeSpeed);
			
			float2 ff = (float2(i.worldPos.x , i.worldPos.y));
			float2 gg = (float2(1.0 , timeSpeed));

			float2 uv2 = i.uv2_texcoord2 * noiseScale + ( ff + gg );

			float4 noiseTex = 1.0 - ( ( tex2D( _NoiseTex1, uv1 ) * _L1Multiply ) * tex2D( _NoiseTex1, uv2 ) ) ;

			float a = i.worldPos.y + (-5.0 + (_TranProgress - 0.0) * 5.0);

			float b = ( a + _L1Offset );
			float aaa = saturate( b + _L2Offset );
			float4 bbb = ( 1.0 - ( noiseTex * aaa ) ) * ( 1.0 - saturate( a ) ) ;
			c.rgb = 0;
			c.a = 1;
			clip( bbb.r - 0.5 );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 ccc = i.uv_texcoord;			

			float a = i.worldPos.y + (-5.0 + (_TranProgress - 0.0) * 5.0);

			float b = saturate(a + _L1Offset);
			float aaa = saturate( b + _L2Offset );
			float4 lerpAc = lerp(float4(0,0,0,0), _L2Color * 2.0  , aaa);

			float4 lerpA = lerp( lerpAc , _L1Color * 2.0  , b);
			o.Emission = ( tex2D( _MainTex, ccc ) + lerpA ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG		
	}
	Fallback "Diffuse"
}
