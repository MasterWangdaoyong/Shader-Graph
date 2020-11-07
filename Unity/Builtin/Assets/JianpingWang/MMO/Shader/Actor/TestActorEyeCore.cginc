
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
};



struct DodInput {

	float4 pos  : SV_POSITION;
	
	half4 uv_MainTex : TEXCOORD0;	
	float4 eyeVec : TEXCOORD1;
	half3 ambient : TEXCOORD2;
	float2 reflectUV : TEXCOORD3;
	#ifdef USE_DOD_SHADOW
	float4 shadowCoords: TEXCOORD4;
	#else
	UNITY_SHADOW_COORDS(4)
	#endif
	UNITY_FOG_COORDS(5)
	float3 worldPos : TEXCOORD6;
	float3 normalWorld :TEXCOORD7;
	
};

///先放在这，需要扩展的时候，在同一改为自定义的接口
struct BrdfSurfaceOutput {
	fixed3 Albedo;
	float3 Normal;
	fixed3 Mask;
	float2 reflectUV;
	fixed Alpha;
};

fixed3 _EyeBallColor;

sampler2D _MainTex;
float4    _MainTex_ST;

half _EnvScale;

sampler2D _SpecTex;
half _SpecScale;

sampler2D _ReflectTex; //mask
sampler2D _ReflectMatcap; //reflect env
half _ReflectScale;

sampler2D _EyeColorMask;

#ifdef USE_DOD_SHADOW
sampler2D _DodShadowTex;
float4x4 _DodShadowMatrix;
half 	 _DodShadowIntensity;
#endif


float _AttenScale;

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


DodInput EyeVert (DodVertexInput v)
{
	DodInput o;
    UNITY_INITIALIZE_OUTPUT(DodInput,o);
	
	float3 posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.eyeVec.xyz = -NormalizePerVertexNormal(posWorld - _WorldSpaceCameraPos);
	
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv_MainTex.xy = TRANSFORM_TEX(v.uv0, _MainTex);
	
	float3 normal = normalize(v.normal);
	o.reflectUV = float2(dot(UNITY_MATRIX_IT_MV[0].xyz, normal),dot(UNITY_MATRIX_IT_MV[1].xyz, normal)) * 0.5 + 0.5;
	
#ifdef USE_DOD_SHADOW
	o.shadowCoords = mul(_DodShadowMatrix, float4(posWorld, 1.0));
#else
	TRANSFER_SHADOW(o);
#endif

	
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
	o.ambient = DodVertexGIForward(normalWorld);
	
	UNITY_TRANSFER_FOG(o,o.pos);
	
	o.worldPos = posWorld;
	o.normalWorld = normalWorld;

	return o;
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

#define PS_OUTPUT fixed4

inline PS_OUTPUT UnityBrdfLight (BrdfSurfaceOutput s, half3 viewDir, 
				UnityLight light, UnityIndirect indirect)
{
	fixed nl = max (0, dot (s.Normal, light.dir));
	//fixed diff = lerp(_DiffWrap, 1, nl);
	fixed diff = nl;

	fixed4 c;
	c.a = 1;
	c.rgb = fixed3(0,0,0);
	
#ifdef DIFFUSE_ON
	c.rgb = s.Albedo * light.color * diff * _EnvScale;
#endif
		
#ifdef ENVLIGHT_ON
#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
	c.rgb += s.Albedo * indirect.diffuse * _EnvScale;		//为了统一光照,环境光也和diffuse一起放大缩小
#endif
#endif

#ifdef SPEC_ON	
	//half spec = _SpecScale * nl * s.Mask.r;

	half3 halfDir = normalize (light.dir + viewDir);	
	half spec = saturate(dot(s.Normal, halfDir)) * _SpecScale * s.Mask.r;
	
	half3 specTerm = spec * light.color;
	c.rgb += specTerm;

#endif
	
#ifdef REFLECT_MAP_ON				

	fixed3 reflectTerm = indirect.specular * s.Mask.b * _ReflectScale;
	c.rgb += reflectTerm;

#endif
			
	c.a = s.Alpha;	
	return c;
}


inline PS_OUTPUT DodLightingBrdf (BrdfSurfaceOutput s, half3 viewDir, UnityGI gi)
{
	PS_OUTPUT c;
	
	#ifdef _ANISO_ON
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect, s.tangent, s.binormal);
	#else
	c = UnityBrdfLight (s, viewDir, gi.light, gi.indirect);
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

BrdfSurfaceOutput dod_surf (DodInput IN) {
	
	BrdfSurfaceOutput o;
	UNITY_INITIALIZE_OUTPUT(BrdfSurfaceOutput, o);
	
    fixed3 baseColor = GetTexture (_MainTex, IN.uv_MainTex).rgb;
	o.Alpha = 1.0;
	
	fixed specMask = MaxColor(GetTexture(_SpecTex, IN.uv_MainTex).rgb);
	fixed reflectMask = MaxColor(GetTexture (_ReflectTex, IN.uv_MainTex).rgb);
	o.Mask = fixed3(specMask, 0, reflectMask);
	
	fixed eyeColorMask = GetTexture(_EyeColorMask, IN.uv_MainTex).r;
	o.Albedo = baseColor + 	_EyeBallColor*eyeColorMask;;
	
	o.reflectUV = IN.reflectUV;
	o.Normal = normalize(IN.normalWorld.xyz);
	
	return o;
}

struct DodUnityGIInput
{
    UnityLight light; // pixel light, sent from the engine

    half3 worldViewDir;
    half atten;
    half3 ambient;
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
	d.worldViewDir = normalize(i.eyeVec.xyz);
	d.ambient = i.ambient;

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
	o_gi.light.color *= data.atten;
	
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

inline half4 GetReflectIndirectSpecularMatcap(fixed2 uv)
{
	return tex2D(_ReflectMatcap, uv);
}

inline UnityGI LightingBrdf_GI (
	inout BrdfSurfaceOutput s,
	DodUnityGIInput data)
{
	UnityGI gi = MyUnityGI_Base (data, 1.0, s.Normal);
	half4 envColor = GetReflectIndirectSpecularMatcap(s.reflectUV);
	gi.indirect.specular = envColor.rgb;
	s.Mask.r *= envColor.a;
	return gi;
}


PS_OUTPUT EyeFrag(DodInput i): SV_Target
{
	BrdfSurfaceOutput s = dod_surf(i);
		
	DodUnityGIInput data = GetGIInput(i);
	UnityGI gi = LightingBrdf_GI (s, data);
	
	PS_OUTPUT c = DodLightingBrdf(s, data.worldViewDir, gi);
	return c;
}

