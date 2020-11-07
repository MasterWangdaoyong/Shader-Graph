#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGlobalIllumination.cginc"
#include "AutoLight.cginc"

struct DodVertexInput
{
	float4 vertex   : POSITION;
	float3 normal    : NORMAL;
	float2 uv0      : TEXCOORD0;
	float4 tangent   : TANGENT;
};

struct DodInput 
{
	float4 pos : SV_POSITION;
	half4 uv_MainTex : TEXCOORD0;	
	float4 eyeVec : TEXCOORD1;
	half3 ambient : TEXCOORD2;
	float3 normalWorld :TEXCOORD3;
	
	#ifdef USE_DOD_SHADOW
	float4 shadowCoords: TEXCOORD4;
	#else
	UNITY_SHADOW_COORDS(4)
	#endif
	UNITY_FOG_COORDS(5)

	float3 tangent : TEXCOORD6;
	float3 binormal : TEXCOORD7;
	float3 posWorld : TEXCOORD8;
};

struct PBSSurfaceOutput 
{
	fixed3 Albedo;
	fixed3 Normal;
	fixed3 Emission;
	fixed3 SpecColor;
	fixed3 ReflectColor;
	fixed Alpha;
	half RimFresnel;
	half Smoothness;
	fixed Skin;
	fixed Metallic;
};


sampler2D _MainTex;
float4    _MainTex_ST;

half _DiffScale;
half _DiffWrap;
half _SpecScale;

sampler2D _BumpTex;
float4 _BumpTex_ST;

sampler2D _SkinTex;

sampler2D _MetallicTex;
sampler2D _RoughTex;
half _Smoothness;
	
half _EmissGloss;
fixed4 _EmissColor;
sampler2D _EmissTex;
half _EmissScale;
half _RimBias;
half _RimRoughness;
half3 _RimColor;
half _RimScale;

half _ToonScale;
half _AttenScale;

half _ReflectScale;
fixed _ReflectContrast;
half _ReflectRoughness;
fixed4 _ReflectColor;

#ifdef USE_DOD_SHADOW
sampler2D _DodShadowTex;
float4x4 _DodShadowMatrix;
half 	 _DodShadowIntensity;
#endif

#ifdef CUT_OFF
fixed _Cutoff;
#endif

inline half3 DodVertexGIForward(half3 normalWorld)
{
    half3 ambient = 0;
    
	#if UNITY_SHOULD_SAMPLE_SH
        ambient = max(half3(0, 0, 0), ShadeSH9(half4(normalWorld, 1.0)));
    #endif
	
    return ambient;
}

inline half DodPow4 (half x)
{
    return x*x*x*x;
}


inline half DodFresnelLerpFast (half cosA)
{
    half t = DodPow4 (1 - cosA);
	return t;
}

inline half GGX_Spec(half nh , half lh, half roughness)
{		
	// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
	// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
	// https://community.arm.com/events/1155
	half a = roughness * roughness;
	half a2 = a* a;
	
	half d = nh * nh * (a2 - 1.f) + 1.00001f;
	half specularTerm = a / (lh * (1.5h + roughness) * d);

	return specularTerm;
}

inline float DodSmithJointGGXVisibilityTerm(float NdotL, float NdotV, float roughness)
{
	float a = roughness;
    float lambdaV = NdotL * (NdotV * (1 - a) + a);
    float lambdaL = NdotV * (NdotL * (1 - a) + a);

#if defined(SHADER_API_SWITCH)
    return 0.5f / (lambdaV + lambdaL + 1e-4f); 
#else
    return 0.5f / (lambdaV + lambdaL + 1e-5f);
#endif
}

inline float DodGGXTerm (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f;
    return UNITY_INV_PI * a2 / (d * d + 1e-7f);                                   
}


half ToonEffectNdL(half val)
{
	fixed multi = val * val;
	fixed temp = multi + 0.187;
	return multi / temp * 1.03;
}


half3 ToonEffect(half3 val)
{
	half v = max(max(val.x, val.y), val.z) + 0.01;
	v = ToonEffectNdL(v) / v;
	return v;
}

fixed MaxColor(fixed3 color)
{
	return max(max(color.r,color.g), color.b);
}

fixed4 GetTexture(sampler2D tex, half2 uv)
{
#if defined(TEX_HIGH) && (SHADER_TARGET >= 30)
	half4 uv4;
	uv4.xy = uv;
	uv4.w = 0;
	return tex2Dlod(tex, uv4);
#else
	return tex2D(tex, uv);
#endif
}

