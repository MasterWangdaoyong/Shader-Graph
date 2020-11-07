
#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGlobalIllumination.cginc"
#include "AutoLight.cginc"

#define OCCLUSION_ON
#define RIM_COLOR

///普通的流光效果
//#define EFFECT_FLOW_LIGHT
///带扰动的流光效果
//#define EFFECT_FLOW_DISTORT

#if defined(EFFECT_FLOW_LIGHT) || defined(EFFECT_FLOW_DISTORT)
	#define EFFECT_FLOW
#else
	#undef EFFECT_FLOW
#endif


struct DodVertexInput
{
	float4 vertex   : POSITION;
	float3 normal    : NORMAL;
	float2 uv0      : TEXCOORD0;
#ifdef _ANISO_ON
	float4 tangent   : TANGENT;
#endif

#if defined(OCCLUSION_ON) && defined(RIM_ON)
	fixed4 color : COLOR;
#endif
};



struct DodInput {
	float4 pos  : SV_POSITION;
	
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

#ifdef _ANISO_ON

	float3 tangent : TEXCOORD6;
	float3 binormal : TEXCOORD7;
	float3 posWorld : TEXCOORD8;
	
#else

	float3 posWorld : TEXCOORD6;
	
#endif
};

///先放在这，需要扩展的时候，在同一改为自定义的接口
struct BrdfSurfaceOutput {
	fixed3 Albedo;
	fixed3 Normal;
	fixed3 Emission;
	fixed3 SpecColor;
	fixed3 ReflectColor;
	half2 anisoXY;
	half3 worldRefl;
	
	#ifdef _ANISO_ON
	half3 tangent;
	half3 binormal;
	#endif
	
	fixed Alpha;
	
	#ifdef RIM_ON
	half RimFresnel;
	#endif
	
	#if defined(OCCLUSION_ON) && defined(RIM_ON)
	half Occlusion;
	#endif

	fixed Skin;
};

fixed3 _Color;
fixed3 _AnisoSpecColor1;
fixed3 _AnisoSpecColor2;

sampler2D _MainTex;
float4    _MainTex_ST;

fixed _DiffWrap;
half _DiffScale;
	
sampler2D _SpecTex;
sampler2D _SpecTex2;
half _SpecShininess;
half _SpecRoughness;
half _SpecScale;

sampler2D _BumpTex;

sampler2D _SkinTex;
float _AttenScale;

sampler2D _EmissTex;
half _EmissScale;
half _RimBias;
half _RimRoughness;
half3 _RimColor;
half _RimScale;

sampler2D _ReflectTex;
half _ReflectScale;
fixed _ReflectContrast;
half _ReflectRoughness;

half4 _AnisoCtrl;
half4 _AnisoCtrl2;

///扰动
sampler2D _AnisoTex;
half _AnisoRandScale;
half _AnisoRandScale2;


///妆容贴图
sampler2D _EyeTex;
half4 _UvOffsetEyeTex;
half4 _UvScaleEyeTex;

sampler2D _MouthTex;
half4 _UvOffsetMouthTex;
half4 _UvScaleMouthTex;

sampler2D _EyeBrowTex;
half4 _UvOffsetEyeBrowTex;
half4 _UvScaleEyeBrowTex;

sampler2D _TattooTex;
half4 _UvOffsetTattooTex;
half4 _UvScaleTattooTex;

sampler2D _MustacheTex;
half4 _UvOffsetMustacheTex;
half4 _UvScaleMustacheTex;

#ifdef USE_DOD_SHADOW
sampler2D _DodShadowTex;
float4x4 _DodShadowMatrix;
half 	 _DodShadowIntensity;
#endif


half _EmissionOn;
half _ReflectOn;
half  _Specular1Open;
half  _Specular2Open;


#ifdef EFFECT_FLOW

half _FlowLightOn;

///遮罩，控制哪些地方可以有流光
sampler2D _FlowLightMaskTex;
sampler2D _FlowLightTex;
float4    _FlowLightTex_ST;

#ifdef EFFECT_FLOW_LIGHT
half  _FlowLightScale;
half3 _FlowLightColor;
half2 _FlowLightSpeed;
#endif

#ifdef EFFECT_FLOW_DISTORT
#endif

