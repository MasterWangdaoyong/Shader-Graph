// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_BRDF_INCLUDED
#define UNITY_STANDARD_BRDF_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityLightingCommon.cginc"

//-----------------------------------------------------------------------------
// 将平滑度转换为粗糙度的助手smoothness to roughness
//-----------------------------------------------------------------------------

float PerceptualRoughnessToRoughness(float perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

half RoughnessToPerceptualRoughness(half roughness)
{
    return sqrt(roughness);
}

//平滑度是用户面对的名称
//应该是perceptualSmoothness，但我们不希望用户使用此名称
half SmoothnessToRoughness(half smoothness)
{
    return (1 - smoothness) * (1 - smoothness);
}

float SmoothnessToPerceptualRoughness(float smoothness)
{
    return (1 - smoothness);
}

//-------------------------------------------------------------------------------------

inline half Pow4 (half x)
{
    return x*x*x*x;
}

inline float2 Pow4 (float2 x)
{
    return x*x*x*x;
}

inline half3 Pow4 (half3 x)
{
    return x*x*x*x;
}

inline half4 Pow4 (half4 x)
{
    return x*x*x*x;
}

// Pow5使用的指令数量与通用pow（）相同，但是有两个优点：
// 1）更好的指令流水线
// 2）无需担心NaNs
inline half Pow5 (half x)
{
    return x*x * x*x * x;
}

inline half2 Pow5 (half2 x)
{
    return x*x * x*x * x;
}

inline half3 Pow5 (half3 x)
{
    return x*x * x*x * x;
}

inline half4 Pow5 (half4 x)
{
    return x*x * x*x * x;
}

inline half3 FresnelTerm (half3 F0, half cosA) //对应迪斯尼F项
{
    half t = Pow5 (1 - cosA);   // ala Schlick插值
    //公式中使用的是dot(v,h)。而Unity默认传入的是dot(l,h)
    //是因为BRDF大量的计算使用的是l,h的点积，而h是l和v的半角向量，所以lh和vh的夹角是一样的。不需要多来一个变量。
    return F0 + (1-F0) * t;
}
inline half3 FresnelLerp (half3 F0, half3 F90, half cosA)
{
    half t = Pow5 (1 - cosA);   // ala Schlick插值
    return lerp (F0, F90, t);
}
//用^ 4而不是^ 5近似显示Schlick
inline half3 FresnelLerpFast (half3 F0, half3 F90, half cosA)
{
    half t = Pow4 (1 - cosA);
    return lerp (F0, F90, t);
}

// 注意：迪士尼漫反射必须乘以diffuseAlbedo / PI。 这是在此功能之外完成的。
half DisneyDiffuse(half NdotV, half NdotL, half LdotH, half perceptualRoughness)
{
    half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
    // 两个schlick菲涅耳术语
    half lightScatter   = (1 + (fd90 - 1) * Pow5(1 - NdotL));
    half viewScatter    = (1 + (fd90 - 1) * Pow5(1 - NdotV));

    return lightScatter * viewScatter;
}

//注意：可见性术语是Torrance-Sparrow模型的完整形式，其中包括几何术语：V = G /（N.L * N.V）
//这样一来，交换几何图形项变得更加容易，并且有更多的优化空间（也许在CookTorrance geom项的情况下除外）
// 通用Smith-Schlick能见度术语
inline half SmithVisibilityTerm (half NdotL, half NdotV, half k)
{
    half gL = NdotL * (1-k) + k;
    half gV = NdotV * (1-k) + k;
    return 1.0 / (gL * gV + 1e-5f); //此功能不适合在Mobile上运行，
                                     //因此epsilon小于可以表示为一半的值
}
// Smith-Schlick 是贝克曼的作品
inline half SmithBeckmannVisibilityTerm (half NdotL, half NdotV, half roughness)
{
    half c = 0.797884560802865h; // c = sqrt(2 / Pi)
    half k = roughness * c;
    return SmithVisibilityTerm (NdotL, NdotV, k) * 0.25f; // * 0.25是可见性项的1/4
}
// Ref: http://jcgt.org/published/0003/02/03/paper.pdf  2014年文献
// 可见性项（包括几何函数和配平系数一起）的计算
inline float SmithJointGGXVisibilityTerm (float NdotL, float NdotV, float roughness)
{
    #if 0  //默认关闭，备注，这里是 Frostbite的GGX-Smith Joint方案（精确，但是需要开方两次，很不经济）
        // 原始配方:
        //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
        //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
        //  G           = 1 / (1 + lambda_v + lambda_l);
        // 重新排序代码以使其更优化
        half a          = roughness;
        half a2         = a * a;
        half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
        half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);
        // 简化可见性术语: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
        return 0.5f / (lambdaV + lambdaL + 1e-5f);  //此功能不适合在Mobile上运行，
                                                    //因此epsilon小于可以表示为一半的值
    #else
        // 走这个部分
        // 近似值（简化sqrt，在数学上不正确，但足够接近）
        // 这个部分是Respawn Entertainment的 GGX-Smith Joint近似方案
        float a = roughness;
        float lambdaV = NdotL * (NdotV * (1 - a) + a);
        float lambdaL = NdotV * (NdotL * (1 - a) + a);
        #if defined(SHADER_API_SWITCH)
            return 0.5f / (lambdaV + lambdaL + 1e-4f); //解决hlslcc舍入错误的解决方法
        #else
            return 0.5f / (lambdaV + lambdaL + 1e-5f);
        #endif
    #endif
}

