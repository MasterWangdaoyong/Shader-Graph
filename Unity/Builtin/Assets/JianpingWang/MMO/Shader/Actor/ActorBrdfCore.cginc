
#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGlobalIllumination.cginc"
#include "AutoLight.cginc"
#include "../Scene/DodFog.cginc"


#define RIM_COLOR
#define OCCLUSION_ON


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

	DOD_FOG_COORDS(5)


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
	
	#ifdef HIGHLIGHT_ON
	half HighLightScale;
	#endif
	
	#if defined(OCCLUSION_ON) && defined(RIM_ON)
	half Occlusion;
	#endif

	#if defined(SKIN_ON)
	fixed Skin;
	#endif

	half2 fogCoord;
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
sampler2D _MaskTex;
half _SpecShininess;
half _SpecRoughness;
half _SpecScale;

sampler2D _BumpTex;

	
//sampler2D _EmissTex;
half _EmissScale;
half _RimBias;
half _RimRoughness;
half3 _RimColor;
half _RimScale;

//sampler2D _ReflectTex;
half _ReflectScale;
fixed _ReflectContrast;
half _ReflectRoughness;

half4 _AnisoCtrl;
half4 _AnisoCtrl2;

///扰动
//sampler2D _AnisoTex;
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

//透明裁剪
#ifdef CUT_OFF
fixed _Cutoff;
#endif


#ifdef USE_DOD_SHADOW
sampler2D _DodShadowTex;
float4x4 _DodShadowMatrix;
half 	 _DodShadowIntensity;
#endif


#ifdef EFFECT_FLOW

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


//高亮
uniform half3 _HighLightColor;
half _HighLightBias;

//渐变消失
fixed _FadeAlpha;

//阴影衰减
float _AttenScale;

#ifdef CUSTOM_MAIN_LIGHT

///角色自定义的光源颜色
half3 _ActorLightColor;
#endif


#ifdef CUSTOM_ENV_LIGHT_ON

half4 show_unity_SHAr;
half4 show_unity_SHAg;
half4 show_unity_SHAb;
half4 show_unity_SHBr;
half4 show_unity_SHBg;
half4 show_unity_SHBb;
half4 show_unity_SHC;

//samplerCUBE _EnvCube; 
UNITY_DECLARE_TEXCUBE(_EnvCube);
half _EnvCubeScale;

// normal should be normalized, w=1.0
half3 ShowSHEvalLinearL0L1 (half4 normal)
{
    half3 x;

    // Linear (L1) + constant (L0) polynomial terms
    x.r = dot(show_unity_SHAr,normal);
    x.g = dot(show_unity_SHAg,normal);
    x.b = dot(show_unity_SHAb,normal);

    return x;
}

// normal should be normalized, w=1.0
half3 ShowSHEvalLinearL2 (half4 normal)
{
    half3 x1, x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = normal.xyzz * normal.yzzx;
    x1.r = dot(show_unity_SHBr,vB);
    x1.g = dot(show_unity_SHBg,vB);
    x1.b = dot(show_unity_SHBb,vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = normal.x*normal.x - normal.y*normal.y;
    x2 = show_unity_SHC.rgb * vC;

    return x1 + x2;
}


// normal should be normalized, w=1.0
// output in active color space
half3 ShowShadeSH9 (half4 normal)
{
    // Linear + constant polynomial terms
    half3 res = ShowSHEvalLinearL0L1 (normal);

    // Quadratic polynomials
    res += ShowSHEvalLinearL2 (normal);

#   ifdef UNITY_COLORSPACE_GAMMA
        res = LinearToGammaSpace (res);
#   endif

    return res;
}

half3 ShowShadeSHPerVertex (half3 normal)
{
	return max(half3(0,0,0), ShowShadeSH9 (half4(normal, 1.0)));
}
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

#if defined(CUSTOM_ENV_LIGHT_ON)		
	o.ambient = ShowShadeSHPerVertex(normalWorld);

#else
	o.ambient = DodVertexGIForward(normalWorld);		
#endif
		
	DOD_TRANSFER_FOG(o.fogCoord,v.vertex);
	
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

float _ShadowScale;

#ifdef _ANISO_ON
inline PS_OUTPUT UnityBrdfLight (BrdfSurfaceOutput s, half3 viewDir, 
				UnityLight light, UnityIndirect indirect, 
				half3 tangent, half3 binormal, fixed atten, float3 worldPos)
#else
inline PS_OUTPUT UnityBrdfLight (BrdfSurfaceOutput s, half3 viewDir, 
				UnityLight light, UnityIndirect indirect, fixed atten, float3 worldPos)
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
	half ansioSpec = D_GGXaniso(_AnisoCtrl.x , _AnisoCtrl.y, nh, halfDir, tangent, RandTangent(binormal, s.Normal, s.anisoXY.x)) * _AnisoCtrl.z * nl * s.SpecColor.r;	
	half anisoSpec2 = D_GGXaniso(_AnisoCtrl2.x , _AnisoCtrl2.y, nh, halfDir, 
		tangent, RandTangent(binormal, s.Normal, s.anisoXY.y)) * _AnisoCtrl2.z * nl * s.SpecColor.g;
	
	c.rgb += (ansioSpec * _AnisoSpecColor1 + anisoSpec2*_AnisoSpecColor2) * s.Albedo * light.color * _Color * nl;
	
#else

	#ifdef SPEC_ON
	
		half lh = max(0.32h, dot(light.dir, halfDir));
		half spec = GGX_Spec(nh, lh, _SpecRoughness)* _SpecScale;

		fixed3 specTerm = s.SpecColor * spec * light.color * nl;
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

	#ifdef MRT_ENABLE
		//lumience += reflectTerm;
	#endif
#endif

#if defined(RIM_ON) && defined(RIM_COLOR)						
	fixed3 rimTerm = s.Albedo * _RimColor * s.RimFresnel * (occlusion * _RimScale);
	c.rgb += rimTerm;	
#endif

	c.rgb += s.Emission;
	#ifdef MRT_ENABLE
		lumience += s.Emission;
		//lumience += s.Emission;
	#endif
	
	
	#ifdef HIGHLIGHT_ON
	c.rgb *= (1 +  _HighLightColor * s.HighLightScale);
	#endif
	
	c.a = s.Alpha;
	
	#ifdef MRT_ENABLE
	PS_OUTPUT ps_out;
	DOD_APPLY_FOG(s.fogCoord, worldPos, c.rgb);
	ps_out.dest0 = c;
	ps_out.dest1 = get_lumience(lumience);
	
	return ps_out;
	#else
	DOD_APPLY_FOG(s.fogCoord, worldPos, c.rgb);
	return c;
	#endif
}


