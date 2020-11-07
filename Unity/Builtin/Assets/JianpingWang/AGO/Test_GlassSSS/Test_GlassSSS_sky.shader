// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test_GlassSSS_sky"
{
	Properties
	{
		_Base("Base", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		[Toggle(_KEYWORD0_ON)] _Keyword0("Keyword 0", Float) = 0
		_TextureSample0("Texture Sample 0", CUBE) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature _KEYWORD0_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
			};

			uniform sampler2D _Base;
			uniform float4 _Base_ST;
			uniform samplerCUBE _TextureSample0;
			uniform sampler2D _Mask;
			uniform float4 _Mask_ST;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord1.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord3.xyz = ase_worldBitangent;
				
				o.ase_texcoord.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.w = 0;
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				float2 uv_Base = i.ase_texcoord.xyz * _Base_ST.xy + _Base_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord1.xyz;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldBitangent = i.ase_texcoord3.xyz;
				float3x3 ase_worldToTangent = float3x3(ase_worldTangent,ase_worldBitangent,ase_worldNormal);
				float3 temp_output_31_0 = ( float3(-1,1,1) * mul( _WorldSpaceCameraPos, ase_worldToTangent ) );
				float3 temp_output_38_0 = ( float3( 1,1,1 ) / temp_output_31_0 );
				float2 appendResult114 = (float2(i.ase_texcoord.xyz.x , abs( ( i.ase_texcoord.xyz.y - 1.0 ) )));
				float2 temp_output_73_0 = ( appendResult114 * float2( 4,4 ) );
				float4 appendResult17 = (float4(( ( frac( temp_output_73_0 ) * float2( 2,-2 ) ) - float2( 1,-1 ) ) , -1.0 , 0.0));
				float4 break10 = ( float4( abs( temp_output_38_0 ) , 0.0 ) - ( float4( temp_output_38_0 , 0.0 ) * appendResult17 ) );
				float4 break50 = ( float4( ( min( min( break10.x , break10.y ) , break10.z ) * temp_output_31_0 ) , 0.0 ) + appendResult17 );
				float3 appendResult55 = (float3(break50.z , break50.x , break50.y));
				float2 break20 = ceil( temp_output_73_0 );
				float3 lerpResult60 = lerp( float3(-1,1,1) , float3(1,-1,1) , fmod( break20.x , 2.0 ));
				float temp_output_24_0 = fmod( break20.y , 2.0 );
				float3 lerpResult63 = lerp( float3(1,1,1) , float3(-1,1,1) , temp_output_24_0);
				float3 temp_output_62_0 = ( lerpResult60 * lerpResult63 );
				float3 temp_output_56_0 = ( appendResult55 * temp_output_62_0 );
				float3 lerpResult39 = lerp( temp_output_56_0 , (temp_output_56_0).yxz , temp_output_24_0);
				#ifdef _KEYWORD0_ON
				float3 staticSwitch45 = lerpResult39;
				#else
				float3 staticSwitch45 = appendResult55;
				#endif
				float2 uv_Mask = i.ase_texcoord.xyz.xy * _Mask_ST.xy + _Mask_ST.zw;
				
				
				finalColor = ( tex2D( _Base, uv_Base ) + ( texCUBE( _TextureSample0, staticSwitch45 ) * tex2D( _Mask, uv_Mask ) ) );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
1927;1;1906;1050;4064.97;615.9465;1;True;False
Node;AmplifyShaderEditor.TexCoordVertexDataNode;88;-3538.173,-12.44398;Inherit;False;0;2;0;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;108;-3530.781,-155.0468;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;110;-3336.077,-166.0363;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;112;-3184.145,-164.0206;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;95;-3515.229,133.4343;Inherit;False;Constant;_Vector0;Vector 0;3;0;Create;True;0;0;False;0;4,4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;114;-3039.1,-12.46716;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-2836.012,104.4141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;159;-3335.457,-488.5359;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldToTangentMatrix;136;-2955.828,-210.2689;Inherit;False;0;1;FLOAT3x3;0
Node;AmplifyShaderEditor.Vector2Node;14;-2415.856,93.37027;Inherit;False;Constant;_Vector1;Vector 1;0;0;Create;True;0;0;False;0;2,-2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;11;-2408.856,-20.62965;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;15;-2196.856,103.3703;Inherit;False;Constant;_Vector2;Vector 2;0;0;Create;True;0;0;False;0;1,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2210.856,-20.62965;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;29;-2622.37,-418.5796;Inherit;False;Constant;_Vector4;Vector 4;0;0;Create;True;0;0;False;0;-1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-2633.773,-234.7348;Inherit;False;2;2;0;FLOAT3;0,1,1;False;1;FLOAT3x3;0,0,0,1,1,1,1,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1953.856,105.3703;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;13;-1958.856,-21.62965;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2279.969,-255.5797;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;17;-1701.856,-21.62965;Inherit;True;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-1970.9,-376.4;Inherit;True;2;0;FLOAT3;1,1,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-1588.3,-239.7;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;1;-1581.3,-490.7;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;3;-1358.3,-316.7;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;10;-1189.156,-313.5297;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMinOpNode;5;-899.4583,-314.9383;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;6;-763.4583,-259.9383;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;19;-2432.961,293.5408;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-623.8583,-184.5383;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-2214.961,293.5408;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;22;-2134.552,433.0135;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;24;-1817.551,416.0135;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-348.1558,-136.5297;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FmodOpNode;21;-1823.551,297.0137;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;59;-1370.955,110.335;Inherit;False;Constant;_Vector6;Vector 6;1;0;Create;True;0;0;False;0;-1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;64;-1371.971,429.7503;Inherit;False;Constant;_Vector7;Vector 7;1;0;Create;True;0;0;False;0;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;65;-1363.071,625.1505;Inherit;False;Constant;_Vector8;Vector 8;1;0;Create;True;0;0;False;0;-1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;61;-1370.955,270.335;Inherit;False;Constant;_Vector3;Vector 3;1;0;Create;True;0;0;False;0;1,-1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;63;-1002.47,603.9501;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;50;-149.9609,-126.6525;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;60;-1000.954,259.335;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-698.9453,352.9744;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;173.7601,-263.3422;Inherit;True;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;442.6661,11.66952;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;67;796.5765,106.2402;Inherit;False;FLOAT3;1;0;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;39;1087.709,9.207861;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;45;1474.709,-24.29213;Inherit;True;Property;_Keyword0;Keyword 0;2;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;98;1458.732,256.9464;Inherit;True;Property;_Mask;Mask;1;0;Create;True;0;0;False;0;-1;0b8cf9fd8748c44478a2569b15672dd3;0b8cf9fd8748c44478a2569b15672dd3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;173;1782.081,-195.3332;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;-1;None;50352acfbeffd3f49ac81e8678a5ae00;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;161;1459.724,483.0413;Inherit;True;Property;_Base;Base;0;0;Create;True;0;0;False;0;-1;0b8cf9fd8748c44478a2569b15672dd3;d0119a74bd820e746b7fc42a88ec31de;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;1894.724,126.0413;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;2017.724,487.0413;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FmodOpNode;26;-1820.971,547.0654;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;175;-2913.97,-488.9465;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;174;-2939.702,-129.0812;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-2138.552,566.0135;Inherit;False;Constant;_Float2;Float 2;0;0;Create;True;0;0;False;0;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;68;-255.9662,521.733;Inherit;False;FLOAT3;1;0;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;69;52.28535,504.122;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FmodOpNode;77;-1815.693,681.7543;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;176;-3231.97,-342.9465;Inherit;False;Constant;_Float4;Float 4;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2260.968,483.4488;Float;False;True;-1;2;ASEMaterialInspector;100;1;Test_GlassSSS_sky;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;110;0;88;2
WireConnection;110;1;108;0
WireConnection;112;0;110;0
WireConnection;114;0;88;1
WireConnection;114;1;112;0
WireConnection;73;0;114;0
WireConnection;73;1;95;0
WireConnection;11;0;73;0
WireConnection;12;0;11;0
WireConnection;12;1;14;0
WireConnection;117;0;159;0
WireConnection;117;1;136;0
WireConnection;13;0;12;0
WireConnection;13;1;15;0
WireConnection;31;0;29;0
WireConnection;31;1;117;0
WireConnection;17;0;13;0
WireConnection;17;2;18;0
WireConnection;38;1;31;0
WireConnection;2;0;38;0
WireConnection;2;1;17;0
WireConnection;1;0;38;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;10;0;3;0
WireConnection;5;0;10;0
WireConnection;5;1;10;1
WireConnection;6;0;5;0
WireConnection;6;1;10;2
WireConnection;19;0;73;0
WireConnection;7;0;6;0
WireConnection;7;1;31;0
WireConnection;20;0;19;0
WireConnection;24;0;20;1
WireConnection;24;1;22;0
WireConnection;8;0;7;0
WireConnection;8;1;17;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;63;0;64;0
WireConnection;63;1;65;0
WireConnection;63;2;24;0
WireConnection;50;0;8;0
WireConnection;60;0;59;0
WireConnection;60;1;61;0
WireConnection;60;2;21;0
WireConnection;62;0;60;0
WireConnection;62;1;63;0
WireConnection;55;0;50;2
WireConnection;55;1;50;0
WireConnection;55;2;50;1
WireConnection;56;0;55;0
WireConnection;56;1;62;0
WireConnection;67;0;56;0
WireConnection;39;0;56;0
WireConnection;39;1;67;0
WireConnection;39;2;24;0
WireConnection;45;1;55;0
WireConnection;45;0;39;0
WireConnection;173;1;45;0
WireConnection;160;0;173;0
WireConnection;160;1;98;0
WireConnection;163;0;161;0
WireConnection;163;1;160;0
WireConnection;26;0;20;0
WireConnection;26;1;23;0
WireConnection;175;0;159;0
WireConnection;175;3;176;0
WireConnection;68;0;62;0
WireConnection;69;0;62;0
WireConnection;69;1;68;0
WireConnection;69;2;77;0
WireConnection;77;0;20;1
WireConnection;77;1;23;0
WireConnection;0;0;163;0
ASEEND*/
//CHKSM=06B270C1E0EF0994AC69AF598787547FB2489EAD