inline float GGXTerm (float NdotH, float roughness) //对应迪斯尼GTR2 下层
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
    return UNITY_INV_PI * a2 / (d * d + 1e-7f); //此功能不适合在Mobile上运行，
                                             //因此epsilon小于一半
}

inline half PerceptualRoughnessToSpecPower (half perceptualRoughness)
{
    half m = PerceptualRoughnessToRoughness(perceptualRoughness);   // m是真正的学术粗糙度。
    half sq = max(1e-4f, m*m);
    half n = (2.0 / sq) - 2.0;                          // https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
    n = max(n, 1e-4f);                                  // 防止pow（0,0）的可能情况，当粗糙度为1.0且NdotH为零时可能发生
    return n;
}

//将BlinnPhong标准化为正态分布函数（NDF）
//用于微面模型：spec = D * G * F
// eq. 19 in https://dl.dropboxusercontent.com/u/55891920/papers/mm_brdf.pdf
inline half NDFBlinnPhongNormalizedTerm (half NdotH, half n)
{
    // norm = (n+2)/(2*pi)
    half normTerm = (n + 2.0) * (0.5/UNITY_PI);

    half specTerm = pow (NdotH, n);
    return specTerm * normTerm;
}

//-------------------------------------------------------------------------------------
/*
// https://s3.amazonaws.com/docs.knaldtech.com/knald/1.0.0/lys_power_drops.html

const float k0 = 0.00098, k1 = 0.9921;
// pass this as a constant for optimization
const float fUserMaxSPow = 100000; // sqrt(12M)
const float g_fMaxT = ( exp2(-10.0/fUserMaxSPow) - k0)/k1;
float GetSpecPowToMip(float fSpecPow, int nMips)
{
   // Default curve - Inverse of TB2 curve with adjusted constants
   float fSmulMaxT = ( exp2(-10.0/sqrt( fSpecPow )) - k0)/k1;
   return float(nMips-1)*(1.0 - clamp( fSmulMaxT/g_fMaxT, 0.0, 1.0 ));
}

    //float specPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    //float mip = GetSpecPowToMip (specPower, 7);
*/

