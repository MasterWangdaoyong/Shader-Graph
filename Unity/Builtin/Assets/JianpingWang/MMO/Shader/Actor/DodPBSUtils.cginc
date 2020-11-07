/************************
*文件名：DodPBSUtils.cginc
*作者：aiya
*时间：2020/2/10
*描述：封装PBS相关算法函数
*************************/

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "Lighting.cginc"

/**************************************
@功能：用于构建TBN矩阵，转化法线到世界空间
@参数：o，顶点着色器输出结构体
@参数：v，顶点着色器输入结构体
**************************************/
#define TRANSFER_TANGENTTOWORLD(o, v)  \
    o.wNormal = UnityObjectToWorldNormal(v.normal); \
    o.wTangent = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w); \
    o.wBinormal = cross(o.wNormal, o.wTangent) * v.tangent.w;

/**************************************************
@功能：将法线贴图从切线空间转换到世界空间
@参数：tNormal，切线空间下的法线方向
@参数：tangent，世界空间下的切线方向
@参数：binormal，世界空间下垂直wNormal与tangent的向量
@参数：wNormal，世界空间下法线方向
**************************************************/
inline half3 GetWorldNormal(half3 tNormal, half3 tangent, half3 binormal, half3 wNormal)
{
    float3x3 rotation = float3x3(tangent, binormal, wNormal);
    return normalize(mul(tNormal, rotation));
}

/**************************************
@功能：将高亮像素点稍微压平，仿卡通渲染效果
@参数：color，像素点颜色值
**************************************/
inline half3 ToonEffect(half3 color)
{
    half v = max(max(color.x, color.y), color.z) + 0.01;
	fixed multi = v * v;
	fixed temp = multi + 0.187;
	half v2 = multi / temp * 1.03;
	v = v2 / v;
	return v;
}

/*******************************
@功能：根据光滑度，转换PBS的粗糙度
@参数：smoothness，光滑度
*******************************/
inline float GetRoughness(float smoothness)
{
    float roughness = (1 - smoothness) * (1 - smoothness);
    return max(0.002, roughness);
}

/*********************************
@功能：SmithJointGGXVisibilityTerm
@参数：NdotL，法线与光照方向点积
@参数：NdotV，法线与视角方向点积
@参数：roughness，粗糙度
*********************************/
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

/*****************************
@功能：计算GGX高光
@参数：NdotH，法线与半角向量点积
@参数：roughness，粗糙度
*****************************/
inline float DodGGXTerm (float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f;
    return UNITY_INV_PI * a2 / (d * d + 1e-7f);                                   
}


/*****************************
@功能：各项异性的GGX高光
@参数：RoughnessX，粗糙度x
@参数：RoughnessY，粗糙度y
@参数：NdotH，法线与半角向量的点积
@参数：H，半角向量
@参数：T，切线向量
@参数：B，随机切线向量
*****************************/
inline half DodGGXaniso(half RoughnessX, half RoughnessY, half NdotH, half3 H, half3 T, half3 B )
{
	half mx = RoughnessX * RoughnessX;
	half my = RoughnessY * RoughnessY;
	half XdotH = dot( T, H );
	half YdotH = dot( B, H );
	half d = XdotH * XdotH / (mx * mx) + YdotH * YdotH / (my * my) + NdotH * NdotH;
	return 1.0 / ( mx * my * d * d );
}

/*************************************
@功能：GGX_Specular
@参数：NdotL，法线与光照方向点积
@参数：NdotV，法线与视角方向点积
@参数：NdotH，法线与半角向量点积
@参数：roughness，粗糙度
*************************************/
inline float GGX_Specular(half3 NdotL, half3 NdotV, half3 NdotH, half roughness)
{
    float V = DodSmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
	float D = DodGGXTerm(NdotH, roughness);
	float specTerm = V * D * UNITY_PI;
	specTerm = max(0, specTerm * NdotL);
    return specTerm;
}

/*****************************
@功能：解码HDR
@参数：data，环境高光颜色
@参数：useAlpha，alpha是否有效
@参数：scale，缩放倍率
*****************************/
inline half3 DodDecodeHDR (half4 data, bool useAlpha, half scale)
{
	half alpha = useAlpha ? data.a : 1.0;
	return (scale * alpha) * data.rgb;
}

/*********************
@功能：四次方运算式
@参数：x，基数
*********************/
inline half DodPow4 (half x)
{
    return x*x*x*x;
}

