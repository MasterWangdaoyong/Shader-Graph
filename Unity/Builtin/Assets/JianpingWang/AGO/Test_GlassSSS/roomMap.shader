// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "roomMap"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]_BumpMap("BumpMap", 2D) = "bump" {}
		_InteriorTex("InteriorTex", CUBE) = "white" {}
		_WindowAlpha("WindowAlpha", Range( 0 , 1)) = 0.4
		_LitRooms("LitRooms", Range( 0 , 1)) = 0.5
		_DarknessAmount("DarknessAmount", Range( 0 , 1)) = 0.14
		_ReflTex("ReflTex", CUBE) = "white" {}
		_ReflPow("ReflPow", Range( 0 , 1)) = 0.4
		_Glossiness("Glossiness", Range( 0 , 1)) = 0.5
		_Metallic("Metallic", Range( 0 , 1)) = 0
		[HideInInspector] _tex4coord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma only_renderers d3d11 glcore gles gles3 metal 
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			half2 vertexToFrag84;
			half3 vertexToFrag85;
			float4 uv_tex4coord;
		};

		uniform sampler2D _BumpMap;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform samplerCUBE _InteriorTex;
		uniform half _LitRooms;
		uniform half _DarknessAmount;
		uniform half _ReflPow;
		uniform samplerCUBE _ReflTex;
		uniform half _WindowAlpha;
		uniform half _Metallic;
		uniform half _Glossiness;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 uv0_MainTex = v.texcoord;
			uv0_MainTex.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			half4 appendResult9 = (half4(uv0_MainTex.x , uv0_MainTex.y , uv0_MainTex.x , 0.0));
			half4 temp_output_10_0 = ( half4( ase_vertex3Pos , 0.0 ) * appendResult9 );
			half4 ase_vertexTangent = v.tangent;
			half temp_output_154_0 = ( 1.0 - ase_vertexTangent.xyz.z );
			half3 appendResult12 = (half3(ase_vertexTangent.xyz.x , 0.0 , temp_output_154_0));
			half dotResult18 = dot( temp_output_10_0 , half4( appendResult12 , 0.0 ) );
			half2 appendResult20 = (half2(dotResult18 , temp_output_10_0.y));
			half2 appendResult25 = (half2(uv0_MainTex.z , uv0_MainTex.w));
			o.vertexToFrag84 = ( appendResult20 + appendResult25 );
			half4 appendResult158 = (half4(_WorldSpaceCameraPos , 1.0));
			half4 transform31 = mul(unity_WorldToObject,appendResult158);
			half4 temp_output_33_0 = ( ( temp_output_10_0 / appendResult9 ) - transform31 );
			half dotResult34 = dot( half4( appendResult12 , 0.0 ) , temp_output_33_0 );
			half3 appendResult15 = (half3(temp_output_154_0 , 0.0 , ase_vertexTangent.xyz.x));
			half dotResult38 = dot( temp_output_33_0 , half4( appendResult15 , 0.0 ) );
			half3 appendResult36 = (half3(dotResult34 , temp_output_33_0.y , dotResult38));
			o.vertexToFrag85 = appendResult36;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			half2 coord026 = i.vertexToFrag84;
			o.Normal = UnpackNormal( half4( UnpackNormal( tex2D( _BumpMap, coord026 ) ) , 0.0 ) );
			half2 appendResult66 = (half2(2.0 , 2.0));
			half2 appendResult68 = (half2(1.0 , 1.0));
			half2 appendResult46 = (half2(0.67957 , 0.785398));
			half2 appendResult50 = (half2(0.414214 , 0.732051));
			half2 break54 = ( ( floor( coord026 ) * appendResult46 ) + appendResult50 );
			half ind107 = ( frac( ( ( break54.x + break54.y ) + ( break54.x * break54.y ) ) ) * 8.0 );
			half4 appendResult70 = (half4(( ( frac( coord026 ) * appendResult66 ) - appendResult68 ) , -1.0 , ind107));
			half3 dir41 = i.vertexToFrag85;
			half3 temp_output_74_0 = ( 1.0 / dir41 );
			half4 break82 = ( half4( abs( temp_output_74_0 ) , 0.0 ) - ( appendResult70 * half4( temp_output_74_0 , 0.0 ) ) );
			half4 texCUBENode94 = texCUBE( _InteriorTex, ( appendResult70 + half4( ( min( min( break82.x , break82.y ) , break82.z ) * dir41 ) , 0.0 ) ).xyz );
			half3 appendResult106 = (half3(texCUBENode94.r , texCUBENode94.g , texCUBENode94.b));
			half ifLocalVar109 = 0;
			if( frac( ind107 ) > _LitRooms )
				ifLocalVar109 = _DarknessAmount;
			else if( frac( ind107 ) < _LitRooms )
				ifLocalVar109 = ( texCUBENode94.a * ( 1.0 + frac( ( ind107 * 5.2954 ) ) ) );
			half3 temp_output_116_0 = ( appendResult106 * ifLocalVar109 );
			half ifLocalVar127 = 0;
			if( frac( ind107 ) > _LitRooms )
				ifLocalVar127 = _ReflPow;
			else if( frac( ind107 ) < _LitRooms )
				ifLocalVar127 = _DarknessAmount;
			float4 uv0_MainTex = i.uv_tex4coord;
			uv0_MainTex.xy = i.uv_tex4coord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			half3 appendResult124 = (half3(uv0_MainTex.x , uv0_MainTex.y , uv0_MainTex.x));
			half4 tex2DNode5 = tex2D( _MainTex, coord026 );
			half temp_output_138_0 = saturate( ( tex2DNode5.a + ( 1.0 - _WindowAlpha ) ) );
			half4 lerpResult142 = lerp( ( half4( temp_output_116_0 , 0.0 ) + ( ifLocalVar127 * texCUBE( _ReflTex, ( dir41 * appendResult124 ) ) ) ) , tex2DNode5 , temp_output_138_0);
			half4 break168 = lerpResult142;
			half3 appendResult169 = (half3(break168.r , break168.g , break168.b));
			o.Albedo = appendResult169;
			half3 lerpResult147 = lerp( ( temp_output_138_0 * temp_output_116_0 ) , half3(0,0,0) , temp_output_138_0);
			o.Emission = lerpResult147;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17500