inline PS_OUTPUT DodLightingBrdf (BrdfSurfaceOutput s, half3 viewDir, UnityGI gi, fixed atten, float3 worldPos)
{
	PS_OUTPUT c;
	
	#ifdef _ANISO_ON
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect, s.tangent, s.binormal, atten, worldPos);
	#else
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect, atten, worldPos);
	#endif
	
	return c;
}


fixed MaxColor(fixed3 color)
{
	return max(max(color.r,color.g), color.b);
}


fixed4 GetTexture(sampler2D tex, half2 uv)
{
#if defined(TEX_HIGH)
	half4 uv4;
	uv4.xy = uv;
	uv4.w = 0;
	return tex2Dlod(tex, uv4);
#else
	return tex2D(tex, uv);
#endif
}

/**************************
@功能：妆容mask贴图
@参数：atlasTex，妆容图集纹理
@参数：uvOffset，uv偏移量
@参数：uvScale，uv缩放倍率
@参数：uv，妆容纹理uv
***************************/
fixed4 GetMaskAtlas(sampler2D atlasTex, float2 uvOffset, float2 uvScale, float4 uvRect, half2 uv)
{
	/*#ifdef MAKS_TEST_MODE
	uvRect = float4(0,0,1,1);
	#endif*/
	
	float2 uvOffsetMask = step(uvRect.xy, uv) * step(uv, uvRect.zw);
	//float2 uvAtlas = uv * uvScale + uvOffset;
	float2 uvAtlas = float2(0,0);
	uvAtlas.x = (uv.x - uvRect.x) * uvScale.x + uvOffset.x;
	uvAtlas.y = 1 - (uvRect.w - uv.y) * uvScale.y - uvOffset.y;
	fixed4 uvMaskColor = GetTexture(atlasTex, uvAtlas);
	uvMaskColor.a *= uvOffsetMask.x * uvOffsetMask.y;
	return uvMaskColor;
}

