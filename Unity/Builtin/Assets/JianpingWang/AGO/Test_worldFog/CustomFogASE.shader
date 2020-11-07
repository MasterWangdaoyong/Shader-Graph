// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "JianpingWang/CustomFog"
{
	Properties
	{
		_FogColor("FogColor", Color) = (0,0.2467189,1,1)
		_HeightControl("HeightControl", Float) = -12.3
		_SmoothFog("SmoothFog", Range( 0 , 1000)) = 20
		_FogStart("FogStart", Float) = 0
		_FogEnd("FogEnd", Float) = 100
		_FogBlend("FogBlend", Range( 0 , 0.5)) = 0.2
		_MainTex("MainTex", 2D) = "white" {}
		[Toggle]_FogDebug("FogDebug", Float) = 0
		[Toggle]_SunDebug("SunDebug", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 2.0
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
			#include "Lighting.cginc"
			#include "UnityShaderVariables.cginc"
			#include "AutoLight.cginc"


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
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
			};

			//This is a late directive
			
			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform half _FogDebug;
			uniform half4 _FogColor;
			uniform half _SunDebug;
			uniform half _HeightControl;
			uniform half _SmoothFog;
			uniform half _FogEnd;
			uniform half _FogStart;
			uniform half _FogBlend;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord1.xyz = ase_worldPos;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.ase_texcoord2 = v.vertex;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord.zw = 0;
				o.ase_texcoord1.w = 0;
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
				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 tex2DNode199 = tex2D( _MainTex, uv_MainTex );
				half4 temp_cast_0 = (_FogDebug).xxxx;
				half4 temp_cast_1 = (_FogDebug).xxxx;
				half4 ifLocalVar217 = 0;
				if( _FogDebug == 1.0 )
				ifLocalVar217 = _FogColor;
				else
				ifLocalVar217 = temp_cast_0;
				half4 FogColor116 = ifLocalVar217;
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				half4 ase_lightColor = 0;
				#else //aselc
				half4 ase_lightColor = _LightColor0;
				#endif //aselc
				float3 ase_worldPos = i.ase_texcoord1.xyz;
				half3 worldSpaceLightDir = UnityWorldSpaceLightDir(ase_worldPos);
				half3 normalizeResult135 = normalize( ( worldSpaceLightDir * -1.0 ) );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(ase_worldPos);
				ase_worldViewDir = normalize(ase_worldViewDir);
				half dotResult112 = dot( normalizeResult135 , ase_worldViewDir );
				half smoothstepResult182 = smoothstep( 0.0 , 1.0 , dotResult112);
				half ifLocalVar213 = 0;
				if( _SunDebug == 1.0 )
				ifLocalVar213 = smoothstepResult182;
				half4 lerpResult137 = lerp( FogColor116 , ( ( ase_lightColor * FogColor116 ) + ase_lightColor ) , ifLocalVar213);
				half4 SunColor120 = lerpResult137;
				half4 transform2 = mul(unity_ObjectToWorld,i.ase_texcoord2);
				half4 lerpResult202 = lerp( tex2DNode199 , SunColor120 , ( 1.0 - saturate( ( ( transform2.y - _HeightControl ) / _SmoothFog ) ) ));
				half3 unityObjectToViewPos15 = UnityObjectToViewPos( i.ase_texcoord2.xyz );
				half temp_output_20_0 = ( _FogEnd - _FogStart );
				half temp_output_27_0 = saturate( ( ( length( unityObjectToViewPos15 ) * ( -1.0 / temp_output_20_0 ) ) + ( _FogEnd / temp_output_20_0 ) ) );
				half4 lerpResult203 = lerp( lerpResult202 , tex2DNode199 , temp_output_27_0);
				half4 lerpResult204 = lerp( tex2DNode199 , SunColor120 , ( 1.0 - temp_output_27_0 ));
				half4 lerpResult205 = lerp( lerpResult203 , lerpResult204 , _FogBlend);
				
				
				finalColor = lerpResult205;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17500
1928;7;1905;1044;2691.465;821.2825;1;False;False
Node;AmplifyShaderEditor.CommentaryNode;184;-2456.327,-2277.166;Inherit;False;2185.901;979.3221;lerp_LightColor0;14;124;111;123;135;117;115;112;145;141;182;137;120;214;221;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-2328.313,-1798.351;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;111;-2359.503,-1950.874;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;216;-1032.282,673.3018;Inherit;False;Property;_FogDebug;FogDebug;7;1;[Toggle];Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;-971.899,473.7478;Inherit;False;Property;_FogColor;FogColor;0;0;Create;True;0;0;False;0;0,0.2467189,1,1;0,0.7183099,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;218;-1027.282,757.3018;Inherit;False;Constant;_Float1;Float 1;8;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;217;-710.282,681.3018;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;221;-2438.135,-1730.567;Inherit;False;778.6185;390.7413;ViewDir;6;220;134;131;133;129;132;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-2017.602,-1950.808;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;220;-1847.925,-1582.893;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;148;-2005.099,-1226.746;Inherit;False;1312.184;805.6169;z*(-1/(end-start)) + (end/end-start)),linearFog;10;22;21;20;18;27;23;24;38;19;200;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-690.7357,157.3372;Half;False;FogColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;135;-1825.135,-1951.016;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;115;-1863.369,-2122.347;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;149;-2006.831,-345.976;Inherit;False;1336.249;432.0955;worldspaceControlY,heightFog;6;2;7;10;65;9;14;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-1881.717,-2224.314;Inherit;False;116;FogColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;112;-1516.007,-1948.974;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;3;-2361.598,-299.2002;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;18;-1916.249,-707.8941;Inherit;False;Property;_FogStart;FogStart;3;0;Create;True;0;0;False;0;0;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;200;-1951.764,-1130.413;Inherit;False;565.1361;229;z;2;16;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1912.896,-607.1428;Inherit;False;Property;_FogEnd;FogEnd;4;0;Create;True;0;0;False;0;100;1000;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;215;-1378.626,-1813.835;Inherit;False;520;258;SunColorDebug;2;213;212;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-1328.626,-1670.835;Inherit;False;Constant;_Float3;Float 3;7;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;2;-1956.831,-295.976;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-1663.38,-714.0125;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-1519.962,-2116.326;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1915.775,-811.2401;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1691.092,-155.0349;Half;False;Property;_HeightControl;HeightControl;1;0;Create;True;0;0;False;0;-12.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-1325.626,-1761.835;Inherit;False;Property;_SunDebug;SunDebug;8;1;[Toggle];Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityObjToViewPosHlpNode;15;-1910.099,-1078.746;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;182;-1329.653,-1948.47;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;16;-1556.963,-1076.137;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1721.092,-31.03488;Half;False;Property;_SmoothFog;SmoothFog;2;0;Create;True;0;0;False;0;20;100;0;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;213;-1056.626,-1763.835;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-1437.975,-247.9133;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;-1365.467,-2070.104;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;22;-1427.512,-806.1926;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;9;-1264,-46.88056;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;137;-1068.272,-2221.506;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1250.131,-809.2852;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;24;-1430.142,-601.1293;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1022.142,-615.1293;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;14;-845.5823,-47.31317;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-513.4258,-2227.166;Inherit;False;SunColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;208;-617.9012,-48.32468;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;201;-375.5303,209.7746;Inherit;False;869.6557;641.963;FogBlend;3;203;202;219;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;199;-1067.823,278.572;Inherit;True;Property;_MainTex;MainTex;6;0;Create;True;0;0;False;0;-1;None;d0119a74bd820e746b7fc42a88ec31de;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;27;-865.3151,-615.6165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-640.3364,480.9471;Inherit;False;120;SunColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;219;-108.5584,429.7888;Inherit;False;562.3848;288.7487;把高度雾没到的地方混合一点点线性雾;3;57;204;205;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;202;-331.1631,281.6291;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;209;-670.845,-615.7444;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;203;-17.13602,316.7433;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-79.55839,610.5375;Inherit;False;Property;_FogBlend;FogBlend;5;0;Create;True;0;0;False;0;0.2;0.2;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;204;-15.63813,479.3866;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;134;-1834.468,-1692.844;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;132;-2013.868,-1693.162;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;205;268.8264,498.7888;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;133;-2394.465,-1499.844;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;131;-2192.505,-1502.138;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceCameraPos;129;-2406.327,-1692.416;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;623.3712,456.629;Half;False;True;-1;2;ASEMaterialInspector;100;1;JianpingWang/CustomFog;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;0;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
WireConnection;217;0;216;0
WireConnection;217;1;218;0
WireConnection;217;2;216;0
WireConnection;217;3;13;0
WireConnection;217;4;216;0
WireConnection;123;0;111;0
WireConnection;123;1;124;0
WireConnection;116;0;217;0
WireConnection;135;0;123;0
WireConnection;112;0;135;0
WireConnection;112;1;220;0
WireConnection;2;0;3;0
WireConnection;20;0;19;0
WireConnection;20;1;18;0
WireConnection;145;0;115;0
WireConnection;145;1;117;0
WireConnection;15;0;3;0
WireConnection;182;0;112;0
WireConnection;16;0;15;0
WireConnection;213;0;212;0
WireConnection;213;1;214;0
WireConnection;213;3;182;0
WireConnection;65;0;2;2
WireConnection;65;1;7;0
WireConnection;141;0;145;0
WireConnection;141;1;115;0
WireConnection;22;0;21;0
WireConnection;22;1;20;0
WireConnection;9;0;65;0
WireConnection;9;1;10;0
WireConnection;137;0;117;0
WireConnection;137;1;141;0
WireConnection;137;2;213;0
WireConnection;38;0;16;0
WireConnection;38;1;22;0
WireConnection;24;0;19;0
WireConnection;24;1;20;0
WireConnection;23;0;38;0
WireConnection;23;1;24;0
WireConnection;14;0;9;0
WireConnection;120;0;137;0
WireConnection;208;0;14;0
WireConnection;27;0;23;0
WireConnection;202;0;199;0
WireConnection;202;1;121;0
WireConnection;202;2;208;0
WireConnection;209;0;27;0
WireConnection;203;0;202;0
WireConnection;203;1;199;0
WireConnection;203;2;27;0
WireConnection;204;0;199;0
WireConnection;204;1;121;0
WireConnection;204;2;209;0
WireConnection;134;0;132;0
WireConnection;132;0;129;0
WireConnection;132;1;131;0
WireConnection;205;0;203;0
WireConnection;205;1;204;0
WireConnection;205;2;57;0
WireConnection;131;0;133;0
WireConnection;0;0;205;0
ASEEND*/
//CHKSM=98DBDF6CDFEF5CD96115D887E3F1E4C99F989850