inline float3 Unity_SafeNormalize(float3 inVec)
{
    float dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

//-------------------------------------------------------------------------------------

//注意：BRDF入口点使用平滑度和oneMinusReflectivity进行优化
//目的，主要用于DX9 SM2.0级别。 大部分数学运算都是在这些（1-x）值上完成的，这样可以节省
//一些宝贵的ALU插槽。


//主要基于物理的BRDF
//源自迪士尼作品，并基于Torrance-Sparrow微面模型
//
//   BRDF = kD / pi + kS * (D * V * F) / 4
//   I = BRDF * NdotL
//
// * NDF（取决于UNITY_BRDF_GGX）：
// a）标准化的BlinnPhong
// b）GGX
// * Smith for Visiblity术语
// *菲涅耳的Schlick近似
half4 BRDF1_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

// NdotV对于可见像素不应为负，但由于透视投影和法线贴图而可能发生
//在这种情况下，应修改法线以使其有效（即朝向相机），并且不会引起怪异的伪影。
//，但此操作添加的ALU很少，用户可能不想要它。 另一种方法是简单地使用NdotV的绝对值（不太正确，但也可以）。
//按照define来控制。 如果ALU在您的平台上很重要，请将其设置为0。
//对于具有SmithJoint可见性功能的GGX，此校正很有趣，因为在这种情况下，由于粗糙表面的高光边缘，伪像更加可见
//编辑：默认情况下，由于与SpeedTree中使用的两侧照明不兼容，因此默认情况下暂时禁用此代码。
#define UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV 0

#if UNITY_HANDLE_CORRECTLY_NEGATIVE_NDOTV
    // 我们将法线移向视图向量的量由点积定义。
    half shiftAmount = dot(normal, viewDir);
    normal = shiftAmount < 0.0f ? normal + viewDir * (-shiftAmount + 1e-5f) : normal;
    // 应该在此处应用重新规范化，但是由于偏移很小，因此我们不这样做以节省ALU。
    //normal = normalize(normal);

    float nv = saturate(dot(normal, viewDir)); //待办事项：这里不需要饱和
#else
    half nv = abs(dot(normal, viewDir));    // 这绝对可以限制假象
#endif

    float nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));

    half lv = saturate(dot(light.dir, viewDir));
    half lh = saturate(dot(light.dir, halfDir));

    // Diffuse 项
    half diffuseTerm = DisneyDiffuse(nv, nl, lh, perceptualRoughness) * nl;

    // Specular 项
    // HACK：理论上，我们应将diffuseTerm除以Pi，而不要乘以specularTerm！
     //但1）会使着色器看起来比旧版着色器暗得多
     //和2）在引擎中，“非重要”灯在注入周围环境SH的情况下也必须用Pi划分
    float roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
#if UNITY_BRDF_GGX
    //粗糙度为0的GGX完全没有镜面反射，在此使用max（roughness，0.002）匹配HDrenderloop粗糙度重新映射。
    roughness = max(roughness, 0.002);
    float V = SmithJointGGXVisibilityTerm (nl, nv, roughness);
    float D = GGXTerm (nh, roughness);
#else
    // Legacy
    half V = SmithBeckmannVisibilityTerm (nl, nv, roughness);
    half D = NDFBlinnPhongNormalizedTerm (nh, PerceptualRoughnessToSpecPower(perceptualRoughness));
#endif

    float specularTerm = V*D * UNITY_PI; // Torrance-Sparrow模型，菲涅耳稍后应用

#   ifdef UNITY_COLORSPACE_GAMMA
        specularTerm = sqrt(max(1e-4h, specularTerm));
#   endif

    // specularTerm *在某些情况下，nl在金属上可以是NaN，请使用max（）来确保它是一个合理的值
    specularTerm = max(0, specularTerm * nl);
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(roughness^2+1)
    half surfaceReduction;
#   ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;      // 1-0.28*x^3 作为近似值 (1/(x^4+1))^(1/2.2) on the domain [0;1]
#   else
        surfaceReduction = 1.0 / (roughness*roughness + 1.0);           // fade \in [0.5;1]
#   endif

    //为了提供真正的lambert照明，我们需要能够完全消除镜面反射。
    specularTerm *= any(specColor) ? 1.0 : 0.0;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   diffColor * (gi.diffuse + light.color * diffuseTerm)
                    + specularTerm * light.color * FresnelTerm (specColor, lh)
                    + surfaceReduction * gi.specular * FresnelLerp (specColor, grazingTerm, nv);

    return half4(color, 1);
}

//基于极简主义的CookTorrance BRDF
//实现与原始推导略有不同：http://www.thetenthplanet.de/archives/255
//
// * NDF（取决于UNITY_BRDF_GGX）：
// a）BlinnPhong
// b）[修改] GGX
// *修改了Kelemen和Szirmay-Kalos的可见度术语
// *菲涅耳近似为1 / LdotH
half4 BRDF2_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{
    float3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

    half nl = saturate(dot(normal, light.dir));
    float nh = saturate(dot(normal, halfDir));
    half nv = saturate(dot(normal, viewDir));
    float lh = saturate(dot(light.dir, halfDir));

    // Specular term
    half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
    half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

#if UNITY_BRDF_GGX

    // GGX分布乘以可见性和菲涅耳组合近似
    //请参阅Siggraph 2015移动移动图形课程中的“优化移动PBR”
    // https://community.arm.com/events/1155
    half a = roughness;
    float a2 = a*a;

    float d = nh * nh * (a2 - 1.f) + 1.00001f;
#ifdef UNITY_COLORSPACE_GAMMA
    //仅适用于Gamma的渲染模式更严格！
    // DVF = sqrt（DVF）;
    // DVF =（a * sqrt（.25））/（max（sqrt（0.1），lh）* sqrt（粗糙度+ .5）* d）;
    float specularTerm = a / (max(0.32f, lh) * (1.5f + roughness) * d);
#else
    float specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
#endif

    //在手机（其中一半实际上表示某物）分母上有溢出的风险
    //下面的钳位是专门为“修复”而添加的，但是dx编译器（我们将字节码转换为metal / gles）
    //看到specularTerm仅具有非负项，因此它在钳位中跳过max（0，..）（仅保留min（100，...））
#if defined (SHADER_API_MOBILE)
    specularTerm = specularTerm - 1e-4f;
#endif

#else

    // Legacy
    half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
    //使用考虑到粗糙度的近似可见性函数进行修改
    //原始（（n + 1）* N.H ^ n）/（8 * Pi * L.H ^ 3）没有考虑粗糙度
    //并在掠射角产生了非常明亮的镜面

    half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // 大约ModifiedKelemenVisibilityTerm（lh，perceptualRoughness）;
    half invF = lh;

    half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);

