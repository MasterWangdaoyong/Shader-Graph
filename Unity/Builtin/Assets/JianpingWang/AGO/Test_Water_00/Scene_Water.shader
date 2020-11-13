
Shader "Dodjoy/Scene/Scene_Water"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_WaterGradientTex("Gradient Tex", 2D) = "gray"{}
		_BumpTex ("Bump Texture", 2D) = "white"{}
		_BumpStrength ("Bump strength", Range(0.0, 1.0)) = 0.3
		_BumpDirection ("Bump direction(2 wave)", Vector)=(1,1,1,-1)
		_BumpTiling ("Bump tiling", Vector)= (0.025,0.025, 0.03,0.03)
		_Skybox("skybox", Cube)="white"{}
		_Specular("Specular Color", Color)=(1,1,1,0.5)
		_Shiness("_Shiness", range(8, 64)) = 32
		_ReflectPerturb("Reflect Perturb", Range(0, 1.0)) = 0.05
		_ReflectScale("Reflect Scale", Range(0, 1.0)) = 1
		_Trans("Transparent", Range(0, 1.0))= 0
	}
	
	SubShader
	{
		Tags { "Queue"="Transparent"  "IgnoreProjector"="True"	"RenderType"="Transparent"}
		
		// ColorMask RGB
		Blend SrcAlpha OneMinusSrcAlpha
				
		Pass
		{
			
			Tags { "LightMode" = "ForwardBase" }		

			CGPROGRAM		
			#pragma vertex vert
			#pragma fragment frag

			#define USE_GRADIENT_TEX

			#include "UnityCG.cginc"	
			
		
			struct appdata
			{
				float4 vertex : POSITION;
				float4 color  : COLOR;
			};

			struct v2f
			{
				half4 vertex    : SV_POSITION;
				half4 bumpCoords:TEXCOORD1;
				half4 viewVector:TEXCOORD2;  
				half4 worldPos : TEXCOORD4;
			};
			
			fixed4 _Color;
			fixed4 _WaterColor;
			half3 _WaterShallowColor;
			sampler2D _WaterGradientTex;
			float4 _WaterGradientTex_ST;
			sampler2D _BumpTex;
			half _BumpStrength;
			half4 _BumpDirection;			
			half4 _BumpTiling;
			
			samplerCUBE _Skybox;
			half4 _Specular;
			half _Shiness;
			half _ReflectPerturb;
			half _ReflectScale;
									
			fixed _Trans;		
			
			half _Depth;
						
			half3 PerPixelNormal(sampler2D bumpMap, half4 coords, half bumpStrength) 
			{
				float2 bump = (UnpackNormal(tex2D(bumpMap, coords.xy)) + UnpackNormal(tex2D(bumpMap, coords.zw))) * 0.5;
				float3 worldNormal;
				worldNormal.xz = bump.xy * bumpStrength;
				worldNormal.y = 1;
				return worldNormal;
			}
			
			inline half FastFresnel(half3 I, half3 N, half R0)
			{
				half icosIN = saturate(1-dot(I, N));
				half i2 = icosIN*icosIN;
				half i4 = i2*i2;
				return R0 + (1-R0)*(i4*icosIN);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.bumpCoords.xyzw = (o.worldPos.xzxz + _Time.yyyy * _BumpDirection.xyzw) * _BumpTiling.xyzw;
				o.viewVector.xyz = o.worldPos - _WorldSpaceCameraPos.xyz;
				o.viewVector.w = v.color.r;

				return o;
			}
						
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result;
				
				half3 worldNormal = normalize(PerPixelNormal(_BumpTex, i.bumpCoords, _BumpStrength));
				half3 viewVector = normalize(i.viewVector.xyz);
				half  alpha = i.viewVector.w;
				half3 halfVector = normalize(_WorldSpaceLightPos0.xyz - viewVector);

				half depth = 1 - alpha;      
				
				depth = max(0, depth - max(0, -viewVector.y));
				
				#ifdef USE_GRADIENT_TEX
				half2 gradUv = half2(depth, 1);
				half3 refractColor = tex2D(_WaterGradientTex, gradUv).rgb * _Color;
				#else
				half3 refractColor = lerp(_WaterShallowColor, _WaterColor , depth) * _Color;
				#endif
				
				half3 reflUV = reflect(viewVector, worldNormal);
				half3 reflectColor = texCUBE(_Skybox, reflUV).rgb;
				
				half fresnel = FastFresnel(-viewVector, worldNormal, _ReflectPerturb) * _ReflectScale;
				result.xyz = lerp(refractColor.xyz, reflectColor.xyz, fresnel);
				
				//spec
				half dotNH = max(0, dot(worldNormal, halfVector));
				half specularColor = _Specular.w * pow(dotNH, _Shiness) * (1 - i.viewVector.w);
				result.xyz += _Specular.xyz * specularColor;
								
				///计算透明度，
				result.a = 1-_Trans * alpha;	

				return result;
			}
			ENDCG
		}
	}
}