#endif

#ifdef CUT_OFF
fixed _Cutoff;
#endif

//-------------------------------------------------------------------------------------
// counterpart for NormalizePerPixelNormal
// skips normalization per-vertex and expects normalization to happen per-pixel
half3 NormalizePerVertexNormal (float3 n) // takes float to avoid overflow
{
	return normalize(n);
}

half3 DodShadeSHPerVertex (half3 normal)
{
	return max(half3(0,0,0), ShadeSH9 (half4(normal, 1.0)));
}

inline half3 DodVertexGIForward(half3 normalWorld)
{
    half3 ambient = 0;
    
	#if UNITY_SHOULD_SAMPLE_SH
        ambient = DodShadeSHPerVertex (normalWorld);
    #endif
	
    return ambient;
}


DodInput BrdfVert (DodVertexInput v)
{
	DodInput o;
    UNITY_INITIALIZE_OUTPUT(DodInput,o);
	
	float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
	
#ifdef _ANISO_ON
	
	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);	
	float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
	
	o.tangent = tangentToWorld[0];
	o.binormal = tangentToWorld[1];
	
#endif
	
	o.posWorld = posWorld;
	o.eyeVec.xyz = -NormalizePerVertexNormal(o.posWorld - _WorldSpaceCameraPos);
	o.normalWorld.xyz = normalWorld;
	
#if defined(OCCLUSION_ON) && defined(RIM_ON)
	o.eyeVec.w = v.color.r;
#endif
	
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv_MainTex.xy = TRANSFORM_TEX(v.uv0, _MainTex);
	
#ifdef EFFECT_FLOW
	o.uv_MainTex.zw = TRANSFORM_TEX(v.uv0, _FlowLightTex);
#endif
	
#ifdef USE_DOD_SHADOW
	o.shadowCoords = mul(_DodShadowMatrix, float4(posWorld, 1.0));
#else
	TRANSFER_SHADOW(o);
#endif

	o.ambient = DodVertexGIForward(normalWorld);

	UNITY_TRANSFER_FOG(o,o.pos);
	
	return o;
}


// Anisotropic GGX
//X TangentWorld
//Y BinormalWorld
// [Burley 2012, "Physically-Based Shading at Disney"]
half D_GGXaniso(half RoughnessX, half RoughnessY, half NoH, half3 H, half3 T, half3 B )
{
	half mx = RoughnessX * RoughnessX;
	half my = RoughnessY * RoughnessY;
	half XoH = dot( T, H );
	half YoH = dot( B, H );
	half d = XoH*XoH / (mx*mx) + YoH*YoH / (my*my) + NoH*NoH;
	return 1.0 / ( mx*my * d*d );
}

half3 RandTangent(half3 t, half3 n, half3 rand)
{
	t = t + n*rand;
	return normalize(t);
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
	half a = roughness;
	half a2 = a*a;
	
	half d = nh * nh * (a2 - 1.h) + 1.00001h;
	half specularTerm = a / (lh * (1.5h + roughness) * d);
	return specularTerm;
}

#ifdef MRT_ENABLE

struct PS_OUTPUT
{
	fixed4 dest0 : SV_Target0;
	fixed  dest1 : SV_Target1;
};

inline fixed get_lumience(fixed3 c)
{
	return dot( c, fixed3(0.22, 0.707, 0.071) );
}

#else
#define PS_OUTPUT fixed4
#endif

half ToonEffectNdL(half val)
{
	fixed multi = val * val;
	fixed temp  = multi + 0.187;
	return multi / temp * 1.03;
}

half3 ToonEffect(half3 val)
{
#if defined(TOON_EFFECT)
	half v = max(max(val.x,val.y), val.z) + 0.01;
	v = ToonEffectNdL(v)/v;
	return val*v;
#else
	return val;
#endif
}



#ifdef _ANISO_ON
inline PS_OUTPUT UnityBrdfLight (BrdfSurfaceOutput s, half3 viewDir, 
				UnityLight light, UnityIndirect indirect, 
				half3 tangent, half3 binormal, fixed atten)
#else
inline PS_OUTPUT UnityBrdfLight (BrdfSurfaceOutput s, half3 viewDir, 
				UnityLight light, UnityIndirect indirect, fixed atten)
