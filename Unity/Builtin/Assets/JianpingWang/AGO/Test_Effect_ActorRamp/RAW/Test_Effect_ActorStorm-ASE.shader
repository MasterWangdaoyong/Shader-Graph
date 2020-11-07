// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JianpingWang/StormEffect-ASE"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_Noise1Multiply("Noise1-Multiply", Range( 0 , 8)) = 3
		_Speed("Speed", Range( -0.5 , 0.5)) = 0
		_L1Offset("L1-Offset", Range( 0 , 8)) = 0.8991984
		_L1Color("L1-Color", Color) = (1,0.6413794,0,0)
		_L2Offset("L2-Offset", Range( 0 , 3)) = 0.8991984
		_L2Color("L2-Color", Color) = (0,0,0,0)
		_VertexY("VertexY", Range( -10 , 30)) = 3
		_TranProgress("Tran-Progress", Range( 0 , 1.5)) = 0
		[NoScaleOffset]_NoiseTex1("NoiseTex1", 2D) = "white" {}
		_NoiseScale("Noise-Scale", Range( 0.1 , 100)) = 79.01261
		[NoScaleOffset]_NoiseTex2("NoiseTex2", 2D) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
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

		uniform float _TranProgress;
		uniform float _L1Offset;
		uniform float _VertexY;
		uniform sampler2D _MainTex;
		uniform float4 _L2Color;
		uniform float _L2Offset;
		uniform half4 _L1Color;
		uniform sampler2D _NoiseTex1;
		uniform float _NoiseScale;
		uniform float _Speed;
		uniform float _Noise1Multiply;
		uniform sampler2D _NoiseTex2;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float temp_output_174_0 = ( ase_worldPos.y + (-5.0 + (_TranProgress - 0.0) * (0.0 - -5.0) / (1.0 - 0.0)) );
			float temp_output_222_0 = ( temp_output_174_0 + _L1Offset );
			float temp_output_184_0 = saturate( temp_output_222_0 );
			float3 appendResult206 = (float3(_VertexY , 0.0 , 0.0));
			v.vertex.xyz += ( temp_output_184_0 * appendResult206 );
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 temp_cast_1 = (_NoiseScale).xx;
			float mulTime167 = _Time.y * _Speed;
			float2 appendResult171 = (float2(1.0 , mulTime167));
			float2 uv2_TexCoord163 = i.uv2_texcoord2 * temp_cast_1 + appendResult171;
			float2 temp_cast_2 = (_NoiseScale).xx;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult249 = (float2(ase_worldPos.x , ase_worldPos.y));
			float2 appendResult242 = (float2(1.0 , mulTime167));
			float2 uv2_TexCoord281 = i.uv2_texcoord2 * temp_cast_2 + ( appendResult249 + appendResult242 );
			float4 DissloveMask186 = ( 1.0 - ( ( tex2D( _NoiseTex1, uv2_TexCoord163 ) * _Noise1Multiply ) * tex2D( _NoiseTex2, uv2_TexCoord281 ) ) );
			float temp_output_174_0 = ( ase_worldPos.y + (-5.0 + (_TranProgress - 0.0) * (0.0 - -5.0) / (1.0 - 0.0)) );
			float temp_output_222_0 = ( temp_output_174_0 + _L1Offset );
			float temp_output_190_0 = saturate( ( temp_output_222_0 + _L2Offset ) );
			float4 AlphaClip201 = ( ( 1.0 - ( DissloveMask186 * temp_output_190_0 ) ) * ( 1.0 - saturate( temp_output_174_0 ) ) );
			c.rgb = 0;
			c.a = 1;
			clip( AlphaClip201.r - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_MainTex218 = i.uv_texcoord;
			float3 ase_worldPos = i.worldPos;
			float temp_output_174_0 = ( ase_worldPos.y + (-5.0 + (_TranProgress - 0.0) * (0.0 - -5.0) / (1.0 - 0.0)) );
			float temp_output_222_0 = ( temp_output_174_0 + _L1Offset );
			float temp_output_190_0 = saturate( ( temp_output_222_0 + _L2Offset ) );
			float4 lerpResult179 = lerp( float4( 0,0,0,0 ) , ( _L2Color * 2.0 ) , temp_output_190_0);
			float temp_output_184_0 = saturate( temp_output_222_0 );
			float4 lerpResult181 = lerp( lerpResult179 , ( _L1Color * 2.0 ) , temp_output_184_0);
			o.Emission = ( tex2D( _MainTex, uv_MainTex218 ) + lerpResult181 ).rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float4 customPack1 : TEXCOORD1;
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
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
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
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
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
Version=17500
1927;1;1906;1050;-1551.934;708.2236;2.725401;True;False
Node;AmplifyShaderEditor.CommentaryNode;259;2522.559,-1525.579;Inherit;False;1164.734;858.2734;Noise UV;7;171;250;167;249;242;172;248;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;172;2922.292,-1436.109;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;0;0.5;-0.5;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;248;2589.169,-1251.424;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;167;3239.599,-1429.136;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;171;3450.296,-1453.401;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;249;3026.475,-1227.589;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;277;3426.195,-1622.292;Inherit;False;Property;_NoiseScale;Noise-Scale;11;0;Create;True;0;0;False;0;79.01261;30.5;0.1;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;242;3320.159,-857.9847;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;260;3792.848,-1549.082;Inherit;False;2051.296;851.6046;Noise-Combine;9;186;246;238;168;169;163;270;278;281;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;250;3505.617,-1074.481;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;269;2689.194,-174.5094;Inherit;False;859.8975;460.0518;Tran-Y-Offset-Root;4;258;173;257;174;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;163;3879.257,-1498.082;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;281;3865.104,-1116.692;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;258;2739.194,79.5424;Inherit;False;Property;_TranProgress;Tran-Progress;9;0;Create;True;0;0;False;0;0;0.78;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;169;4184.393,-1325.362;Inherit;False;Property;_Noise1Multiply;Noise1-Multiply;2;0;Create;True;0;0;False;0;3;1.75;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;270;4179.154,-1521.149;Inherit;True;Property;_NoiseTex1;NoiseTex1;10;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;f0189e0aaa7290e4fa2994cffd5d8af2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;173;3007.029,-124.5094;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;267;3783.364,35.81268;Inherit;False;2584.145;847.575;Comment;13;222;178;177;180;179;190;181;182;184;223;282;283;284;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;257;3052.194,83.54241;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-5;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;4561.667,-1343.378;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;278;4164.677,-1146.848;Inherit;True;Property;_NoiseTex2;NoiseTex2;12;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;f0189e0aaa7290e4fa2994cffd5d8af2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;4991.701,-1080.433;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;223;3833.364,346.5116;Inherit;False;Property;_L1Offset;L1-Offset;4;0;Create;True;0;0;False;0;0.8991984;0.53;0;8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;3314.092,-4.146039;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;222;4223.033,327.1152;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;4196.79,558.0536;Inherit;False;Property;_L2Offset;L2-Offset;6;0;Create;True;0;0;False;0;0.8991984;0.55;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;246;5284.771,-1079.25;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;268;3802.354,-611.6039;Inherit;False;1639.618;580.4785;AlphaMask;7;226;225;227;198;187;199;201;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;186;5601.976,-1081.163;Inherit;False;DissloveMask;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;177;4592.725,441.6782;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;3852.355,-561.6039;Inherit;False;186;DissloveMask;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;190;4841.576,441.2625;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;180;4869.904,603.2747;Inherit;False;Property;_L2Color;L2-Color;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;225;3857.92,-284.9606;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;198;4149.344,-556.3082;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;283;4897.764,794.5578;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;199;4410.857,-557.8484;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;229;6496.006,434.4412;Inherit;False;733.8882;405.2561;Comment;3;208;206;216;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;282;5167.764,607.5578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;226;4409.003,-287.6286;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;182;5414.583,175.9699;Half;False;Property;_L1Color;L1-Color;5;0;Create;True;0;0;False;0;1,0.6413794,0,0;0,0.8784313,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;179;5391.667,583.8257;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;184;4644.843,191.7748;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;4685.083,-423.8636;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;208;6542.006,676.847;Inherit;False;Property;_VertexY;VertexY;8;0;Create;True;0;0;False;0;3;-0.05;-10;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;284;5741.531,180.3231;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;181;5962.73,158.1835;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;206;6853.146,681.6978;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;201;5190.425,-434.1282;Inherit;False;AlphaClip;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;218;6552.12,-8.082397;Inherit;True;Property;_MainTex;MainTex;1;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;d1d368fa0d12b16419eae7b9679fa082;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;7060.894,571.3268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;202;7042.456,301.4241;Inherit;False;201;AlphaClip;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;220;7067.217,139.742;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;61;7481.885,95.73007;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;JianpingWang/StormEffect-ASE;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;3;False;-1;6;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;167;0;172;0
WireConnection;171;1;167;0
WireConnection;249;0;248;1
WireConnection;249;1;248;2
WireConnection;242;1;167;0
WireConnection;250;0;249;0
WireConnection;250;1;242;0
WireConnection;163;0;277;0
WireConnection;163;1;171;0
WireConnection;281;0;277;0
WireConnection;281;1;250;0
WireConnection;270;1;163;0
WireConnection;257;0;258;0
WireConnection;168;0;270;0
WireConnection;168;1;169;0
WireConnection;278;1;281;0
WireConnection;238;0;168;0
WireConnection;238;1;278;0
WireConnection;174;0;173;2
WireConnection;174;1;257;0
WireConnection;222;0;174;0
WireConnection;222;1;223;0
WireConnection;246;0;238;0
WireConnection;186;0;246;0
WireConnection;177;0;222;0
WireConnection;177;1;178;0
WireConnection;190;0;177;0
WireConnection;225;0;174;0
WireConnection;198;0;187;0
WireConnection;198;1;190;0
WireConnection;199;0;198;0
WireConnection;282;0;180;0
WireConnection;282;1;283;0
WireConnection;226;0;225;0
WireConnection;179;1;282;0
WireConnection;179;2;190;0
WireConnection;184;0;222;0
WireConnection;227;0;199;0
WireConnection;227;1;226;0
WireConnection;284;0;182;0
WireConnection;284;1;283;0
WireConnection;181;0;179;0
WireConnection;181;1;284;0
WireConnection;181;2;184;0
WireConnection;206;0;208;0
WireConnection;201;0;227;0
WireConnection;216;0;184;0
WireConnection;216;1;206;0
WireConnection;220;0;218;0
WireConnection;220;1;181;0
WireConnection;61;2;220;0
WireConnection;61;10;202;0
WireConnection;61;11;216;0
ASEEND*/
//CHKSM=E951E8EF79D7C1B678D6161B43507976351ECE68