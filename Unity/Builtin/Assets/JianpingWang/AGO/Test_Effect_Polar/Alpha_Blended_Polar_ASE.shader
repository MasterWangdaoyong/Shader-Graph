// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JianpingWang/Effect_Polar_ASE"
{
	Properties
	{
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		_ScaleOffset("_ScaleOffset", Vector) = (1,1,0,0)
		_Scale("Scale", Float) = 1
		_Rotator("Rotator", Float) = 0
		_AlphaClip("AlphaClip", Range( 0 , 1)) = 0.5

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
	LOD 0

		CGINCLUDE
		#pragma target 2.0
		ENDCG
		Blend Off
		Cull Off
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
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform half _Rotator;
			uniform half _Scale;
			uniform float4 _ScaleOffset;
			uniform half _AlphaClip;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_color = v.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
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
				float4 color5 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				half2 uv0_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float cos33 = cos( ( ( ( 1.0 - length( (uv0_MainTex*2.0 + -1.0) ) ) * 2.0 * _Rotator ) * UNITY_PI ) );
				float sin33 = sin( ( ( ( 1.0 - length( (uv0_MainTex*2.0 + -1.0) ) ) * 2.0 * _Rotator ) * UNITY_PI ) );
				half2 rotator33 = mul( uv0_MainTex - float2( 0.5,0.5 ) , float2x2( cos33 , -sin33 , sin33 , cos33 )) + float2( 0.5,0.5 );
				half2 temp_output_39_0 = (rotator33*2.0 + -1.0);
				half2 break10 = temp_output_39_0;
				half2 appendResult15 = (half2(pow( length( temp_output_39_0 ) , _Scale ) , ( ( atan2( break10.y , break10.x ) / ( 2.0 * UNITY_PI ) ) + 0.5 )));
				half2 appendResult19 = (half2(_ScaleOffset.x , _ScaleOffset.y));
				half2 appendResult20 = (half2(_ScaleOffset.z , _ScaleOffset.w));
				half2 break37 = (appendResult15*appendResult19 + appendResult20);
				half2 appendResult38 = (half2(break37.y , break37.x));
				half4 tex2DNode4 = tex2D( _MainTex, appendResult38 );
				clip( tex2DNode4.a - _AlphaClip);
				
				
				finalColor = ( color5 * tex2DNode4 * i.ase_color );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
270;422;1531;589;7321.586;665.0957;2.3687;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-6325.847,64.59557;Inherit;True;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;26;-5813.942,495.2551;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LengthOpNode;27;-5523.047,496.3609;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-5310.595,775.2496;Half;False;Property;_Rotator;Rotator;3;0;Create;True;0;0;False;0;0;-0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-5321.835,495.3635;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-5029.282,502.1273;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;25;-4732.937,500.951;Inherit;True;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;33;-4517.848,64.59557;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;39;-4207,64;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;10;-3881.267,369.3107;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.PiNode;13;-3531.682,594.712;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;11;-3562.267,369.3107;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-3248,368;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3609.845,232.5232;Half;False;Property;_Scale;Scale;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;40;-3840,64;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;18;-2590.758,320.1011;Float;False;Property;_ScaleOffset;_ScaleOffset;1;0;Create;True;0;0;False;0;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-2961.24,369.4308;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;21;-3397.847,64.59557;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;-2333.67,239.6898;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-2643.034,61.44919;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-2334.781,437.3813;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;17;-2109.381,60.28758;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;37;-1792,64;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;38;-1488,64;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-985.9095,-85.39689;Half;False;Property;_AlphaClip;AlphaClip;4;0;Create;True;0;0;False;0;0.5;0.094;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-976,48;Inherit;True;Property;_MainTex;MainTex;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;60e6a6242029729458c6bb29f05e3f98;34b3040a34e1dfd4296ba2bc376ba8d2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-968.3179,-284.027;Float;False;Constant;_MainColor;MainColor;1;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClipNode;34;-512,48;Inherit;False;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;6;-938.2551,270.3732;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1;-206.7,25.1;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;49.29999,25.10001;Half;False;True;-1;2;ASEMaterialInspector;0;1;JianpingWang/Effect_Polar_ASE;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Transparent=RenderType;True;0;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;26;0;7;0
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;30;0;28;0
WireConnection;30;2;29;0
WireConnection;25;0;30;0
WireConnection;33;0;7;0
WireConnection;33;2;25;0
WireConnection;39;0;33;0
WireConnection;10;0;39;0
WireConnection;11;0;10;1
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;40;0;39;0
WireConnection;14;0;12;0
WireConnection;21;0;40;0
WireConnection;21;1;22;0
WireConnection;19;0;18;1
WireConnection;19;1;18;2
WireConnection;15;0;21;0
WireConnection;15;1;14;0
WireConnection;20;0;18;3
WireConnection;20;1;18;4
WireConnection;17;0;15;0
WireConnection;17;1;19;0
WireConnection;17;2;20;0
WireConnection;37;0;17;0
WireConnection;38;0;37;1
WireConnection;38;1;37;0
WireConnection;4;1;38;0
WireConnection;34;0;4;0
WireConnection;34;1;4;4
WireConnection;34;2;35;0
WireConnection;1;0;5;0
WireConnection;1;1;34;0
WireConnection;1;2;6;0
WireConnection;0;0;1;0
ASEEND*/
//CHKSM=7DA794DC0D3DED0C6414E5C3870AD72FDE5226B4