#define GetAndMaskColor(tex, uv) \
	maskColor = GetMaskAtlas(_##tex, _UvOffset##tex.xy, _UvOffset##tex.zw, _UvScale##tex, uv); \
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

half3 dod_flow_effect(DodInput IN, fixed mask)
{
	half flowMask = mask * _FlowLightScale;
	half time = _Time.y;
	half2 lightUV = _FlowLightSpeed * time + IN.uv_MainTex.zw;
	return tex2D(_FlowLightTex, lightUV).rgb * _FlowLightColor * flowMask;
}

#elif defined(EFFECT_FLOW_DISTORT)

half3 dod_flow_effect(DodInput IN, mask)
{
	return half3(0,0,0);
}

#endif

BrdfSurfaceOutput dod_surf (DodInput IN) {
	
	BrdfSurfaceOutput o;
	UNITY_INITIALIZE_OUTPUT(BrdfSurfaceOutput, o);
	
	fixed4 baseColor = GetBaseColor(IN.uv_MainTex.xy);
	
#ifdef CUT_OFF
	clip(baseColor.a - _Cutoff);
	
#endif

	#ifdef FADE_ON
	o.Alpha = _FadeAlpha;
	#else
	o.Alpha = baseColor.a * 0.5;
	#endif
	
	#ifdef NORMAL_MAP_ON
	//o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_MainTex));
	#endif

	o.Normal = normalize(IN.normalWorld);
	//o.Normal = IN.normalWorld;
	
	fixed4 mask = GetTexture(_MaskTex, IN.uv_MainTex.xy);

	//皮肤通道
#if defined(SKIN_ON)
	o.Skin = mask.a;
#endif
	
	#ifndef _ANISO_ON
		
	fixed specMask = mask.r;
	fixed emissMask = mask.g;
	fixed reflectMask = mask.b;
	
	#ifdef EMISS_MAP_ON
	o.Emission = baseColor * emissMask * _EmissScale;	
	baseColor = baseColor * (1-emissMask);
	
	#endif
	    
#ifdef EFFECT_FLOW
	o.Emission += dod_flow_effect(IN, mask.a);
#endif
		
	o.SpecColor = baseColor * specMask;
	
	#ifdef REFLECT_MAP_ON
	reflectMask = min(1, reflectMask * _ReflectContrast);		
	o.ReflectColor = baseColor * reflectMask;	
	o.Albedo = baseColor * (1-reflectMask);
	
	#else
	o.Albedo = baseColor;	
	#endif
	
	#else
	
	o.Albedo = baseColor;
	o.SpecColor = fixed3(mask.r, mask.g, 0);
	
	half anisoRand = mask.b - 0.5;
	o.anisoXY = half2(_AnisoCtrl.w + anisoRand*_AnisoRandScale, _AnisoCtrl2.w + anisoRand);	
	
	#endif
	
	#ifdef _ANISO_ON
	o.tangent = normalize(IN.tangent);
	o.binormal = normalize(IN.binormal);
	
	#endif
	
	#if defined(OCCLUSION_ON) && defined(RIM_ON)
	o.Occlusion = IN.eyeVec.w;
	#endif

	o.fogCoord = IN.fogCoord;

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
		
	
	#ifdef CUSTOM_MAIN_LIGHT
	d.light.dir = _WorldSpaceLightPos0.xyz;
	d.light.color = _ActorLightColor; ///不需要lightprobe变化支持 * data.light.color.r*_ActorDiveBaseMainLight;
	#else
	d.light = DodMainLight();
	#endif
	
	d.worldPos = DodGetInputWorldPos(i);
	d.worldViewDir = normalize(i.eyeVec.xyz);
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
	
	#if defined(UNITY_SHOULD_SAMPLE_SH) || defined(CUSTOM_ENV_LIGHT_ON)
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
#ifdef CUSTOM_ENV_LIGHT_ON
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(_EnvCube, worldRefl, roughness);
	half3 specular = DodDecodeHDR(rgbm, true, _EnvCubeScale);
#else
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, roughness);
	half3 specular = DodDecodeHDR(rgbm, unity_SpecCube0_HDR.w == 1, unity_SpecCube0_HDR.x);
#endif
	
	return specular;
}

inline UnityGI LightingBrdf_GI (
	inout BrdfSurfaceOutput s,
	DodUnityGIInput data)
{
	UnityGI gi = MyUnityGI_Base (data, 1.0, s.Normal);
	half3 reflUVW	= reflect(-data.worldViewDir, s.Normal);
	
	half vn = dot(data.worldViewDir, s.Normal);
	
	#ifdef HIGHLIGHT_ON
		half nv = saturate(_HighLightBias + vn);
		s.HighLightScale = DodFresnelLerpFast(nv);
	#endif
	
	#ifdef RIM_ON
		half nv = saturate(_RimBias + vn);
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
	
	#ifdef REFLECT_MAP_ON
		gi.indirect.specular = GetReflectIndirectSpecular(data, reflUVW, roughness);
	#endif
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
	UnityGI gi = LightingBrdf_GI (s, data);
	
	PS_OUTPUT c = DodLightingBrdf(s, data.worldViewDir, gi, data.atten, data.worldPos);
	return c;
}


/*************************************************************
*********************角色通用材质增加无光模式*******************
**************************************************************/
DodInput UnLitVert (DodVertexInput v)
{
	DodInput o;
	UNITY_INITIALIZE_OUTPUT(DodInput, o);

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv_MainTex.xy = TRANSFORM_TEX(v.uv0, _MainTex);

	return o;
}

fixed4 UnLitFrag(DodInput i) : SV_Target
{
	fixed4 color = GetBaseColor(i.uv_MainTex);
	//color.rgb *= 1.15; //trick
	return color;	
}