/**********************************
@功能：菲尼尔计算式
@参数：VdotH，视角方向与半角向量点积
**********************************/
inline half DodFresnel(half VdotH)
{
    //float F0 = 0.028;
    float F0 = 1.0;
    float base = 1.0 - VdotH;
    float exponential = pow(base, 5.0);
    return exponential + F0 * (1.0 - exponential);
}


/*****************************
@功能：简化版菲尼尔计算式
@参数：cosA，法线与视线夹角余弦值
******************************/
inline half DodFresnelLerpFast (half cosA)
{
    half t = DodPow4 (1 - cosA);
	return t;
}

/*****************************
@功能：计算切线偏移
@参数：tangent，模型切线向量
@参数：normal，模型法线向量
@参数：rand，偏移量
******************************/
inline half3 RandTangent(half3 tangent, half3 normal, half3 rand)
{
	half t = tangent + normal * rand;
	return normalize(t);
}

/***********************
@功能：2d纹理查询
@参数：tex，纹理贴图
@参数：uv，纹理uv
*************************/
inline fixed4 GetTexture(sampler2D tex, half2 uv)
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

//********************************************************
//***********************自定义光照***********************
//********************************************************
#ifdef CUSTOM_MAIN_LIGHT
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
half3 ShowSHEvalLinearL0L1 (half4 wNormal)
{
    half3 x;

    // Linear (L1) + constant (L0) polynomial terms
    x.r = dot(show_unity_SHAr,wNormal);
    x.g = dot(show_unity_SHAg,wNormal);
    x.b = dot(show_unity_SHAb,wNormal);

    return x;
}

// normal should be normalized, w=1.0
half3 ShowSHEvalLinearL2 (half4 wNormal)
{
    half3 x1, x2;
    // 4 of the quadratic (L2) polynomials
    half4 vB = wNormal.xyzz * wNormal.yzzx;
    x1.r = dot(show_unity_SHBr,vB);
    x1.g = dot(show_unity_SHBg,vB);
    x1.b = dot(show_unity_SHBb,vB);

    // Final (5th) quadratic (L2) polynomial
    half vC = wNormal.x*wNormal.x - wNormal.y*wNormal.y;
    x2 = show_unity_SHC.rgb * vC;

    return x1 + x2;
}


// normal should be normalized, w=1.0
// output in active color space
half3 ShowShadeSH9 (half4 wNormal)
{
    // Linear + constant polynomial terms
    half3 res = ShowSHEvalLinearL0L1 (wNormal);

    // Quadratic polynomials
    res += ShowSHEvalLinearL2 (wNormal);

#ifdef UNITY_COLORSPACE_GAMMA
        res = LinearToGammaSpace (res);
#endif

    return res;
}

/*****************************
@功能：逐顶点SH光照
@参数：wNormal，世界空间下的法线
******************************/
half3 ShowShadeSHPerVertex (half3 wNormal)
{
	return max(half3(0,0,0), ShowShadeSH9 (half4(wNormal, 1.0)));
}

#endif



/*****************************
@功能：获取当前场景环境光照
@参数：wNormal，世界空间下的法线
******************************/
half3 DodVertexGIForward(half3 wNormal)
{
    half3 ambient = 0;
    
	#if UNITY_SHOULD_SAMPLE_SH
        ambient = max(half3(0, 0, 0), ShadeSH9(half4(wNormal, 1.0)));
    #endif
	
    return ambient;
}

//获取主光照宏
#ifdef CUSTOM_MAIN_LIGHT
	#define LIGHTCOLOR _ActorLightColor
#else
	#define LIGHTCOLOR _LightColor0
#endif


//获取环境光照宏
#ifdef CUSTOM_ENV_LIGHT_ON
	#define DOD_LIGHTMODEL_AMBIENT(wNormal) ShowShadeSHPerVertex(wNormal)
#else
	#define DOD_LIGHTMODEL_AMBIENT(wNormal) DodVertexGIForward(wNormal)
#endif


/**********************************
@功能：获取间接高光反射
@参数：worldRefl，世界空间下的反射方向
@参数：roughness，粗糙度
***********************************/
inline half3 GetReflectIndirectSpecular(half3 worldRefl, half roughness)
{	
	half mip = roughness * UNITY_SPECCUBE_LOD_STEPS;
#ifdef CUSTOM_ENV_LIGHT_ON
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(_EnvCube, worldRefl, mip);
	half3 specular = DodDecodeHDR(rgbm, true, _EnvCubeScale);
#else
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, mip);
	half3 specular = DodDecodeHDR(rgbm, unity_SpecCube0_HDR.w == 1, unity_SpecCube0_HDR.x);
#endif
	
	return specular;
}

//**************************End 自定义光照**************************