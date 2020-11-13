// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test_Effect_ActorRamp2"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Noise1Scale("Noise1-Scale", Range( 0.1 , 150)) = 10
		_Noise1Multiply("Noise1-Multiply", Range( 0 , 8)) = 1.1
		_Speed1("Speed1", Range( -0.5 , 0.5)) = -0.1
		_Noise2TileUV("Noise2-Tile-UV", Range( 0 , 1)) = 1
		_Noise2Scale("Noise2-Scale", Range( 0.1 , 150)) = 4
		_Noise2Multiply("Noise2-Multiply", Range( 0 , 12)) = 0.75
		_Speed2("Speed2", Range( -2 , 0.5)) = -1.5
		_L3Color("L3-Color", Color) = (1,1,1,0)
		_L3Offset("L3-Offset", Range( 0 , 8)) = 2.75
		_L2Color("L2-Color", Color) = (1,1,0,0)
		_L2Offset("L2-Offset", Range( 0 , 3)) = 0.8
		_L1Color("L1-Color", Color) = (0.3529412,0.02352941,0.02352941,0)
		_L1Offset("L1-Offset", Range( 0 , 3)) = 0.8
		_VertexY("VertexY", Range( 0 , 30)) = 2
		_TranProgress("Tran-Progress", Range( 0 , 1)) = 0.54
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
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
			half2 uv_texcoord;
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

		uniform half _TranProgress;
		uniform half _L3Offset;
		uniform half _VertexY;
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_ST;
		uniform half4 _L1Color;
		uniform half _L2Offset;
		uniform half _L1Offset;
		uniform half4 _L2Color;
		uniform half4 _L3Color;
		uniform half _Speed1;
		uniform half _Noise1Scale;
		uniform half _Noise1Multiply;
		uniform half _Noise2TileUV;
		uniform half _Speed2;
		uniform half _Noise2Scale;
		uniform half _Noise2Multiply;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			half3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_5_0 = ( ase_worldPos.y + (-10.0 + (_TranProgress - 0.0) * (0.0 - -10.0) / (4.0 - 0.0)) );
			float temp_output_8_0 = ( temp_output_5_0 + _L3Offset );
			float offsetY10 = temp_output_8_0;
			float3 appendResult30 = (half3(_VertexY , 0.0 , 0.0));
			v.vertex.xyz += ( saturate( offsetY10 ) * appendResult30 );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float mulTime58 = _Time.y * _Speed1;
			float2 appendResult59 = (half2(1.0 , mulTime58));
			float2 uv_TexCoord60 = i.uv_texcoord + appendResult59;
			float simplePerlin2D61 = snoise( uv_TexCoord60*_Noise1Scale );
			simplePerlin2D61 = simplePerlin2D61*0.5 + 0.5;
			float temp_output_63_0 = ( simplePerlin2D61 * _Noise1Multiply );
			half3 ase_worldPos = i.worldPos;
			float2 appendResult44 = (half2(ase_worldPos.x , ( ase_worldPos.y * _Noise2TileUV )));
			float mulTime48 = _Time.y * _Speed2;
			float2 appendResult49 = (half2(1.0 , mulTime48));
			float simplePerlin2D52 = snoise( ( appendResult44 + appendResult49 )*_Noise2Scale );
			simplePerlin2D52 = simplePerlin2D52*0.5 + 0.5;
			float temp_output_54_0 = ( simplePerlin2D52 * _Noise2Multiply );
			float DissMask67 = ( 1.0 - ( temp_output_63_0 * saturate( temp_output_54_0 ) ) );
			float temp_output_5_0 = ( ase_worldPos.y + (-10.0 + (_TranProgress - 0.0) * (0.0 - -10.0) / (4.0 - 0.0)) );
			float temp_output_8_0 = ( temp_output_5_0 + _L3Offset );
			float temp_output_11_0 = ( temp_output_8_0 + _L2Offset );
			float L2Mask16 = saturate( temp_output_11_0 );
			float AlphaClip42 = saturate( ( ( 1.0 - ( DissMask67 * L2Mask16 ) ) * ( 1.0 - saturate( temp_output_5_0 ) ) ) );
			c.rgb = 0;
			c.a = 1;
			clip( AlphaClip42 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half3 ase_worldPos = i.worldPos;
			float temp_output_5_0 = ( ase_worldPos.y + (-10.0 + (_TranProgress - 0.0) * (0.0 - -10.0) / (4.0 - 0.0)) );
			float temp_output_8_0 = ( temp_output_5_0 + _L3Offset );
			float temp_output_11_0 = ( temp_output_8_0 + _L2Offset );
			float4 lerpResult18 = lerp( float4( 0,0,0,0 ) , _L1Color , saturate( ( temp_output_11_0 + _L1Offset ) ));
			float L2Mask16 = saturate( temp_output_11_0 );
			float4 lerpResult22 = lerp( lerpResult18 , _L2Color , L2Mask16);
			float4 lerpResult24 = lerp( lerpResult22 , _L3Color , saturate( temp_output_8_0 ));
			o.Emission = ( tex2D( _MainTex, uv_MainTex ) + lerpResult24 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
359;346;1278;561;750.3918;37.55383;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;43;-2713.679,-764.0219;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;46;-2739.594,-560.8517;Float;False;Property;_Noise2TileUV;Noise2-Tile-UV;5;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2744.072,-437.7431;Float;False;Property;_Speed2;Speed2;8;0;Create;True;0;0;False;0;-1.5;-1.5;-2;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-2364.745,-622.1439;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2623.095,-985.5967;Float;False;Property;_Speed1;Speed1;4;0;Create;True;0;0;False;0;-0.1;-0.1;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;48;-2385.28,-431.3531;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-2166.741,-741.2438;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-2168.28,-456.3531;Float;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;58;-2307.966,-980.0566;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2268.368,218.9316;Float;False;Property;_TranProgress;Tran-Progress;16;0;Create;True;0;0;False;0;0.54;0.54;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-1868.279,-582.3531;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1813.425,-434.0989;Float;False;Property;_Noise2Scale;Noise2-Scale;6;0;Create;True;0;0;False;0;4;4;0.1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-2100.55,-1001.063;Float;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1485.558,-440.8522;Float;False;Property;_Noise2Multiply;Noise2-Multiply;7;0;Create;True;0;0;False;0;0.75;0.75;0;12;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1844.851,-865.7656;Float;False;Property;_Noise1Scale;Noise1-Scale;2;0;Create;True;0;0;False;0;10;10;0.1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;52;-1504.558,-582.8522;Float;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;6;-1933.739,61.85419;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-1831.55,-1047.063;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;4;-1930.639,225.2542;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;4;False;3;FLOAT;-10;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;61;-1516.714,-1052.539;Float;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1180.558,-576.8522;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-1641.739,178.8542;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-1548.607,-804.1471;Float;False;Property;_Noise1Multiply;Noise1-Multiply;3;0;Create;True;0;0;False;0;1.1;1.1;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1481.105,414.9261;Float;False;Property;_L3Offset;L3-Offset;10;0;Create;True;0;0;False;0;2.75;2.75;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;55;-957.5577,-574.8522;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1243.105,532.9261;Float;False;Property;_L2Offset;L2-Offset;12;0;Create;True;0;0;False;0;0.8;0.8;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1131.105,395.9261;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1185.785,-1047.556;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-899.1047,476.9261;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-732.1332,-597.2722;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-648.1047,399.9261;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;66;-509.6305,-598.2502;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-257.6305,-604.2502;Float;False;DissMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-485.1047,395.9261;Float;False;L2Mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1032.105,627.9261;Float;False;Property;_L1Offset;L1-Offset;14;0;Create;True;0;0;False;0;0.8;0.8;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1296.009,-185.9292;Float;False;67;DissMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-1295.009,-107.9292;Float;False;16;L2Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;34;-1296.009,31.07078;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1074.009,-160.9292;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-631.1047,552.9261;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;39;-903.0087,-160.9292;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;-470.1047,552.9261;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;35;-904.0087,31.07078;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-244.1047,418.9261;Float;False;Property;_L1Color;L1-Color;13;0;Create;True;0;0;False;0;0.3529412,0.02352941,0.02352941,0;0.3529412,0.02352941,0.02352941,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-921.1047,391.9261;Float;False;offsetY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;49.89526,506.9261;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;36.52094,399.4686;Float;False;16;L2Mask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-700.0087,-77.92923;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;23;-230.4791,212.4686;Float;False;Property;_L2Color;L2-Color;11;0;Create;True;0;0;False;0;1,1,0,0;1,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;699.772,655.463;Float;False;Property;_VertexY;VertexY;15;0;Create;True;0;0;False;0;2;2;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;22;305.5209,390.4686;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;9;-913.5896,264.6042;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;783.772,540.463;Float;False;10;offsetY;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;41;-511.4079,-78.53436;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;7.93433,-1.512024;Float;False;Property;_L3Color;L3-Color;9;0;Create;True;0;0;False;0;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-333.5994,-83.5998;Float;False;AlphaClip;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;24;493.521,215.4686;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;33;1019.772,539.463;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;1030.779,-206.4578;Float;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;d1d368fa0d12b16419eae7b9679fa082;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;30;1036.772,661.463;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;1387.772,410.463;Float;False;42;AlphaClip;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-787.2803,-1048.751;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;1251.772,636.463;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2;1389.407,192.4285;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1696.562,187.8948;Half;False;True;2;Half;ASEMaterialInspector;0;0;CustomLighting;Test_Effect_ActorRamp2;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;TransparentCutout;;Geometry;All;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;45;0;43;2
WireConnection;45;1;46;0
WireConnection;48;0;47;0
WireConnection;44;0;43;1
WireConnection;44;1;45;0
WireConnection;49;1;48;0
WireConnection;58;0;57;0
WireConnection;50;0;44;0
WireConnection;50;1;49;0
WireConnection;59;1;58;0
WireConnection;52;0;50;0
WireConnection;52;1;51;0
WireConnection;60;1;59;0
WireConnection;4;0;3;0
WireConnection;61;0;60;0
WireConnection;61;1;62;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;5;0;6;2
WireConnection;5;1;4;0
WireConnection;55;0;54;0
WireConnection;8;0;5;0
WireConnection;8;1;7;0
WireConnection;63;0;61;0
WireConnection;63;1;64;0
WireConnection;11;0;8;0
WireConnection;11;1;12;0
WireConnection;56;0;63;0
WireConnection;56;1;55;0
WireConnection;15;0;11;0
WireConnection;66;0;56;0
WireConnection;67;0;66;0
WireConnection;16;0;15;0
WireConnection;34;0;5;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;13;0;11;0
WireConnection;13;1;14;0
WireConnection;39;0;38;0
WireConnection;17;0;13;0
WireConnection;35;0;34;0
WireConnection;10;0;8;0
WireConnection;18;1;20;0
WireConnection;18;2;17;0
WireConnection;40;0;39;0
WireConnection;40;1;35;0
WireConnection;22;0;18;0
WireConnection;22;1;23;0
WireConnection;22;2;21;0
WireConnection;9;0;8;0
WireConnection;41;0;40;0
WireConnection;42;0;41;0
WireConnection;24;0;22;0
WireConnection;24;1;25;0
WireConnection;24;2;9;0
WireConnection;33;0;27;0
WireConnection;30;0;28;0
WireConnection;65;0;63;0
WireConnection;65;1;54;0
WireConnection;31;0;33;0
WireConnection;31;1;30;0
WireConnection;2;0;1;0
WireConnection;2;1;24;0
WireConnection;0;2;2;0
WireConnection;0;10;26;0
WireConnection;0;11;31;0
ASEEND*/
//CHKSM=95A843DE4A581D3E9383816E4C3FFA6F4D6DC2EB