inline fixed4 UnityPBSLight(PBSSurfaceOutput s, half3 viewDir, UnityLight light, UnityIndirect indirect, half atten)
{
	fixed4 c;
	c.rgb = fixed3(0, 0, 0);

	fixed nl = max(0, dot(s.Normal, light.dir));

#ifdef DIFFUSE_ON
	half diffBody = nl;
	fixed wrap = (nl + _DiffWrap) / (1 + _DiffWrap);
	half diffSkin = max(lerp(_AttenScale, 1, wrap) * atten, _AttenScale);
	half3 baseFactor = light.color * diffBody * atten * (1 - s.Skin) + light.color * diffSkin * s.Skin;
#else
	half3 baseFactor = half3(0, 0, 0);
#endif

#if defined(ENVLIGHT_ON) && defined(UNITY_LIGHT_FUNCTION_APPLY_INDIRECT)
	baseFactor += indirect.diffuse;
#endif

	half3 diffColor = s.Albedo * (1 - s.Metallic) * baseFactor * _DiffScale;
#ifdef TOON_EFFECT
	half3 toonColor = ToonEffect(diffColor);
	toonColor = lerp(1, toonColor, _ToonScale);
	c.rgb += diffColor * (1 - s.Skin) + (diffColor * s.Skin) * toonColor;
#else
	c.rgb += diffColor;
#endif
	

#ifdef SPEC_ON
	half3 halfDir = normalize(light.dir + viewDir);
	half nh = max(0, dot(s.Normal, halfDir));
	half nv = max(0, dot(s.Normal, viewDir));
	half lh = max(0.32h, dot(light.dir, halfDir));

	/*
	half spec = GGX_Spec(nh, lh, 1 - _Smoothness) * _SpecScale ;
	fixed3 specTerm = FresnelTerm(s.SpecColor, lh) * spec * nl * light.color;
	c.rgb += specTerm;
	*/

	float roughness = (1 - s.Smoothness) * (1 - s.Smoothness);
	roughness = max(roughness, 0.002);
	float V = DodSmithJointGGXVisibilityTerm(nl, nv, roughness);
	float D = DodGGXTerm(nh, roughness);
	float specTerm = V * D * UNITY_PI;
	specTerm = max(0, specTerm * nl);

	float3 specColorm = lerp (half3(0.220916301, 0.220916301, 0.220916301), s.Albedo, s.Metallic);
	fixed3 spec = specTerm * light.color * FresnelTerm(specColorm, lh);
	c.rgb += spec;
#endif
	

#ifdef REFLECT_MAP_ON
	fixed3 reflectTerm = indirect.specular * s.ReflectColor * _ReflectScale;
	c.rgb += reflectTerm;
#endif

#ifdef RIM_ON					
	fixed3 rimTerm = s.Albedo * _RimColor * s.RimFresnel * _RimScale;
	c.rgb += rimTerm;
#endif

	c.rgb += s.Emission;

	c.a = s.Alpha;

	return c;
}


PBSSurfaceOutput dod_surf(DodInput IN) {

	PBSSurfaceOutput o;
	UNITY_INITIALIZE_OUTPUT(PBSSurfaceOutput, o);
	
	fixed4 allColor = GetTexture(_MainTex, IN.uv_MainTex.xy).rgba;

#ifdef CUT_OFF
	clip(allColor.a - _Cutoff);
#endif

	fixed3 baseColor = allColor.rgb;
	o.Alpha = allColor.a;

	//将法线从切线空间转到世界空间
	float3x3 tangentTransform = float3x3(IN.tangent, IN.binormal, IN.normalWorld);
	float3 normalLocal = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex));
	o.Normal = normalize(mul(normalLocal, tangentTransform));
	
	fixed3 roughMask = GetTexture(_RoughTex, IN.uv_MainTex.xy).rgb;
	o.Smoothness = (1 - MaxColor(roughMask.rgb)) * _Smoothness;

	fixed3 metallicMask = GetTexture(_MetallicTex, IN.uv_MainTex.xy).rgb;
	o.SpecColor = baseColor * metallicMask;
	o.Metallic = MaxColor(metallicMask);
#ifdef TOON_EFFECT
	o.Skin = MaxColor(GetTexture(_SkinTex, IN.uv_MainTex.xy).rgb); 
#endif

#ifdef EMISS_MAP_ON
	fixed emissMask = MaxColor(GetTexture(_EmissTex, IN.uv_MainTex.xy).rgb);
	fixed3 emiss = allColor * emissMask;
	o.Emission = pow(emiss, _EmissGloss) * _EmissScale;
	baseColor = baseColor * (1 - emissMask);
#endif

#ifdef REFLECT_MAP_ON
	o.ReflectColor = baseColor * MaxColor(metallicMask);
	//baseColor = baseColor * (1 - reflectMask);
#endif

	o.Albedo = baseColor;

	return o;
}

struct DodUnityGIInput
{
    UnityLight light; // pixel light, sent from the engine

