// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_UTILS_INCLUDED
#define UNITY_STANDARD_UTILS_INCLUDED

#include "UnityCG.cginc"
#include "UnityStandardConfig.cginc"

// Helper functions, maybe move into UnityCG.cginc

half SpecularStrength(half3 specular)
{
    #if (SHADER_TARGET < 30)
        // SM2.0: instruction count limitation
        // SM2.0: simplified SpecularStrength
        return specular.r; // Red channel - because most metals are either monocrhome or with redish/yellowish tint
    #else
        return max (max (specular.r, specular.g), specular.b);
    #endif
}

// Diffuse/Spec Energy conservation
inline half3 EnergyConservationBetweenDiffuseAndSpecular (half3 albedo, half3 specColor, out half oneMinusReflectivity)
{
    oneMinusReflectivity = 1 - SpecularStrength(specColor);
    #if !UNITY_CONSERVE_ENERGY
        return albedo;
    #elif UNITY_CONSERVE_ENERGY_MONOCHROME
        return albedo * oneMinusReflectivity;
    #else
        return albedo * (half3(1,1,1) - specColor);
    #endif
}

inline half OneMinusReflectivityFromMetallic(half metallic) //003a2
{   
    // We'll need oneMinusReflectivity, so
    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
    // store (1-dielectricSpec) in unity_ColorSpaceDielectricSpec.a, then
    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
    //                  = alpha - metallic * alpha
    //gamma #define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
    //linear #define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)
    half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
    //gamma 1.0 - 0.220916301 = 0.779083699
    //linear 1.0 - 0.04 = 0.96
    //取值
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
    //gamma 0.779083699 - metallic * 0.779083699
    //linear 0.96 - metallic * 0.96
}

inline half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity) //003a
{    
    specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
    //specColor 镜面反射率。使用金属度去混合电介质与albedo颜色
    //gamma #define unity_ColorSpaceDielectricSpec half4(0.220916301, 0.220916301, 0.220916301, 1.0 - 0.220916301)
    //linear #define unity_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04) // standard dielectric reflectivity coef at incident angle (= 4%)
    //颜色空间不一样 计算方式不一样 结果顺理就不一样了
    //metallic 值越大镜面反射率就是 albedo，值越小就是 unity_ColorSpaceDielectricSpec
    //工作流中 PBR 资源制作时 正常情况下会及少画非金属 也就是说只画金属与非金属 非1即0 中间值是半导体 又是金属又是非金 Substance流中可以自动化检测
    
    oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic); //003a2 特定数值范围内，反向
    //oneMinusReflectivity 漫反射率

    //如果 metallic = 0 非金属 在gamma空间中漫反射 ＝ albedo * 0.779083699 接近1，漫反射颜色接近白色。结果差不多是albedo的直接颜色 （不同的颜色空间颜色不一样，切记）
    //如果 metallic = 1 金属  在gamma空间中的漫反射 ＝ albedo * 0 完全没有漫反射颜色 黑色
    //如果 metallic 介于之间 就使用上述插值 
    return albedo * oneMinusReflectivity;
    //返回 漫反射颜色部分
}

inline half3 PreMultiplyAlpha (half3 diffColor, half alpha, half oneMinusReflectivity, out half outModifiedAlpha)
{   //2.2.6
    #if defined(_ALPHAPREMULTIPLY_ON)
        //注意：着色器依赖于预乘alpha混合（_SrcBlend = One，_DstBlend = OneMinusSrcAlpha）
        //透明度从“漫反射”组件中“删除”
        diffColor *= alpha;
        #if (SHADER_TARGET < 30)
            // SM2.0：指令计数限制
            //相反，它会牺牲部分基于物理的透明度，其中反射率会影响透明度
            // SM2.0：使用未修改的Alpha
            outModifiedAlpha = alpha;
        #else
            //反射率从其他组件中“消除”，包括透明度
            // outAlpha = 1-(1-alpha)*(1-reflectivity) = 1-(oneMinusReflectivity - alpha*oneMinusReflectivity) =
            //          = 1-oneMinusReflectivity + alpha*oneMinusReflectivity
            outModifiedAlpha = 1 - oneMinusReflectivity + alpha * oneMinusReflectivity;
        #endif
    #else
        outModifiedAlpha = alpha;
    #endif
    return diffColor;
}