1928;7;1905;1044;3188.404;1052.605;5.228426;False;False
Node;AmplifyShaderEditor.CommentaryNode;155;-2150.9,226.3;Inherit;False;592.8289;455.4881;tx,tz;4;11;154;12;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;153;-2167.9,-191.7;Inherit;False;716.9999;397;pos;4;9;4;10;7;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-2117.9,-1.70002;Inherit;False;0;5;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TangentVertexDataNode;11;-2100.9,276.3;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;4;-1873.9,-141.7;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;9;-1839.9,14.29999;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.OneMinusNode;154;-1898.917,374.9692;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1727.9,297.3;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1619.9,-4.700012;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;156;-1319.159,-237.4159;Inherit;False;1307.44;478.0722;coord0;7;18;21;25;20;22;84;26;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;21;-1269.159,-187.4159;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;18;-1189.159,-1.41603;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;20;-994.159,1.583969;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;25;-987.926,107.6563;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-798.8589,7.583984;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexToFragmentNode;84;-588.5524,10.21992;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;87;-1839.353,1136.68;Inherit;False;2483.719;577.1791;Random;18;47;49;55;56;44;43;46;59;42;58;54;57;53;45;48;50;51;107;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-254.7193,3.656187;Half;False;coord0;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1789.353,1186.68;Inherit;False;26;coord0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;45;-1526.353,1339.68;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;False;0;0.785398;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1516.353,1262.68;Inherit;False;Constant;_Float1;Float 1;1;0;Create;True;0;0;False;0;0.67957;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-1529.353,1456.68;Inherit;False;Constant;_Float3;Float 3;1;0;Create;True;0;0;False;0;0.414214;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;161;-2247.328,705.7748;Inherit;False;772.7952;317.7991;cam;4;27;159;158;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FloorOpNode;42;-1308.396,1189.384;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;-1318.353,1279.68;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-1527.353,1542.68;Inherit;False;Constant;_Float4;Float 4;1;0;Create;True;0;0;False;0;0.732051;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;159;-2083.896,908.5739;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;27;-2197.328,755.7748;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;163;-1264.508,282.9475;Inherit;False;1548.15;505.9076;dir;7;162;35;34;36;85;41;38;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-1103.353,1274.68;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;50;-1319.353,1460.68;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-934.3528,1438.68;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;162;-1214.508,415.0598;Inherit;False;392.0458;184.0571;dist;2;32;33;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;158;-1883.896,757.5739;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;54;-741.8859,1438.467;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1164.508,465.0598;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;31;-1701.533,757.5756;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;15;-1725.071,525.7881;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-340.6339,1572.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-338.6339,1440.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;33;-996.4622,466.1169;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-108.6339,1467.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;35;-781.9149,609.8551;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DotProductOpNode;34;-743.8679,332.9475;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1795.729,1724.408;Inherit;False;1026;430;Enterance;10;70;64;65;67;63;66;68;72;71;164;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;38;-741.7555,467.174;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-114.6339,1583.859;Inherit;False;Constant;_Float5;Float 5;1;0;Create;True;0;0;False;0;8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;53;62.67413,1469;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-512.407,418.5561;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1742.729,1860.408;Inherit;False;Constant;_Float6;Float 6;1;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexToFragmentNode;85;-289.6299,421.45;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;213.3661,1463.859;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1745.729,2007.408;Inherit;False;Constant;_Float7;Float 7;1;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;63;-1537.729,1774.408;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;66;-1544.729,1858.408;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;93;-1806.417,2200.188;Inherit;False;2032.118;460.77;Ray;12;83;73;75;74;79;77;78;82;81;91;92;89;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;40.64171,416.1758;Inherit;False;dir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;377.8381,1458.648;Inherit;False;ind;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-1538.729,2000.408;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1333.729,1775.408;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-1756.417,2491.188;Inherit;False;41;dir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1735.481,2409.466;Inherit;False;Constant;_Float9;Float 9;1;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-1142.729,1776.408;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-1140.729,1880.408;Inherit;False;Constant;_Float8;Float 8;1;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;164;-1156.767,1990.226;Inherit;False;107;ind;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;74;-1520.417,2412.188;Inherit;False;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-918.7292,1776.408;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1013.417,2250.188;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;77;-1316.417,2411.188;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;78;-1010.417,2411.188;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;82;-834.4168,2410.188;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;112;221.2634,2698.874;Inherit;False;1039.712;279.6851;light;7;101;99;102;105;100;108;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMinOpNode;81;-519.4167,2410.188;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;274.2114,2779.841;Inherit;False;107;ind;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;102;271.2634,2859.559;Inherit;False;Constant;_Float11;Float 11;2;0;Create;True;0;0;False;0;5.2954;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;92;-388.861,2545.958;Inherit;False;41;dir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMinOpNode;83;-356.4167,2434.188;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-137.5237,2436.025;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;133;1055.889,3124.872;Inherit;False;1198.307;354.269;sky;5;121;124;118;119;117;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;534.2634,2845.559;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;101;706.2634,2844.559;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;121;1105.889,3272.141;Inherit;False;0;5;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;89;71.70135,2414.962;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;99;696.2729,2752.85;Inherit;False;Constant;_Float10;Float 10;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;481.4749,2387.278;Inherit;True;Property;_InteriorTex;InteriorTex;2;0;Create;True;0;0;False;0;-1;None;72d3e0d4cb90a1744a6463f3958df390;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;100;913.6729,2758.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;1387.586,3174.872;Inherit;False;41;dir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;139;1090.292,1541.968;Inherit;False;679.8531;280;wall;2;5;134;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;1336.289,2871.041;Inherit;False;107;ind;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;124;1409.889,3288.141;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;1208.42,2493.844;Inherit;False;107;ind;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;125;1588.289,2876.041;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;1091.975,2748.874;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;110;1444.809,2499.203;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;1405.292,1916.695;Inherit;False;Property;_WindowAlpha;WindowAlpha;3;0;Create;True;0;0;False;0;0.4;0.234;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;1485.292,1834.695;Inherit;False;Constant;_Float12;Float 12;6;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;134;1140.292,1613.695;Inherit;False;26;coord0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;114;1288.813,2676.268;Inherit;False;Property;_DarknessAmount;DarknessAmount;5;0;Create;True;0;0;False;0;0.14;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;1623.586,3203.872;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;113;1286.813,2592.268;Inherit;False;Property;_LitRooms;LitRooms;4;0;Create;True;0;0;False;0;0.5;0.341;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;131;1358.493,2981.543;Inherit;False;Property;_ReflPow;ReflPow;7;0;Create;True;0;0;False;0;0.4;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;1449.145,1591.968;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;False;0;-1;None;987e8a2415c3bd442ae9425db5d204b1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;172;2295.193,2823.743;Inherit;False;219;183;sky;1;132;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ConditionalIfNode;127;1848.289,2876.041;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;109;1686.42,2500.844;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;1933.196,3177.522;Inherit;True;Property;_ReflTex;ReflTex;6;0;Create;True;0;0;False;0;-1;None;fafe6e0295196ee4fba7a7f437ca1f71;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;106;858.0758,2361.174;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;140;1741.292,1861.695;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;171;1855.894,2315.033;Inherit;False;219;183;interior;1;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;1905.894,2365.033;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;2345.193,2873.743;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;1949.292,1696.695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;138;2135.292,1697.695;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;2568.809,2369.303;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;2411.254,1835.436;Inherit;False;26;coord0;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;142;2719.163,1580.445;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;144;2633.558,1813.635;Inherit;True;Property;_BumpMap;BumpMap;1;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;ee7fb6a9713941342ad443c87aa1a7fd;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;149;2190.142,2116.452;Inherit;False;Constant;_Vector0;Vector 0;8;0;Create;True;0;0;False;0;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;148;2199.186,2018.137;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;168;2878.252,1405.807;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;169;3190.252,1405.807;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;150;2923.637,1647.478;Inherit;False;Property;_Metallic;Metallic;9;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;151;2921.637,1723.478;Inherit;False;Property;_Glossiness;Glossiness;8;0;Create;True;0;0;False;0;0.5;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnpackScaleNormalNode;146;2971.085,1820.497;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;147;2406.168,2017.076;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;175;3346.233,1580.226;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;roomMap;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;5;d3d11;glcore;gles;gles3;metal;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;173;3577.732,1578.539;Inherit;False;186;100;20200629;0;;1,1,1,1;0;0
WireConnection;9;0;7;1
WireConnection;9;1;7;2
WireConnection;9;2;7;1
WireConnection;154;0;11;3
WireConnection;12;0;11;1
WireConnection;12;2;154;0
WireConnection;10;0;4;0
WireConnection;10;1;9;0
WireConnection;21;0;10;0
WireConnection;18;0;10;0
WireConnection;18;1;12;0
WireConnection;20;0;18;0
WireConnection;20;1;21;1
WireConnection;25;0;7;3
WireConnection;25;1;7;4
WireConnection;22;0;20;0
WireConnection;22;1;25;0
WireConnection;84;0;22;0
WireConnection;26;0;84;0
WireConnection;42;0;43;0
WireConnection;46;0;44;0
WireConnection;46;1;45;0
WireConnection;51;0;42;0
WireConnection;51;1;46;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;47;0;51;0
WireConnection;47;1;50;0
WireConnection;158;0;27;0
WireConnection;158;3;159;0
WireConnection;54;0;47;0
WireConnection;32;0;10;0
WireConnection;32;1;9;0
WireConnection;31;0;158;0
WireConnection;15;0;154;0
WireConnection;15;2;11;1
WireConnection;57;0;54;0
WireConnection;57;1;54;1
WireConnection;55;0;54;0
WireConnection;55;1;54;1
WireConnection;33;0;32;0
WireConnection;33;1;31;0
WireConnection;56;0;55;0
WireConnection;56;1;57;0
WireConnection;35;0;33;0
WireConnection;34;0;12;0
WireConnection;34;1;33;0
WireConnection;38;0;33;0
WireConnection;38;1;15;0
WireConnection;53;0;56;0
WireConnection;36;0;34;0
WireConnection;36;1;35;1
WireConnection;36;2;38;0
WireConnection;85;0;36;0
WireConnection;58;0;53;0
WireConnection;58;1;59;0
WireConnection;63;0;43;0
WireConnection;66;0;65;0
WireConnection;66;1;65;0
WireConnection;41;0;85;0
WireConnection;107;0;58;0
WireConnection;68;0;67;0
WireConnection;68;1;67;0
WireConnection;64;0;63;0
WireConnection;64;1;66;0
WireConnection;71;0;64;0
WireConnection;71;1;68;0
WireConnection;74;0;73;0
WireConnection;74;1;75;0
WireConnection;70;0;71;0
WireConnection;70;2;72;0
WireConnection;70;3;164;0
WireConnection;79;0;70;0
WireConnection;79;1;74;0
WireConnection;77;0;74;0
WireConnection;78;0;77;0
WireConnection;78;1;79;0
WireConnection;82;0;78;0
WireConnection;81;0;82;0
WireConnection;81;1;82;1
WireConnection;83;0;81;0
WireConnection;83;1;82;2
WireConnection;91;0;83;0
WireConnection;91;1;92;0
WireConnection;104;0;108;0
WireConnection;104;1;102;0
WireConnection;101;0;104;0
WireConnection;89;0;70;0
WireConnection;89;1;91;0
WireConnection;94;1;89;0
WireConnection;100;0;99;0
WireConnection;100;1;101;0
WireConnection;124;0;121;1
WireConnection;124;1;121;2
WireConnection;124;2;121;1
WireConnection;125;0;126;0
WireConnection;105;0;94;4
WireConnection;105;1;100;0
WireConnection;110;0;111;0
WireConnection;119;0;118;0
WireConnection;119;1;124;0
WireConnection;5;1;134;0
WireConnection;127;0;125;0
WireConnection;127;1;113;0
WireConnection;127;2;131;0
WireConnection;127;4;114;0
WireConnection;109;0;110;0
WireConnection;109;1;113;0
WireConnection;109;2;114;0
WireConnection;109;4;105;0
WireConnection;117;1;119;0
WireConnection;106;0;94;1
WireConnection;106;1;94;2
WireConnection;106;2;94;3
WireConnection;140;0;135;0
WireConnection;140;1;136;0
WireConnection;116;0;106;0
WireConnection;116;1;109;0
WireConnection;132;0;127;0
WireConnection;132;1;117;0
WireConnection;141;0;5;4
WireConnection;141;1;140;0
WireConnection;138;0;141;0
WireConnection;143;0;116;0
WireConnection;143;1;132;0
WireConnection;142;0;143;0
WireConnection;142;1;5;0
WireConnection;142;2;138;0
WireConnection;144;1;145;0
WireConnection;148;0;138;0
WireConnection;148;1;116;0
WireConnection;168;0;142;0
WireConnection;169;0;168;0
WireConnection;169;1;168;1
WireConnection;169;2;168;2
WireConnection;146;0;144;0
WireConnection;147;0;148;0
WireConnection;147;1;149;0
WireConnection;147;2;138;0
WireConnection;175;0;169;0
WireConnection;175;1;146;0
WireConnection;175;2;147;0
WireConnection;175;3;150;0
WireConnection;175;4;151;0
ASEEND*/
//CHKSM=9435F5CFAC9CF4527E7C74E1D283309F049B0F78