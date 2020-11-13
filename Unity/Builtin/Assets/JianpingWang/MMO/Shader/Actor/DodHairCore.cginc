/*****************************
*文件名：DodHairCore.cginc
*作者：aiya
*时间：2020/3/6
*描述：角色头发着色器
******************************/

#include "DodPBSUtils.cginc" 
#include "../Scene/Dodfog.cginc"

//顶点着色器输入结构体
struct a2v{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float2 texcoord : TEXCOORD0;
};

//顶点着色器输出结构体
struct v2f{
	float4 pos : SV_POSITION;	//裁剪空间下的坐标
	float3 wPos : TEXCOORD0;	//世界空间下的坐标
	half3 wTangent : TEXCOORD1;
	half3 wBinormal : TEXCOORD2;
	half3 wNormal : TEXCOORD3;
	half2 uv : TEXCOORD4;
	SHADOW_COORDS(5)
	DOD_FOG_COORDS(6)
};

//材质参数
fixed4 _MainColor;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _BumpTex;

float _BumpScale;
float _DiffWrap;
float _Cutoff;

fixed4 _SpecColor1;
float _SpecShift1;
float _SpecGloss1;

fixed4 _SpecColor2;
float _SpecShift2;
float _SpecGloss2;

float _SpecIntensity;

#ifdef FADE_ON
float _FadeAlpha;
#endif

/*********************************
@功能：计算切线偏移
@参数：T，世界空间下的副法线binormal
@参数：N，世界空间下的法线
@参数：shift，偏移量
*********************************/
float3 ShiftTangent(float3 T, float3 N, float shift)
{
	float3 shiftedT = T + (shift * N);
	return normalize(shiftedT);
}

/******************************************
@功能：Kajiya-Kay光照模型
@参数：T，副切线，通过偏移计算
@参数：V，世界空间下的视角方向
@参数：L，世界空间下的光照方向
@参数：exponent，光泽度，值越高越凝聚，亮度越大
*******************************************/
float StrandSpecular(float3 T, float3 V, float3 L, float exponent)
{
	float3 halfDir = normalize(L + V);
	float dotTH = dot(T, halfDir);
	float sinTH = max(0.01, sqrt(1 - pow(dotTH, 2)));
	float dirAtten = smoothstep(-1, 0, dotTH);
	return dirAtten * pow(sinTH, exponent);
}



/**************************
@功能：Hair顶点着色器
@参数：v，顶点着色器输入结构体
@输出：o，顶点着色器输出结构体
***************************/
v2f vert(a2v v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.wNormal = UnityObjectToWorldNormal(v.normal);
	o.wTangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	o.wBinormal = cross(o.wNormal, o.wTangent) * v.tangent.w;

	TRANSFER_SHADOW(o);
	DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
	return o;
}

/****************************************************
@功能：Hair片元着色器，用于头发写入深入，同时输出颜色
@参数：i，顶点着色器输出结构体
*****************************************************/
fixed4 frag_mask(v2f i) : SV_Target
{
	fixed4 albedo = tex2D(_MainTex, i.uv); //G-Specular shift, B-Noise, A-Cutoff
	float cutoff = min(_Cutoff, 0.9);//限制裁剪不能超过0.9，避免mesh断层
	clip(albedo.a - cutoff);

	fixed4 finalColor = 0;
	finalColor.rgb = _MainColor;

	half alpha = albedo.a;
#ifdef FADE_ON
	alpha *= _FadeAlpha;
#endif
	finalColor.a = alpha;
	return finalColor;
}


/*******************************
@功能：Hair片元着色器
@参数：i，顶点着色器输出结构体
*******************************/
fixed4 frag(v2f i) : SV_TARGET
{
	half3 worldPosDir = normalize(i.wPos);
	half3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wPos));
	half3 halfDir = normalize(viewDir + lightDir);

	half3 tNormal = UnpackNormal(tex2D(_BumpTex, i.uv));
	tNormal.xy *= _BumpScale;
	half3 normalDir = GetWorldNormal(tNormal, i.wTangent, i.wBinormal, i.wNormal);

	half NdotL = saturate(dot(normalDir, lightDir));

	fixed4 albedo = tex2D(_MainTex, i.uv);//G-Specular shift, B-Noise, A-Cutoff
	
#ifdef FADE_ON
	albedo.a = _FadeAlpha;
#endif

////// Lighting:
	half3 ambient = DOD_LIGHTMODEL_AMBIENT(normalDir) * _MainColor;
	fixed shadow = SHADOW_ATTENUATION(i);

////// Diffuse:
	float diff = NdotL;
	float wrap = (diff + _DiffWrap) / (1 + _DiffWrap);
	half3 diffColor = LIGHTCOLOR.rgb * wrap * _MainColor * shadow;
	
////// Specular:
	half shiftTex = albedo.g;

	//分别计算主高光和副高光
	half3 t1 = ShiftTangent(i.wBinormal, normalDir,  (_SpecShift1 * 5 + shiftTex));
	half3 t2 = ShiftTangent(i.wBinormal, normalDir,  (_SpecShift2 * 5 + shiftTex));	
	half3 spec1 = StrandSpecular(t1, viewDir, lightDir, _SpecGloss1) * _SpecColor1;
	half3 spec2 = StrandSpecular(t2, viewDir, lightDir, _SpecGloss2) * _SpecColor2 * albedo.b;
	float3 specColor = LIGHTCOLOR.rgb * (spec1 + spec2) * _SpecIntensity * NdotL * shadow;

////// Final:
	fixed4 finalColor = 0;
	finalColor.rgb = (diffColor + specColor) + ambient;
	finalColor.a = albedo.a;

	DOD_APPLY_FOG(i.fogCoord, i.wPos, finalColor.rgb);

	return finalColor;
}
