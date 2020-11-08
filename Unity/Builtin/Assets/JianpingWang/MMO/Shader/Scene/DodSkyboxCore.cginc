//20200616 分析  JianpingWang 于深圳 晴    //mian = JianpingWang
//利用官方标准的skybox 修改所得
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "DodFog.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 uv : TEXCOORD0;
};

struct v2f
{
    float3 uv : TEXCOORD0;
    float4 pos : SV_POSITION;
	DOD_FOG_COORDS(1)
	float4 worldPos : TEXCOORD2;
	float3 viewDir : TEXCOORD3;
};

half4 _Tint;
half _Exposure;
float _Rotation;
samplerCUBE _Cubemap;
half4 _Cubemap_HDR;

v2f Skyboxvert (appdata v)
{
    v2f o;
	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = v.vertex;
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
	o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
	DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
    return o;
}
// float PhaseMie(float costheta)
// {
// 	return 0.00950627 * (costheta*costheta) /(1.96+(costheta*1.955));
// }
fixed4 Skyboxfrag (v2f i) : SV_Target
{
	half4 tex = texCUBE(_Cubemap, i.uv);
	half3 c = DecodeHDR(tex, _Cubemap_HDR);

	#if defined(LINEARCOLOR)
		c *= c;
	#endif

	c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb; //做数据转换？？？？？？？？？？？？？？？？？？？？？？？
	c *= _Exposure;

	#if defined(DOD_SUN_ON)
	// float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
	// float costheta = dot(normalize(i.viewDir), -lightDir);
	// float costheta2 = dot(normalize(i.viewDir), lightDir);
	// float phaseMie = PhaseMie(costheta2);
	// c += costheta * _DODSunColor * 0.8;
	// c += phaseMie*_DODSunColor;
	// c = clamp(c,0.0,4.0);

	float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //main 
    float dirSun = dot(normalize(i.viewDir), -lightDir); 
	c = c + dirSun * _DODSunColor * 0.8;
	half3 ray = normalize(mul((float3x3)unity_ObjectToWorld, -i.uv));   
	c += _DODSunColor * calcSunAttenuation(_WorldSpaceLightPos0.xyz, -ray);
	#endif

	DOD_APPLY_FOG(i.fogCoord, i.worldPos, c);

	#if defined(LINEARCOLOR)
		c = pow(c,0.5);
	#endif
	
	return half4(c, 1);
}