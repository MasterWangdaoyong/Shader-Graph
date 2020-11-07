
#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "UnityLightingCommon.cginc"
#include "UnityGlobalIllumination.cginc"
#include "AutoLight.cginc"


struct v2f_shadowcaster { 
	V2F_SHADOW_CASTER;
#ifdef CUT_OFF
	float2 uv : TEXCOORD1;
#endif
	
	
};

#ifdef CUT_OFF
sampler2D _MainTex;
float4 _MainTex_ST;
fixed _Cutoff;
#endif

v2f_shadowcaster vertShadowCaster(appdata_base v)
{
	v2f_shadowcaster o;
	TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)

#ifdef CUT_OFF
	o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
#endif
	return o;
}

float4 fragShadowCaster(v2f_shadowcaster i) : SV_Target
{
#ifdef CUT_OFF
	float4 c = tex2D(_MainTex, i.uv);
	clip(c.a - _Cutoff);
#endif

	SHADOW_CASTER_FRAGMENT(i)
}


