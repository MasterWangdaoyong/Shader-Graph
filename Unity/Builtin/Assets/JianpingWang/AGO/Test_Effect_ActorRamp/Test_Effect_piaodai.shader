// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/NewUnlitShader"
{
	Properties
	{
		_m("m", 2D) = "white" {}
		_a("a", 2D) = "white" {}
		_b("b", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		Blend One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _m;
		uniform float4 _m_ST;
		uniform sampler2D _a;
		uniform sampler2D _b;
		uniform sampler2D _TextureSample1;
		uniform float4 _TextureSample1_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv0_m = i.uv_texcoord * _m_ST.xy + _m_ST.zw;
			float2 panner3 = ( 1.0 * _Time.y * float2( 0,-1 ) + uv0_m);
			float2 panner12 = ( 1.0 * _Time.y * float2( 0,0 ) + (uv0_m*1.0 + 0.0));
			float2 panner19 = ( 1.0 * _Time.y * float2( 0,0 ) + (uv0_m*1.0 + 0.0));
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float4 color6 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
			o.Emission = ( ( ( ( tex2D( _m, ( panner3 + ( tex2D( _a, panner12 ).r + tex2D( _b, panner19 ).r ) ) ) * tex2D( _TextureSample1, uv_TextureSample1 ) ) * color6 ) * 2.0 ) * 1.0 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17000
201;243;1485;767;3066.38;255.4974;1.261668;True;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-3099.185,-97.10049;Float;True;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;23;-2758.917,488.5916;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;22;-2787.106,195.1961;Float;True;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;19;-2366.51,482.8543;Float;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;12;-2379.102,192.3553;Float;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;11;-2085.96,196.8221;Float;True;Property;_a;a;1;0;Create;True;0;0;False;0;61c0b9c0523734e0e91bc6043c72a490;7b472673f5a41124c9d9419a813e66ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-2073.368,487.321;Float;True;Property;_b;b;2;0;Create;True;0;0;False;0;3047639831e02ae498bc903a803924e5;7b472673f5a41124c9d9419a813e66ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-1654.063,217.521;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;3;-2385.845,-94.83601;Float;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1530.531,-94.62524;Float;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1161.971,-108.2041;Float;True;Property;_m;m;0;0;Create;True;0;0;False;0;7b472673f5a41124c9d9419a813e66ce;7b472673f5a41124c9d9419a813e66ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1159.465,113.2687;Float;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;ceeb95b0b7095774e88253d53882d9ba;7b472673f5a41124c9d9419a813e66ce;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;6;-605.8458,132.212;Float;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-602.0038,-102.0256;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-195.0659,-100.5811;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-158.4279,171.8054;Float;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;232.5706,-102.1789;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;27;251.3,170.2196;Float;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;581.2303,-104.2821;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1041.976,-164.454;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Unlit/NewUnlitShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;23;0;4;0
WireConnection;22;0;4;0
WireConnection;19;0;23;0
WireConnection;12;0;22;0
WireConnection;11;1;12;0
WireConnection;20;1;19;0
WireConnection;21;0;11;1
WireConnection;21;1;20;1
WireConnection;3;0;4;0
WireConnection;14;0;3;0
WireConnection;14;1;21;0
WireConnection;1;1;14;0
WireConnection;8;0;1;0
WireConnection;8;1;7;0
WireConnection;5;0;8;0
WireConnection;5;1;6;0
WireConnection;24;0;5;0
WireConnection;24;1;25;0
WireConnection;26;0;24;0
WireConnection;26;1;27;0
WireConnection;0;2;26;0
ASEEND*/
//CHKSM=72AAD62520F51646EFD2FE011508FBD7869B3BBB