// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JianpingWang/Alpha_Blended_Ramp"
{
	Properties
	{
		_MainColor("MainColor", Color) = (1,1,1,1)
		_MainTex("MainTex", 2D) = "white" {}
		_RampTex("RampTex", 2D) = "white" {}
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseClip("NoiseClip", Range( 0 , 2)) = 0.2893383
		_EdgeColor("EdgeColor", Color) = (1,1,1,1)
		_EdgeWidth("EdgeWidth", Range( 0 , 1)) = 0.2587144
		_GLOW("GLOW", Range( 1 , 5)) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" }
	LOD 0

		CGINCLUDE
		#pragma target 2.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		Cull Off
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		
		
		
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

			uniform sampler2D _RampTex;
			uniform sampler2D _NoiseTex;
			uniform half4 _NoiseTex_ST;
			uniform float _NoiseClip;
			uniform float _EdgeWidth;
			uniform half4 _EdgeColor;
			uniform float _GLOW;
			uniform half4 _MainColor;
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;

			
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
				float2 uv_NoiseTex = i.ase_texcoord.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				half temp_output_7_0_g5 = ( 1.0 - _EdgeWidth );
				half temp_output_37_0 = saturate( ( ( ( ( tex2D( _NoiseTex, uv_NoiseTex ).r + 1.0 ) - _NoiseClip ) - temp_output_7_0_g5 ) / ( 1.0 - temp_output_7_0_g5 ) ) );
				half2 appendResult16 = (half2(temp_output_37_0 , 0.0));
				half4 tex2DNode8 = tex2D( _RampTex, appendResult16 );
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
				half4 lerpResult18 = lerp( ( ( tex2DNode8 * _EdgeColor ) * _GLOW ) , ( _MainColor * tex2DNode2 * i.ase_color ) , tex2DNode8.a);
				half4 appendResult38 = (half4(lerpResult18.rgb , ( _MainColor.a * tex2DNode2.a * i.ase_color.a * temp_output_37_0 )));
				
				
				finalColor = appendResult38;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
1921;1;1918;1056;2244.604;-79.82654;1.842646;True;False
Node;AmplifyShaderEditor.SamplerNode;34;-3300.552,559.1223;Inherit;True;Property;_NoiseTex;NoiseTex;3;0;Create;True;0;0;False;0;-1;51111c5dc886dd245a3bead11d028d66;51111c5dc886dd245a3bead11d028d66;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;12;-3328,784;Float;False;Property;_NoiseClip;NoiseClip;4;0;Create;True;0;0;False;0;0.2893383;0.31;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2813.397,858.8017;Float;False;Property;_EdgeWidth;EdgeWidth;7;0;Create;True;0;0;False;0;0.2587144;0.258;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2992,560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-2816,560;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-2535.397,862.8017;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;37;-2304,560;Inherit;True;Smoothstep_Simple;-1;;5;c58981667c12bb249a5ca7a24a096023;0;3;1;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1534.764,581.132;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;8;-1234.261,549.6479;Inherit;True;Property;_RampTex;RampTex;2;0;Create;True;0;0;False;0;-1;45e2b98cb63f4b947a05db41dbf15b79;45e2b98cb63f4b947a05db41dbf15b79;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;20;-1201.365,793.3452;Half;False;Property;_EdgeColor;EdgeColor;6;0;Create;True;0;0;False;0;1,1,1,1;1,0.8455282,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-774.7999,-92.60001;Half;False;Property;_MainColor;MainColor;0;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,0.6156863;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-858.7999,83.39999;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;-1;4994409df4e1e784685897e06ec96d68;42758299f2fa280499f99c8e12390590;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-727.7443,828.0951;Float;False;Property;_GLOW;GLOW;8;0;Create;True;0;0;False;0;2;2;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;3;-737.0645,283.3208;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-877.8777,587.0375;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-438.2894,581.1675;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-450.0645,69.32083;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;227.5618,51.35522;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-411.0619,308.9164;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1851.913,666.4677;Float;False;Property;_RampColorY;RampColorY;5;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;694.1187,48.62249;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1077.64,47.69374;Half;False;True;-1;2;ASEMaterialInspector;0;1;JianpingWang/Alpha_Blended_Ramp;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;False;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;False;-1;True;False;0;False;-1;0;False;-1;True;3;RenderType=Transparent=RenderType;IgnoreProjector=True;Queue=Transparent=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;9;0;34;1
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;30;0;29;0
WireConnection;37;1;11;0
WireConnection;37;7;30;0
WireConnection;16;0;37;0
WireConnection;8;1;16;0
WireConnection;19;0;8;0
WireConnection;19;1;20;0
WireConnection;45;0;19;0
WireConnection;45;1;47;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;4;2;3;0
WireConnection;18;0;45;0
WireConnection;18;1;4;0
WireConnection;18;2;8;4
WireConnection;25;0;1;4
WireConnection;25;1;2;4
WireConnection;25;2;3;4
WireConnection;25;3;37;0
WireConnection;38;0;18;0
WireConnection;38;3;25;0
WireConnection;0;0;38;0
ASEEND*/
//CHKSM=F173521EF3F2F577041B705A394B284991D941A0