#ifdef UNITY_COLORSPACE_GAMMA
    specularTerm = sqrt(max(1e-4f, specularTerm));
#endif

#endif

#if defined (SHADER_API_MOBILE)
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specularTerm = 0.0;
#endif

    // surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

    // 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
    // 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
#ifdef UNITY_COLORSPACE_GAMMA
    half surfaceReduction = 0.28;
#else
    half surfaceReduction = (0.6-0.08*perceptualRoughness);
#endif

    surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
    half3 color =   (diffColor + specularTerm * specColor) * light.color * nl
                    + gi.diffuse * diffColor
                    + surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

    return half4(color, 1);
}

sampler2D_float unity_NHxRoughness;
half3 BRDF3_Direct(half3 diffColor, half3 specColor, half rlPow4, half smoothness)
{ //基于blinn-phong 光照模型的优化实现 
    half LUT_RANGE = 16.0;     //必须与GeneratedTextures.cpp中的NHxRoughness（）函数中的范围匹配
     //查找纹理以保存指令
    half specular = tex2D(unity_NHxRoughness, half2(rlPow4, SmoothnessToPerceptualRoughness(smoothness))).r * LUT_RANGE;
#if defined(_SPECULARHIGHLIGHTS_OFF)
    specular = 0.0;
#endif

    return diffColor + specular * specColor;
}

half3 BRDF3_Indirect(half3 diffColor, half3 specColor, UnityIndirect indirect, half grazingTerm, half fresnelTerm)
{
    half3 c = indirect.diffuse * diffColor;
    c += indirect.specular * lerp (specColor, grazingTerm, fresnelTerm);
    return c;
}

//老派，而不是基于微面的修正归一化Blinn-Phong BRDF
//实现使用Lookup纹理提高性能
//
// *以RDF格式标准化的BlinnPhong
// *隐式可见度术语
// *没有菲涅耳项
//
// TODO：在线性渲染模式下镜面反射太弱
half4 BRDF3_Unity_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
    float3 normal, float3 viewDir,
    UnityLight light, UnityIndirect gi)
{//2.7
    float3 reflDir = reflect (viewDir, normal);

    half nl = saturate(dot(normal, light.dir));
    half nv = saturate(dot(normal, viewDir));

    // 向量化Pow4以保存说明
    half2 rlPow4AndFresnelTerm = Pow4 (float2(dot(reflDir, light.dir), 1-nv));
    //使用R.L代替N.H保存指令  // use R.L instead of N.H to save couple of instructions
    half rlPow4 = rlPow4AndFresnelTerm.x; 
    // 幂指数必须与GeneratedTextures.cpp的NHxRoughness（）函数中的kHorizontalWarpExp相匹配// power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
    half fresnelTerm = rlPow4AndFresnelTerm.y;
    // 简化版 (1-h . wi)4(次方)

    half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));//掠射角项

    half3 color = BRDF3_Direct(diffColor, specColor, rlPow4, smoothness);//直接光部分 
                    //2.7.1
    color *= light.color * nl;
    color += BRDF3_Indirect(diffColor, specColor, gi, grazingTerm, fresnelTerm);//间接光部分
            //2.7.2
    return half4(color, 1);
}

// Include deprecated function
#define INCLUDE_UNITY_STANDARD_BRDF_DEPRECATED
#include "UnityDeprecated.cginc"
#undef INCLUDE_UNITY_STANDARD_BRDF_DEPRECATED

#endif // UNITY_STANDARD_BRDF_INCLUDED
