// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JianpingWang/FlowMap"
{
	Properties
	{
		[NoScaleOffset]_FlowMap("FlowMap", 2D) = "white" {}
		[NoScaleOffset]_Diffuse("Diffuse", 2D) = "white" {}
		_Speed("Speed", Float) = 1
		_Tiling("Tiling", Float) = 1
		_Strength("Strength", Float) = 1
		_Alpha("Alpha", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
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


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};

			uniform sampler2D _Diffuse;
			uniform sampler2D _FlowMap;
			uniform float _Speed;
			uniform float _Strength;
			uniform float _Tiling;
			uniform float _Alpha;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
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

#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
#endif
				float2 uv060 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 uv_FlowMap41 = i.ase_texcoord1.xy;
				float2 blendOpSrc59 = uv060;
				float2 blendOpDest59 = (tex2D( _FlowMap, uv_FlowMap41 )).rg;
				float2 temp_output_59_0 = ( saturate( (( blendOpDest59 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest59 ) * ( 1.0 - blendOpSrc59 ) ) : ( 2.0 * blendOpDest59 * blendOpSrc59 ) ) ));
				float temp_output_54_0 = ( _Time.y * _Speed );
				float temp_output_1_0_g3 = temp_output_54_0;
				float temp_output_57_0 = (0.0 + (( ( temp_output_1_0_g3 - floor( ( temp_output_1_0_g3 + 0.5 ) ) ) * 2 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
				float TimeA62 = ( -temp_output_57_0 * _Strength );
				float2 lerpResult61 = lerp( uv060 , temp_output_59_0 , TimeA62);
				float2 temp_cast_0 = (_Tiling).xx;
				float2 uv076 = i.ase_texcoord1.xy * temp_cast_0 + float2( 0,0 );
				float2 DiffuseTiling77 = uv076;
				float2 FlowA68 = ( lerpResult61 + DiffuseTiling77 );
				float temp_output_1_0_g2 = (temp_output_54_0*1.0 + 0.5);
				float TimeB86 = ( -(0.0 + (( ( temp_output_1_0_g2 - floor( ( temp_output_1_0_g2 + 0.5 ) ) ) * 2 ) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) * _Strength );
				float2 lerpResult87 = lerp( uv060 , temp_output_59_0 , TimeB86);
				float2 FlowB90 = ( lerpResult87 + DiffuseTiling77 );
				float BlendTime99 = saturate( abs( ( 1.0 - ( temp_output_57_0 / 0.5 ) ) ) );
				float4 lerpResult94 = lerp( tex2D( _Diffuse, FlowA68 ) , tex2D( _Diffuse, FlowB90 ) , BlendTime99);
				float4 appendResult128 = (float4((lerpResult94).rgb , _Alpha));
				float4 Diffuse70 = appendResult128;
				
				
				finalColor = Diffuse70;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18000
19;66;1824;917;4878.739;2625.567;5.143873;True;False
Node;AmplifyShaderEditor.CommentaryNode;63;-1693.8,165.2567;Inherit;False;1951.2;690.7635;Comment;20;99;95;98;96;97;62;86;85;58;84;57;56;83;82;54;53;55;110;111;112;Time;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-1628.8,324.2565;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;False;0;1;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;53;-1643.8,215.2567;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1381.8,254.2567;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;82;-1196.323,482.8394;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;83;-931.5068,485.7565;Inherit;False;Sawtooth Wave;-1;;2;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;56;-1200.8,252.2567;Inherit;False;Sawtooth Wave;-1;;3;289adb816c3ac6d489f255fc3caf5016;0;1;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;84;-690.5075,488.7565;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;57;-959.7996,255.2567;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1690.574,-654.2312;Inherit;False;1982.398;624.1754;Comment;13;87;88;89;90;68;79;61;80;66;59;44;60;41;FlowMap UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-1686.906,-1039.874;Inherit;False;899.0818;211;Comment;3;73;77;76;Diffuse Tiling;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;112;-455.0685,365.5346;Inherit;False;Property;_Strength;Strength;6;0;Create;True;0;0;False;0;1;5.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;58;-655.7997,254.2567;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;85;-404.5076,491.7565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1636.906,-967.0236;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;False;0;1;1.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;41;-1640.574,-361.9561;Inherit;True;Property;_FlowMap;FlowMap;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;bcc6329aad71ba940bd10dcff76159a8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-174.0686,491.5346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-234.741,258.7929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;44;-1284.574,-361.9561;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;60;-1304.159,-604.2312;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;52.3984,489.2941;Inherit;False;TimeB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;43.90635,254.194;Inherit;False;TimeA;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;76;-1376.824,-984.8738;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;88;-822.4598,-128.7368;Inherit;False;86;TimeB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;95;-665.9164,744.9362;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;59;-862.1592,-385.2312;Inherit;False;Overlay;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-791.7312,-500.168;Inherit;False;62;TimeA;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1030.824,-989.8738;Inherit;False;DiffuseTiling;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;87;-489.2781,-181.93;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;61;-521.1592,-603.2312;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-540.5718,-442.7549;Inherit;False;77;DiffuseTiling;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;96;-507.9164,743.9362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;97;-310.9164,743.9362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;89;-156.0632,-178.4716;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-234.5718,-600.7549;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;29.2688,-602.168;Inherit;False;FlowA;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;98;-142.9165,743.9362;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;91;455.353,-647.6042;Inherit;False;1691.748;541.5112;Comment;11;70;94;51;100;92;93;71;69;127;129;128;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;90;44.93677,-183.4716;Inherit;False;FlowB;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;511.6684,-277.6091;Inherit;False;90;FlowB;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;69;505.3531,-597.6042;Inherit;True;Property;_Diffuse;Diffuse;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;b8455599424652c4c8fb43e7735c036d;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;513.353,-380.6039;Inherit;False;68;FlowA;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;25.08352,739.9362;Inherit;False;BlendTime;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;92;838.5554,-302.661;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;100;866.8721,-392.2366;Inherit;False;99;BlendTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;828.3629,-594.523;Inherit;True;Property;_Diff;Diff;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;94;1192.668,-587.6092;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;129;1337.969,-274.4279;Inherit;False;Property;_Alpha;Alpha;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;127;1371.969,-365.4279;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;128;1743.969,-359.4279;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;1891.908,-587.4192;Inherit;False;Diffuse;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;113;441.5284,956.9805;Inherit;False;1717.748;556.5112;Comment;11;118;120;122;121;123;124;116;114;117;119;115;Emissive;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;101;417.8713,196.9275;Inherit;False;1162.135;565.1923;Comment;8;108;102;106;105;107;109;103;104;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;72;1946.637,226.8269;Inherit;False;70;Diffuse;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;475.8712,463.9279;Inherit;False;68;FlowA;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;107;801.0745,541.8707;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;1869.528,1014.98;Inherit;False;Emissive;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;124;1111.412,1129.543;Inherit;False;Property;_EmissiveColor;Emissive Color;7;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;114;491.5285,1006.98;Inherit;True;Property;_Emissive;Emissive;2;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;102;467.8712,246.9276;Inherit;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;1339.048,1427.348;Inherit;False;99;BlendTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;814.539,1010.062;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;115;497.8439,1326.975;Inherit;False;90;FlowB;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;108;1155.187,256.9225;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;106;790.8824,250.0087;Inherit;True;Property;_TextureSample5;Texture Sample 5;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;103;474.1866,566.9225;Inherit;False;90;FlowB;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;499.5285,1223.981;Inherit;False;68;FlowA;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;1350.412,1312.543;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;120;1677.844,1018.975;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;1346.871,252.9276;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;1374.412,1018.543;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;829.3914,452.2952;Inherit;False;99;BlendTime;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;119;824.7311,1301.923;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2211.731,233.82;Float;False;True;-1;2;ASEMaterialInspector;100;1;JianpingWang/FlowMap;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;0;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Transparent=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;82;0;54;0
WireConnection;83;1;82;0
WireConnection;56;1;54;0
WireConnection;84;0;83;0
WireConnection;57;0;56;0
WireConnection;58;0;57;0
WireConnection;85;0;84;0
WireConnection;111;0;85;0
WireConnection;111;1;112;0
WireConnection;110;0;58;0
WireConnection;110;1;112;0
WireConnection;44;0;41;0
WireConnection;86;0;111;0
WireConnection;62;0;110;0
WireConnection;76;0;73;0
WireConnection;95;0;57;0
WireConnection;59;0;60;0
WireConnection;59;1;44;0
WireConnection;77;0;76;0
WireConnection;87;0;60;0
WireConnection;87;1;59;0
WireConnection;87;2;88;0
WireConnection;61;0;60;0
WireConnection;61;1;59;0
WireConnection;61;2;66;0
WireConnection;96;0;95;0
WireConnection;97;0;96;0
WireConnection;89;0;87;0
WireConnection;89;1;80;0
WireConnection;79;0;61;0
WireConnection;79;1;80;0
WireConnection;68;0;79;0
WireConnection;98;0;97;0
WireConnection;90;0;89;0
WireConnection;99;0;98;0
WireConnection;92;0;69;0
WireConnection;92;1;93;0
WireConnection;51;0;69;0
WireConnection;51;1;71;0
WireConnection;94;0;51;0
WireConnection;94;1;92;0
WireConnection;94;2;100;0
WireConnection;127;0;94;0
WireConnection;128;0;127;0
WireConnection;128;3;129;0
WireConnection;70;0;128;0
WireConnection;107;0;102;0
WireConnection;107;1;103;0
WireConnection;121;0;120;0
WireConnection;117;0;114;0
WireConnection;117;1;116;0
WireConnection;108;0;106;0
WireConnection;108;1;107;0
WireConnection;108;2;105;0
WireConnection;106;0;102;0
WireConnection;106;1;104;0
WireConnection;122;0;119;0
WireConnection;122;1;124;0
WireConnection;120;0;123;0
WireConnection;120;1;122;0
WireConnection;120;2;118;0
WireConnection;109;0;108;0
WireConnection;123;0;117;0
WireConnection;123;1;124;0
WireConnection;119;0;114;0
WireConnection;119;1;115;0
WireConnection;0;0;72;0
ASEEND*/
//CHKSM=E2483A165FA5F67EFF061E9469ADFF0BC3F8C8BD