    float3 worldPos;
    half3 worldViewDir;
    half atten;
    half3 ambient;
	
	// HDR cubemap properties, use to decompress HDR texture
    float4 probeHDR[1];
};


inline UnityLight DodMainLight()
{
	UnityLight l;
	l.color = _LightColor0.rgb;
	l.dir = _WorldSpaceLightPos0.xyz;
	l.ndotl = 0; // Not used
	return l;
}

#ifdef USE_DOD_SHADOW
inline half DodSampleShadow (float4 shadowCoord)
{
#if defined(UNITY_REVERSED_Z)
	float lightDepth = 1.0 - tex2Dproj(_DodShadowTex, shadowCoord).r;
	half shadow = shadowCoord.z < lightDepth ? 1.0 : _DodShadowIntensity;
	return shadow;
#else
	float lightDepth = tex2Dproj(_DodShadowTex, shadowCoord).r;
	return shadowCoord.z < lightDepth ? 1.0 : _DodShadowIntensity;
#endif
}

#endif

DodUnityGIInput GetGIInput(DodInput i)
{
	DodUnityGIInput d;
		
	d.light = DodMainLight();
	d.worldPos = i.posWorld;
	d.worldViewDir = i.eyeVec.xyz;
	d.ambient = i.ambient;
	d.probeHDR[0] = unity_SpecCube0_HDR;
	
#ifdef USE_DOD_SHADOW
	half atten = DodSampleShadow(i.shadowCoords);
#else
	half atten = SHADOW_ATTENUATION(i);
#endif
	
	d.atten = atten;
	
	return d;
}


inline UnityGI MyUnityGI_Base(DodUnityGIInput data, half occlusion, half3 normalWorld)
{
	UnityGI o_gi;
	ResetUnityGI(o_gi);
	
	o_gi.light = data.light;
	//o_gi.light.color *= data.atten;
	
	#if UNITY_SHOULD_SAMPLE_SH
		o_gi.indirect.diffuse = data.ambient;
	#endif
	
	return o_gi;
}

inline half3 DodDecodeHDR (half4 data, bool useAlpha, half scale)
{
	half alpha = useAlpha ? data.a : 1.0;
	return (scale * alpha) * data.rgb;
}

inline half3 GetReflectIndirectSpecular(DodUnityGIInput data, half3 worldRefl, half roughness)
{	
	half mip = roughness * UNITY_SPECCUBE_LOD_STEPS;
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, mip);
	half3 specular = DodDecodeHDR(rgbm, unity_SpecCube0_HDR.w == 1, unity_SpecCube0_HDR.x);
	return specular;
}

inline UnityGI LightingPBS_GI(inout PBSSurfaceOutput s, DodUnityGIInput data)
{
	UnityGI gi = MyUnityGI_Base (data, 1.0, s.Normal);
	half3 reflUVW = reflect(-data.worldViewDir, s.Normal);
	half roughness = 1 - s.Smoothness;
	//roughness = 1 - _Smoothness;
	#ifdef RIM_ON
		half nv = saturate(_RimBias + dot(data.worldViewDir, s.Normal));
		half upTerm = 1;
		s.RimFresnel = DodFresnelLerpFast(nv) * upTerm;
		
		///如果是颜色，那么不影响正常的反射
		#ifndef RIM_COLOR
		roughness  = lerp(roughness, _RimRoughness, s.RimFresnel);
		#endif
	#endif
	
	gi.indirect.specular = GetReflectIndirectSpecular(data, reflUVW, roughness);
	return gi;
}


DodInput PBSVert(DodVertexInput v)
{
	DodInput o;
	UNITY_INITIALIZE_OUTPUT(DodInput, o);

	float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);

	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);

	o.tangent = tangentToWorld[0];
	o.binormal = tangentToWorld[1];

	o.posWorld = posWorld;
	o.eyeVec.xyz = -normalize(o.posWorld - _WorldSpaceCameraPos);
	o.normalWorld.xyz = normalWorld;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv_MainTex.xy = TRANSFORM_TEX(v.uv0, _MainTex);

#ifdef USE_DOD_SHADOW
	o.shadowCoords = mul(_DodShadowMatrix, float4(posWorld, 1.0));
#else
	TRANSFER_SHADOW(o);
#endif

	o.ambient = DodVertexGIForward(normalWorld);
	UNITY_TRANSFER_FOG(o, o.pos);

	return o;
}


fixed4 PBSFrag(DodInput i) : SV_Target
{
	PBSSurfaceOutput s = dod_surf(i);
	DodUnityGIInput data = GetGIInput(i);
	UnityGI gi = LightingPBS_GI(s, data);

	return UnityPBSLight(s, data.worldViewDir, gi.light, gi.indirect, data.atten);
}