#endif
{
	fixed nl = max (0, dot (s.Normal, light.dir));
	fixed diff = max(0, (nl + _DiffWrap) / (1 + _DiffWrap));

	//shadow:
	fixed shadow = ( nl * atten + 0.5 ) / ( 1 + 0.5 );

	fixed4 c;
	c.rgb = fixed3(0,0,0);
	
#ifdef DIFFUSE_ON
	//half3 baseFactor = light.color * diff;
	
	//如果有皮肤，则要分开计算漫反射系数
	#ifdef SKIN_ON
	half diffAtten = max(lerp(_AttenScale, 1, nl) * atten, _AttenScale);
	half3 baseFactor = light.color * diff * (1 - s.Skin) * shadow + light.color * diffAtten * s.Skin;
	#else
	half3 baseFactor = light.color * diff  * shadow;
	#endif
	
#else
	half3 baseFactor = half3(0,0,0);
#endif
	
	#if defined(OCCLUSION_ON) && defined(RIM_ON)
		half occlusion = s.Occlusion;
	#else
		half occlusion = 1;
	#endif

#ifdef ENVLIGHT_ON
#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	baseFactor += indirect.diffuse;		//为了统一光照,环境光也和diffuse一起放大缩小
#endif
#endif

#if defined(_ANISO_ON) || defined(SPEC_ON)
	half3 halfDir = normalize (light.dir + viewDir);	
	half nh = max (0, dot (s.Normal, halfDir));	
#endif
	

#ifdef MRT_ENABLE
	fixed3 lumience = 0;
#endif

#if  defined(SPEC_ON) && defined(_ANISO_ON)	
	half ansioSpec = D_GGXaniso(_AnisoCtrl.x , _AnisoCtrl.y, nh, halfDir, tangent, RandTangent(binormal, s.Normal, s.anisoXY.x)) * _AnisoCtrl.z * nl * s.SpecColor.r * _Specular1Open;	
	half anisoSpec2 = D_GGXaniso(_AnisoCtrl2.x , _AnisoCtrl2.y, nh, halfDir, 
		tangent, RandTangent(binormal, s.Normal, s.anisoXY.y)) * _AnisoCtrl2.z * nl * s.SpecColor.g * _Specular2Open;
	
	c.rgb += (ansioSpec * _AnisoSpecColor1 + anisoSpec2*_AnisoSpecColor2) * s.Albedo * light.color * _Color * nl * atten;
	
#else

	#ifdef SPEC_ON
		half lh = max(0.32h, dot(light.dir, halfDir));
		half spec = GGX_Spec(nh, lh, _SpecRoughness)* _SpecScale;	
	
		fixed3 specTerm = s.SpecColor * spec * light.color * nl * atten;
		c.rgb += specTerm;

	#ifdef MRT_ENABLE
		lumience += specTerm;
	#endif
	
	#endif

#endif

#ifdef _ANISO_ON
c.rgb += ToonEffect(s.Albedo * _Color * baseFactor*_DiffScale);
#else
c.rgb += ToonEffect(s.Albedo * baseFactor*_DiffScale);
#endif


#ifdef REFLECT_MAP_ON				

	#if defined(RIM_ON) && !defined(RIM_COLOR)
		half3 grazingTerm = half3(1,1,1);
		s.ReflectColor = lerp(s.ReflectColor, grazingTerm, s.RimFresnel);
	#endif
	
	fixed3 reflectTerm = indirect.specular * s.ReflectColor * _ReflectScale;
	c.rgb += reflectTerm;

	#ifdef MRT_ENABLE0
		lumience += reflectTerm;
	#endif
#endif

#if defined(RIM_ON) && defined(RIM_COLOR)						
	fixed3 rimTerm = s.Albedo * _RimColor * s.RimFresnel * (occlusion * _RimScale);
	c.rgb += rimTerm;
#endif


#if defined(EMISS_MAP_ON)
	c.rgb += s.Emission;
#endif


	#ifdef MRT_ENABLE
		lumience += s.Emission;
		//lumience += s.Emission;
	#endif
	
	c.a = s.Alpha;
	
	#ifdef MRT_ENABLE
	PS_OUTPUT ps_out;
	ps_out.dest0 = c;
	ps_out.dest1 = get_lumience(lumience);
	
	return ps_out;
	#else
	return c;
	#endif
}


