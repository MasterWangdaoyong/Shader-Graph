// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "TOZ/Object/Interior/Standard" {
	Properties {
		_MainTex("Walls Albedo (RGB) Trans (A)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_InteriorTex("Interior Texture", CUBE) = "" {}
		_WindowAlpha("Window alpha", Range (0, 1)) = 0.4
		_LitRooms("Lit rooms quantity", Range (0, 1)) = 0.5
		_DarknessAmount("Dark rooms intensity", Range (0, 1)) = 0.14
		_ReflTex("Reflections", CUBE) = "" {}
		_ReflPow("Reflection power", Range (0, 1)) = 0.4
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard vertex:vert fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex, _BumpMap;
		uniform float4 _MainTex_ST;
		samplerCUBE _InteriorTex, _ReflTex;
		float _WindowAlpha, _LitRooms, _DarknessAmount, _ReflPow;
		half _Glossiness;
		half _Metallic;

		struct Input {
			float2 coord0 : TEXCOORD0;
			float3 dir : TEXCOORD1;
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			//Everything in Object Space to support angled walls
			float3 pos = v.vertex.xyz;
			pos *= _MainTex_ST.xyx;
			float3 tanW = v.tangent.xyz;
			float3 tx = float3(v.tangent.x, 0, -v.tangent.z);
			float3 tz = float3(-v.tangent.z, 0, v.tangent.x);
			o.coord0 = float2(dot(pos, tx), pos.y) + _MainTex_ST.zw;
			float3 cam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
			float3 dist = (pos / _MainTex_ST.xyx) - cam;
			o.dir = float3(dot(dist, tx), dist.y, dot(dist, tz));
		}

		void surf(Input IN, inout SurfaceOutputStandard o) {
			//Random
			float2 rnd = floor(IN.coord0) * float2(0.679570, 0.785398) + float2(0.414214, 0.732051);
			float ind = frac(rnd.x + rnd.y + rnd.x * rnd.y) * 8.0;
			//Enterance
			float2 frc = frac(IN.coord0);
			float4 ent = float4(frc * float2(2.0, 2.0) - float2(1.0, 1.0), -1.0, ind);
			//Ray
			float3 id = 1.0 / IN.dir;
			float3 k = abs(id) - ent * id;
			float kMin = min(min(k.x, k.y), k.z);
			ent.xyz += kMin * IN.dir;
			//Varied lights
			fixed4 interior = texCUBE(_InteriorTex, ent);
			float light = interior.a * (1.0 + frac(5.2954 * ind));
			interior.rgb *= (frac(ind) < _LitRooms) ? light : _DarknessAmount;
			//Reflections
			//Not enough texture interpolators, so we untile it to fix.
			fixed4 sky = texCUBE(_ReflTex, IN.dir * _MainTex_ST.xyx);
			sky *= (frac(ind) < _LitRooms) ? _DarknessAmount :  _ReflPow;
			//Walls
			fixed4 wall = tex2D(_MainTex, IN.coord0);
			wall.a = saturate(wall.a + (1.0 - _WindowAlpha));
			//Result
			fixed4 result = lerp(interior + sky, wall, wall.a);
			result.a = 1.0;
			o.Albedo = result.rgb;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.coord0));
			o.Emission =  lerp(interior.rgb * wall.a, float3(0, 0, 0), wall.a);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = result.a;
		}
		ENDCG
	}

	FallBack "TOZ/Object/Interior/Unlit"
}