// Same as ParallaxOffset in Unity CG, except:
//  *) precision - half instead of float
half2 ParallaxOffset1Step (half h, half height, half3 viewDir)
{
    h = h * height - height/2.0;
    half3 v = normalize(viewDir);
    v.z += 0.42;
    return h * (v.xy / v.z);
}

half LerpOneTo(half b, half t)
{
    half oneMinusT = 1 - t;
    return oneMinusT + b * t;
}

half3 LerpWhiteTo(half3 b, half t)
{
    half oneMinusT = 1 - t;
    return half3(oneMinusT, oneMinusT, oneMinusT) + b * t;
    //(1-t) + b * t
}

half3 UnpackScaleNormalDXT5nm(half4 packednormal, half bumpScale)
{
    half3 normal;
    normal.xy = (packednormal.wy * 2 - 1);
    #if (SHADER_TARGET >= 30)
        // SM2.0: instruction count limitation
        // SM2.0: normal scaler is not supported
        normal.xy *= bumpScale;
    #endif
    normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
    return normal;
}

half3 UnpackScaleNormalRGorAG(half4 packednormal, half bumpScale)
{
    #if defined(UNITY_NO_DXT5nm)
        half3 normal = packednormal.xyz * 2 - 1;
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        return normal;
    #else
        // This do the trick
        packednormal.x *= packednormal.w;

        half3 normal;
        normal.xy = (packednormal.xy * 2 - 1);
        #if (SHADER_TARGET >= 30)
            // SM2.0: instruction count limitation
            // SM2.0: normal scaler is not supported
            normal.xy *= bumpScale;
        #endif
        normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
        return normal;
    #endif
}

half3 UnpackScaleNormal(half4 packednormal, half bumpScale)
{
    return UnpackScaleNormalRGorAG(packednormal, bumpScale);
}

half3 BlendNormals(half3 n1, half3 n2)
{
    return normalize(half3(n1.xy + n2.xy, n1.z*n2.z));
}

half3x3 CreateTangentToWorldPerVertex(half3 normal, half3 tangent, half tangentSign) 
{   //1.3
    // For odd-negative scale transforms we need to flip the sign
    //对于奇数负比例变换，我们需要翻转符号
    half sign = tangentSign * unity_WorldTransformParams.w;
    // w is usually 1.0, or -1.0 for odd-negative scale transforms
    //w通常为1.0，对于奇数负比例转换，通常为-1.0
    half3 binormal = cross(normal, tangent) * sign;
    //叉积 判断正反
    return half3x3(tangent, binormal, normal);
    //返回矩阵数据
}

//-------------------------------------------------------------------------------------
half3 ShadeSHPerVertex (half3 normal, half3 ambient)
{
    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // 完全按像素
        // 无用事项
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // 完全按顶点
        ambient += max(half3(0,0,0), ShadeSH9 (half4(normal, 1.0)));
    #else
        // 每顶点L2，每像素L0..L1和伽马校正

        // 注意：SH数据始终处于线性状态，并且计算在顶点和像素之间划分
        // 将环境转换为线性，并在最后进行最终的伽玛校正（每像素）
        #ifdef UNITY_COLORSPACE_GAMMA
            ambient = GammaToLinearSpace (ambient);
        #endif
        ambient += SHEvalLinearL2 (half4(normal, 1.0));     // 没有最大值，因为这只是L2贡献
    #endif
    return ambient;
}