inline PS_OUTPUT DodLightingBrdf (BrdfSurfaceOutput s, half3 viewDir, UnityGI gi, fixed atten)
{
	PS_OUTPUT c;
	
	#ifdef _ANISO_ON
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect, s.tangent, s.binormal, atten);
	#else
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect, atten);
	#endif
	
	return c;
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

fixed4 GetMaskAtlas(sampler2D atlasTex, half4 uvOffset, half4 uvScale, half2 uv)
{
	float2 uvOffsetSrc = (uv - uvOffset.xy)/uvScale.xy;
	
	//判断是否超过边界
	float2 uvOffsetMask = step(uvOffsetSrc, float2(1,1));
	uvOffsetMask = uvOffsetMask * step(float2(0, 0), uvOffsetSrc);
	
	#ifdef MAKS_TEST_MODE
		uvScale.zw = half2(1,1);
		uvOffset.zw = half2(0, 0);
	#endif
	
	half2 uvAtlas = uvOffsetSrc * uvScale.zw + uvOffset.zw;
	return uvOffsetMask.x*uvOffsetMask.y * GetTexture(atlasTex, uvAtlas);
}

#define GetAndMaskColor(tex, uv) \
	maskColor = GetMaskAtlas(_##tex, _UvOffset##tex, _UvScale##tex, uv); \
	baseColor = maskColor.rgba * maskColor.a + baseColor * (1-maskColor.a);

fixed4 GetBaseColor(half2 uv)
{
	fixed4 baseColor = GetTexture (_MainTex, uv).rgba;
	fixed4 maskColor;
	
	#ifdef MASK_EYE_TEX
	GetAndMaskColor(EyeTex, uv);
	#endif
	
	#ifdef MASK_MOUTH_TEX
	GetAndMaskColor(MouthTex, uv);
	#endif
		
	#ifdef MASK_EYEBROW_TEX
	GetAndMaskColor(EyeBrowTex, uv);
	#endif
	
	#ifdef MASK_TATTOO_TEX
	GetAndMaskColor(TattooTex, uv);
	#endif
	
	#ifdef MASK_MUSTACHE_TEX
	GetAndMaskColor(MustacheTex, uv);
	#endif
	
	return baseColor;
}

#if defined(EFFECT_FLOW_LIGHT)

half3 dod_flow_effect(DodInput IN)
{
	half flowMask = MaxColor(tex2D(_FlowLightMaskTex, IN.uv_MainTex.xy).rgb) * _FlowLightScale;
	half time = _Time.y;
	half2 lightUV = _FlowLightSpeed * time + IN.uv_MainTex.zw;
	return tex2D(_FlowLightTex, lightUV).rgb * _FlowLightColor * flowMask * _FlowLightOn;
}

#elif defined(EFFECT_FLOW_DISTORT)

half3 dod_flow_effect(DodInput IN)
{
	return half3(0,0,0);
}

#endif

BrdfSurfaceOutput dod_surf (DodInput IN) {
	
	BrdfSurfaceOutput o;
	UNITY_INITIALIZE_OUTPUT(BrdfSurfaceOutput, o);
	
    fixed4 allColor = GetBaseColor(IN.uv_MainTex.xy);

#ifdef CUT_OFF
	clip(allColor.a - _Cutoff);
	//o.Alpha = allColor.a * (1 + _Cutoff);
#else
	o.Alpha = allColor.a;
#endif

	
	fixed3 baseColor = allColor.rgb;
	
	#ifdef NORMAL_MAP_ON
	//o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex));
	#endif

	o.Normal = normalize(IN.normalWorld);

	o.Skin = MaxColor(GetTexture(_SkinTex, IN.uv_MainTex.xy).rgb);

#ifndef _ANISO_ON

#ifdef EMISS_MAP_ON
	
	///计算emisson		
	fixed3 emiss = GetTexture(_EmissTex, IN.uv_MainTex.xy).rgb;
#else
	fixed3 emiss = fixed3(0,0,0);
#endif

	fixed3 diffColor = min(1, baseColor + emiss);
	fixed emissMask = MaxColor(emiss) / MaxColor(diffColor);
	
	baseColor = diffColor * (1-emissMask);
		
	fixed specMask = MaxColor(GetTexture(_SpecTex, IN.uv_MainTex.xy).rgb);
	o.Emission = diffColor * emissMask * _EmissScale * _EmissionOn;
	
#ifdef EFFECT_FLOW
	o.Emission += dod_flow_effect(IN);
#endif
	
	o.SpecColor = baseColor * specMask;	
	
#ifdef REFLECT_MAP_ON
	fixed reflectMask = MaxColor(GetTexture (_ReflectTex, IN.uv_MainTex.xy).rgb);
	
	reflectMask = min(1, reflectMask * _ReflectContrast);		
	o.ReflectColor = baseColor * reflectMask * _ReflectOn;
	
	baseColor = baseColor * (1-reflectMask);
#endif
	
#else
	
	
	///变为spec mask
	fixed spec1 = MaxColor(GetTexture(_SpecTex, IN.uv_MainTex.xy).rgb);
	fixed spec2 = MaxColor(GetTexture(_SpecTex2, IN.uv_MainTex.xy).rgb);
	
	o.SpecColor  = fixed3(spec1, spec2, 0);
	
	half anisoRand = GetTexture(_AnisoTex, IN.uv_MainTex.xy).r - 0.5;
	o.anisoXY = half2(_AnisoCtrl.w + anisoRand*_AnisoRandScale, _AnisoCtrl2.w + anisoRand * _AnisoRandScale2);
	
	
#endif
	
	o.Albedo = baseColor;
		
	#ifdef _ANISO_ON
	o.tangent = normalize(IN.tangent);
	o.binormal = normalize(IN.binormal);
	
	#endif
	
	#if defined(OCCLUSION_ON) && defined(RIM_ON)
	o.Occlusion = IN.eyeVec.w;
	#endif

	return o;
}

half3 DodGetInputWorldPos(DodInput i)
{
	//如果是tanent,就分散到几个vector里
	return i.posWorld;
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
	d.worldPos = DodGetInputWorldPos(i);
	
	d.worldViewDir = i.eyeVec.xyz;
	//d.worldViewDir = normalize(i.eyeVec.xyz);
	//d.worldViewDir = i.eyeVec.xyz;
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
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, roughness);
	half3 specular = DodDecodeHDR(rgbm, unity_SpecCube0_HDR.w == 1, unity_SpecCube0_HDR.x);
	return specular;
}

