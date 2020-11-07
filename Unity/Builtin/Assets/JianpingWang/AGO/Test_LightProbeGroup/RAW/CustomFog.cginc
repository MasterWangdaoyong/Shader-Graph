/**********************
@功能：自定义雾效
@作者：aiya
@时间：2019/8/28
**********************/   

#define CUSTOM_FOG_COORDS(index) float2 fogCoord : TEXCOORD##index;
#define CUSTOM_TRANSFER_FOG CalcFogCoord
#define CUSTOM_APPLY_FOG ApplyFog

uniform fixed4 _FogColor;
uniform float _DepthFogStart;
uniform float _DepthFogEnd;
uniform float _HeighFogStart;
uniform float _HeighFogEnd;
uniform float _HeighFogIntensity;
uniform float _FogIntensity;

uniform float _SkyboxFogHeight;
uniform float _SkyboxFogIntensity;

uniform fixed4 _DirectionalColor;
uniform float _DirectionalIntensity;

//计算雾
inline void CalcFogCoord(inout float2 fogCoord, float3 vertex)
{
	fogCoord = 0;
#if defined (DOD_FOG_NONE)
	return;
#endif

#if defined(FOG_SKY_BOX)
	//天空盒不做深度雾
	fogCoord.x = 0;

	//高度雾
	float3 worldPos = normalize(mul(unity_ObjectToWorld, vertex));
	fogCoord.y = saturate((1 -  worldPos.y / _SkyboxFogHeight));
	//fogCoord.y *= step(0.00001, worldPos.y);
#else
	//深度雾
	float3 viewPos = UnityObjectToViewPos(vertex);
	float z = length(viewPos);
	float factor = 0;
	#if defined(DOD_FOG_LINEAR)
	factor = (_DepthFogEnd - z) / (_DepthFogEnd - _DepthFogStart);
	#elif defined(DOD_FOG_EXP)
	factor = exp2(-abs(_FogIntensity * z));
	#elif defined(DOD_FOG_EXP2)
	factor = exp2(-abs(_FogIntensity * z) * abs(_FogIntensity * z));
	#endif
	fogCoord.x = saturate(factor);

	//高度雾
	float3 worldPos = mul(unity_ObjectToWorld, vertex);
	fogCoord.y = saturate(1 - (max(0, worldPos.y - _HeighFogStart) / _HeighFogEnd));
#endif
}

//混合雾的颜色
inline void ApplyFog(float2 fogCoord, float3 worldPos, inout fixed3 finalColor)
{
#if defined (DOD_FOG_NONE)
	return;
#endif

	float3 worldPosDir = normalize(worldPos);
	half3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
	
	float VoL = dot(viewDir, worldLightDir);
	float blendFactor = (VoL + 1) * 0.5 * _DirectionalIntensity;
	fixed4 blendColor = lerp(_FogColor, _DirectionalColor, blendFactor);

#if defined (FOG_SKY_BOX)
	//天空盒不需要深度雾
	finalColor = lerp(finalColor, lerp(finalColor, blendColor, fogCoord.y), _SkyboxFogIntensity);

#elif !defined(DOD_FOG_NONE)
	//先混合深度雾效
	fixed3 fogColor = lerp(blendColor, finalColor, fogCoord.x);
	//再混合高度雾
	finalColor = lerp(finalColor, fogColor, fogCoord.y);
#endif
}
