/*****************************
*文件名：DodSkinCore.cginc
*作者：aiya
*时间：2020/2/12
*描述：角色皮肤材质着色器
******************************/

#include "DodPBSUtils.cginc"

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
};

//材质参数
sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;
sampler2D _BumpTex;
sampler2D _BRDFTex;

float _DiffScale;
float _BumpScale;
float _DiffWrap;
float _CurvatureScale;
float _SpecScale;
float _ReflectScale;
float _Smoothness;
float _RimGloss;
float _RimScale;
fixed3 _RimColor;
float _FadeAlpha;

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


/**************************
@功能：妆容mask贴图
@参数：atlasTex，妆容图集纹理
@参数：uvOffset，uv偏移量
@参数：uvScale，uv缩放倍率
@参数：uv，妆容纹理uv
***************************/
fixed4 GetMaskAtlas(sampler2D atlasTex, float2 uvOffset, float2 uvScale, float4 uvRect, half2 uv)
{
	#ifdef MAKS_TEST_MODE
	uvScale = float4(0,0,1,1);
	#endif
	
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


/********************
@功能：获取妆容
@参数：albedo，固有色
@参数：uv，主纹理uv
********************/
fixed3 GetDecalColor(fixed3 albedo, half2 uv)
{
	fixed3 baseColor = albedo;
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



/**************************
@功能：均值模糊
@参数：albedo，固有色贴图
@参数：uv，主纹理uv
@参数：blurSize，模糊倍率
***************************/
fixed3 SimpleBlur(fixed3 albedo, half2 uv, float blurSize)
{
	float2 uv1 = uv + blurSize * _MainTex_TexelSize * float2(1, 1);
	float2 uv2 = uv + blurSize * _MainTex_TexelSize * float2(-1, 1);
	float2 uv3 = uv + blurSize * _MainTex_TexelSize * float2(-1, -1);
	float2 uv4 = uv + blurSize * _MainTex_TexelSize * float2(1, -1);

	fixed3 color = fixed3(0, 0, 0);
	color += albedo;
	color += tex2D(_MainTex, uv1);
	color += tex2D(_MainTex, uv2);
	color += tex2D(_MainTex, uv3);
	color += tex2D(_MainTex, uv4);

	return color * 0.2;
}

/**************************
@功能：Skin顶点着色器
@参数：v，顶点着色器输入结构体
@输出：o，顶点着色器输出结构体
***************************/
v2f vertSkin(a2v v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.wNormal = UnityObjectToWorldNormal(v.normal);
	o.wTangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
	o.wBinormal = cross(o.wNormal, o.wTangent) * v.tangent.w;

	TRANSFER_SHADOW(o);
	return o;
}

/*******************************
@功能：Skin片元着色器
@参数：i，顶点着色器输出结构体
*******************************/
fixed4 fragSkin(v2f i) : SV_TARGET
{
	half3 worldPosDir = normalize(i.wPos);
	half3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wPos));
	half3 halfDir = normalize(viewDir + lightDir);

	//将法线从切线空间转换到世界空间
	half3 tNormal = UnpackNormal(tex2D(_BumpTex, i.uv));
	tNormal.xy = tNormal.xy * _BumpScale;
	half3 normalDir = GetWorldNormal(tNormal, i.wTangent, i.wBinormal, i.wNormal);

	half NdotL = saturate(dot(normalDir, lightDir));
	half NdotH = saturate(dot(normalDir, halfDir));
	half VdotH = dot(viewDir, halfDir);
	half NdotV = dot(normalDir, viewDir);
	fixed4 albedo = tex2D(_MainTex, i.uv);
	#ifdef FADE_ON
	albedo.a = _FadeAlpha;
	#endif
	
	#ifdef SIMPLE_BLUR
	albedo.rgb = SimpleBlur(albedo.rgb, i.uv, _Smoothness);
	#endif

	albedo.rgb = GetDecalColor(albedo.rgb, i.uv);
	
////// Lighting:
	half3 ambient = DOD_LIGHTMODEL_AMBIENT(normalDir) * albedo.rgb;
	float shadow = SHADOW_ATTENUATION(i);


////// Diffuse:
	//float curvature = saturate(length(fwidth(normalDir)) / length(fwidth(worldPosDir)) * _CurvatureScale * 0.1);
	float curvature = dot(LIGHTCOLOR.rgb, fixed3(0.22, 0.707, 0.071)) * _CurvatureScale;
	float wrap = (NdotL * shadow + _DiffWrap) / (1 + _DiffWrap);
	half2 brdfUV = half2(wrap, curvature);
	//float halfLambert = NdotL * 0.5 + 0.5;
	//half2 brdfUV = half2(halfLambert, curvature);
	fixed3 brdf = tex2D(_BRDFTex, brdfUV).rgb;
	half3 diffColor = LIGHTCOLOR.rgb * brdf * albedo.rgb * _DiffScale;

	
////// Specular:
	float fresnel = DodFresnel(VdotH);
	float spec = pow(NdotH, 128) * _SpecScale * fresnel;
	half3 specColor = LIGHTCOLOR.rgb * spec * pow(1 - albedo.a, 6.0);

/////// Reflection:
	half roughness = GetRoughness(1 - albedo.a);
	half3 reflUVW = reflect(-viewDir, normalDir);
	fixed3 indirectSpec = GetReflectIndirectSpecular(reflUVW, roughness);
	fixed3 reflColor = indirectSpec * albedo.rgb * albedo.a * _ReflectScale;
	//反射部分直接加到高光上
	specColor += reflColor;

////// Rim:
	fixed3 rimColor = pow((1 - NdotV), _RimGloss) * _RimColor.rgb * _RimScale;
	specColor += rimColor;

////// Final:
	fixed4 finalColor = (fixed4)1.0;
	finalColor.rgb = diffColor + specColor + ambient;
	finalColor.a = albedo.a;
	return finalColor;
}