inline UnityGI LightingBrdf_GI (
	inout BrdfSurfaceOutput s,
	DodUnityGIInput data)
{
	UnityGI gi = MyUnityGI_Base (data, 1.0, s.Normal);
	half3 reflUVW	= reflect(-data.worldViewDir, s.Normal);
	
	#ifdef RIM_ON
		half nv = saturate(_RimBias + dot(data.worldViewDir, s.Normal));
		half upTerm = 1;
		s.RimFresnel = DodFresnelLerpFast(nv) * upTerm;
		
		///如果是颜色，那么不影响正常的反射
		#ifndef RIM_COLOR
		half roughness  = lerp(_ReflectRoughness, _RimRoughness, s.RimFresnel);
		#else
		half roughness = _ReflectRoughness;
		#endif
	#else
		half roughness = _ReflectRoughness;
	#endif
	
	gi.indirect.specular = GetReflectIndirectSpecular(data, reflUVW, roughness);
	return gi;
}


#ifdef MRT_ENABLE
PS_OUTPUT BrdfFrag(DodInput i)
#else
PS_OUTPUT BrdfFrag(DodInput i): SV_Target
#endif
{
	

	BrdfSurfaceOutput s = dod_surf(i);		
	DodUnityGIInput data = GetGIInput(i);
	
/*
	PS_OUTPUT test;
	#ifdef MRT_ENABLE
	test.dest0 = data.atten;
	return test;
	#else
	return data.atten;
	#endif
*/
		
	UnityGI gi = LightingBrdf_GI (s, data);
	PS_OUTPUT c = DodLightingBrdf(s, data.worldViewDir, gi, data.atten);
	return c;
}