half3 ShadeSHPerPixel (half3 normal, half3 ambient, float3 worldPos)
{
    half3 ambient_contrib = 0.0;
    
    #if UNITY_SAMPLE_FULL_SH_PER_PIXEL
        // 完全按像素 片元中每顶点计算球谐
            #if UNITY_LIGHT_PROBE_PROXY_VOLUME
                if (unity_ProbeVolumeParams.x == 1.0)
                    ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume(half4(normal, 1.0), worldPos);
                else
                    ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
            #else
                ambient_contrib = SHEvalLinearL0L1(half4(normal, 1.0));
            #endif
        ambient_contrib += SHEvalLinearL2(half4(normal, 1.0));
        ambient += max(half3(0, 0, 0), ambient_contrib);
            #ifdef UNITY_COLORSPACE_GAMMA
                ambient = LinearToGammaSpace(ambient);
            #endif
    #elif (SHADER_TARGET < 30) || UNITY_STANDARD_SIMPLE
        // 完全按像素
        // 无事。 SH的环境上的Gamma转换在顶点着色器中进行，请参见ShadeSHPerVertex。
    #else
        // 每顶点L2，每像素L0..L1和伽马校正
        // 在这种情况下，环境始终是线性的，请参见ShadeSHPerVertex（）
            #if UNITY_LIGHT_PROBE_PROXY_VOLUME
                if (unity_ProbeVolumeParams.x == 1.0)
                    ambient_contrib = SHEvalLinearL0L1_SampleProbeVolume (half4(normal, 1.0), worldPos);
                else
                    ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
            #else
                ambient_contrib = SHEvalLinearL0L1 (half4(normal, 1.0));
            #endif
        ambient = max(half3(0, 0, 0), ambient + ambient_contrib);     // 之前在顶点着色器中包含L2贡献。
            #ifdef UNITY_COLORSPACE_GAMMA
                ambient = LinearToGammaSpace (ambient);
            #endif
    #endif
    return ambient;
}

//-------------------------------------------------------------------------------------
inline float3 BoxProjectedCubemapDirection (float3 worldRefl, float3 worldPos, float4 cubemapCenter, float4 boxMin, float4 boxMax)
{
    //我们有一个有效的反射探头吗？
    UNITY_BRANCH
    if (cubemapCenter.w > 0.0)
    {
        float3 nrdir = normalize(worldRefl);
        #if 1
            float3 rbmax = (boxMax.xyz - worldPos) / nrdir;
            float3 rbmin = (boxMin.xyz - worldPos) / nrdir;
            float3 rbminmax = (nrdir > 0.0f) ? rbmax : rbmin;
        #else // 优化版本
            float3 rbmax = (boxMax.xyz - worldPos);
            float3 rbmin = (boxMin.xyz - worldPos);
            float3 select = step (float3(0,0,0), nrdir);
            float3 rbminmax = lerp (rbmax, rbmin, select);
            rbminmax /= nrdir;
        #endif
        float fa = min(min(rbminmax.x, rbminmax.y), rbminmax.z);
        worldPos -= cubemapCenter.xyz;
        worldRefl = worldPos + nrdir * fa;
    }
    return worldRefl;
}


//-------------------------------------------------------------------------------------
// Derivative maps
// http://www.rorydriscoll.com/2012/01/11/derivative-maps/
// For future use.

// Project the surface gradient (dhdx, dhdy) onto the surface (n, dpdx, dpdy)
half3 CalculateSurfaceGradient(half3 n, half3 dpdx, half3 dpdy, half dhdx, half dhdy)
{
    half3 r1 = cross(dpdy, n);
    half3 r2 = cross(n, dpdx);
    return (r1 * dhdx + r2 * dhdy) / dot(dpdx, r1);
}

// Move the normal away from the surface normal in the opposite surface gradient direction
half3 PerturbNormal(half3 n, half3 dpdx, half3 dpdy, half dhdx, half dhdy)
{
    //TODO: normalize seems to be necessary when scales do go beyond the 2...-2 range, should we limit that?
    //how expensive is a normalize? Anything cheaper for this case?
    return normalize(n - CalculateSurfaceGradient(n, dpdx, dpdy, dhdx, dhdy));
}

// Calculate the surface normal using the uv-space gradient (dhdu, dhdv)
half3 CalculateSurfaceNormal(half3 position, half3 normal, half2 gradient, half2 uv)
{
    half3 dpdx = ddx(position);
    half3 dpdy = ddy(position);

    half dhdx = dot(gradient, ddx(uv));
    half dhdy = dot(gradient, ddy(uv));

    return PerturbNormal(normal, dpdx, dpdy, dhdx, dhdy);
}


#endif // UNITY_STANDARD_UTILS_INCLUDED
