Shader "Unlit/CustomFogClean"   //ASE 整洁版，只为查找高度雾的水平问题。
{								//顶点的世界位置在顶点函数里面计算完后传递至片元里面，并不是动态的。   20200710
	Properties
	{
		_FogColor("FogColor", Color) = (1,1,1,1)
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

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float4 vertex : TEXCOORD2;
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
				v2f o = (v2f) 0;
				o.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.ase_texcoord.xy = v.ase_texcoord.xy;
				o.vertex = v.vertex;			
                				
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				fixed4 finalColor;

				float2 uv_MainTex = i.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 texColor = tex2D( _MainTex, uv_MainTex );


				half4 temp_cast_0 = (_FogDebug).xxxx;
				half4 temp_cast_1 = (_FogDebug).xxxx;
				half4 boolA = 0;                
				if( _FogDebug == 1.0 )
				boolA = _FogColor;
				else
				boolA = temp_cast_0;
				half4 FogColor = boolA;
				#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
				half4 lightColor0 = 0;
				#else //aselc
				half4 lightColor0 = _LightColor0;
				#endif //aselc


				
				half3 LightDir = UnityWorldSpaceLightDir(i.worldPos.xyz);
				LightDir = normalize( (LightDir * -1.0 ) );
				float3 ViewDir = UnityWorldSpaceViewDir(i.worldPos.xyz);
				ViewDir = normalize(ViewDir);

				half LOV = dot( LightDir , ViewDir );
				half smoothLOV = smoothstep( 0.0 , 1.0 , LOV);
				half LOVs = 0;

                half3 factor = length( UnityObjectToViewPos( i.vertex.xyz ));

				if( _SunDebug == 1.0 )
				LOVs = smoothLOV;
                half End2Start = _FogEnd - _FogStart;
				half FogFactor = saturate( ( ( (factor ) * ( -1.0 / End2Start ) ) + ( _FogEnd / End2Start ) ));
                half heightControl = 1.0 - saturate(((i.worldPos.y - _HeightControl) / _SmoothFog));

				half4 FogAndSunColor = lerp( FogColor , (lightColor0 * FogColor) + lightColor0, LOVs);
                half4 LinearFog = lerp( texColor , FogAndSunColor , 1.0 - FogFactor);

				half4 HeightFog = lerp( texColor , FogAndSunColor , heightControl);			
				half4 VheightFog = lerp( HeightFog , texColor , FogFactor);			


				half4 lerpResult205 = lerp( VheightFog , LinearFog , _FogBlend);
				
				
				finalColor = lerpResult205;
				return finalColor;
			}
			ENDCG
		}
	}

	
	
}