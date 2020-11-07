// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TOZ/Object/Interior/Unlit" {
	Properties {
		_MainTex("Walls Albedo (RGB) Trans (A)", 2D) = "white" {}
		_InteriorTex("Interior Texture", CUBE) = "" {}
		_WindowAlpha("Window alpha", Range (0, 1)) = 0.4
		_LitRooms("Lit rooms quantity", Range (0, 1)) = 0.5
		_DarknessAmount("Dark rooms intensity", Range (0, 1)) = 0.14
		_ReflTex("Reflections", CUBE) = "" {}
		_ReflPow("Reflection power", Range (0, 1)) = 0.4
	}

	SubShader {
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "DisableBatching" = "True" }
		LOD 250
		
		Pass {
			Name "BASE"
			Tags { "LightMode" = "Always" }

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog

			sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			samplerCUBE _InteriorTex, _ReflTex;
			float _WindowAlpha, _LitRooms, _DarknessAmount, _ReflPow;

			struct a2v {
				float4 vertex : POSITION;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 hPos : SV_POSITION;
				float2 coord0 : TEXCOORD0;
				float3 dir : TEXCOORD1;
				float3 refl : TEXCOORD2;
				UNITY_FOG_COORDS(4)
			};

			v2f vert (a2v v) {
				v2f o;
				o.hPos = UnityObjectToClipPos(v.vertex);
				//Everything in Object Space to support angled walls
				float3 pos = v.vertex.xyz;
				pos *= _MainTex_ST.xyx;
				float3 tx = float3(v.tangent.x, 0, -v.tangent.z);
				float3 tz = float3(-v.tangent.z, 0, v.tangent.x);
				o.coord0 = float2(dot(pos, tx), pos.y) + _MainTex_ST.zw;
				float3 cam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0)).xyz;
				float3 dist = (pos / _MainTex_ST.xyx) - cam;
				o.dir = float3(dot(dist, tx), dist.y, dot(dist, tz));
				float3 eye = WorldSpaceViewDir(v.vertex);
				float3 norm = UnityObjectToWorldNormal(v.normal);
				o.refl = reflect(-eye, norm);
				UNITY_TRANSFER_FOG(o, o.hPos);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				//Random
				float2 rnd = floor(i.coord0) * float2(0.679570, 0.785398) + float2(0.414214, 0.732051);
				float ind = frac(rnd.x + rnd.y + rnd.x * rnd.y) * 8.0;
				//Enterance
				float2 frc = frac(i.coord0);
				float4 ent = float4(frc * float2(2.0, 2.0) - float2(1.0, 1.0), -1.0, ind);
				//Ray
				float3 id = 1.0 / i.dir;
				float3 k = abs(id) - ent * id;
				float kMin = min(min(k.x, k.y), k.z);
				ent.xyz += kMin * i.dir;
				//Varied lights
				fixed4 interior = texCUBE(_InteriorTex, ent);
				float light = interior.a * (1.0 + frac(5.2954 * ind));
				interior.rgb *= (frac(ind) < _LitRooms) ? light : _DarknessAmount;
				//Reflections
				fixed4 sky = texCUBE(_ReflTex, i.refl);
				sky *= (frac(ind) < _LitRooms) ? _DarknessAmount :  _ReflPow;
				//Walls
				fixed4 wall = tex2D(_MainTex, i.coord0);
				wall.a = saturate(wall.a + (1.0 - _WindowAlpha));
				//Result
				//fixed4 sky = texCUBE(_ReflTex, i.refl) * _ReflPow;
				fixed4 result = lerp(interior + sky, wall, wall.a);
				result.a = 1.0;
				UNITY_APPLY_FOG(i.fogCoord, result);
				return result;
			}
			ENDCG
		}
	}

	FallBack "VertexLit"
}