// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_GLOBAL_ILLUMINATION_INCLUDED
#define UNITY_GLOBAL_ILLUMINATION_INCLUDED

// Functions sampling light environment data (lightmaps, light probes, reflection probes), which is then returned as the UnityGI struct.

#include "UnityImageBasedLighting.cginc"
#include "UnityStandardUtils.cginc"
#include "UnityShadowLibrary.cginc"

inline half3 DecodeDirectionalSpecularLightmap (half3 color, half4 dirTex, half3 normalWorld, bool isRealtimeLightmap, fixed4 realtimeNormalTex, out UnityLight o_light)
{
    o_light.color = color;
    o_light.dir = dirTex.xyz * 2 - 1;
    o_light.ndotl = 0; // Not use;

    // The length of the direction vector is the light's "directionality", i.e. 1 for all light coming from this direction,
    // lower values for more spread out, ambient light.
    half directionality = max(0.001, length(o_light.dir));
    o_light.dir /= directionality;

    #ifdef DYNAMICLIGHTMAP_ON
    if (isRealtimeLightmap)
    {
        // Realtime directional lightmaps' intensity needs to be divided by N.L
        // to get the incoming light intensity. Baked directional lightmaps are already
        // output like that (including the max() to prevent div by zero).
        half3 realtimeNormal = realtimeNormalTex.xyz * 2 - 1;
        o_light.color /= max(0.125, dot(realtimeNormal, o_light.dir));
    }
    #endif

    // Split light into the directional and ambient parts, according to the directionality factor.
    half3 ambient = o_light.color * (1 - directionality);
    o_light.color = o_light.color * directionality;

    // Technically this is incorrect, but helps hide jagged light edge at the object silhouettes and
    // makes normalmaps show up.
    ambient *= saturate(dot(normalWorld, o_light.dir));
    return ambient;
}

inline void ResetUnityLight(out UnityLight outLight)
{
    outLight.color = half3(0, 0, 0);
    outLight.dir = half3(0, 1, 0); // Irrelevant direction, just not null//不相关的方向，但不为null
    outLight.ndotl = 0; // Not used 未使用
}

inline half3 SubtractMainLightWithRealtimeAttenuationFromLightmap (half3 lightmap, half attenuation, half4 bakedColorTex, half3 normalWorld)
{
    //让我们尝试使实时阴影在已经包含表面的表面上起作用
     //烘烤的灯光和主要太阳光的阴影。
    half3 shadowColor = unity_ShadowColor.rgb;
    half shadowStrength = _LightShadowData.x;

    //摘要：
     // 1）通过从实时阴影遮挡的位置减去估计的光贡献来计算阴影中的可能值：
     // a）保留其他烘焙的灯光和反弹光
     // b）消除了背向灯光的几何图形上的阴影
     // 2）锁定用户定义的ShadowColor。
     // 3）选择原始的光照贴图值（如果它是最暗的）。

    //提供良好的照明估计，就好像在烘焙过程中光线会被遮盖一样。
     //保留反射光和其他烘烤的光
     //几何体上没有阴影，远离光
    half ndotl = LambertTerm (normalWorld, _WorldSpaceLightPos0.xyz); //普通lambert 但有平台判断 有性能优化区分
    half3 estimatedLightContributionMaskedByInverseOfShadow = ndotl * (1- attenuation) * _LightColor0.rgb; //阴影区分
    half3 subtractedLightmap = lightmap - estimatedLightContributionMaskedByInverseOfShadow; //减去光照贴图

    // 2）允许用户定义场景的整体环境并在实时阴影变得太暗时控制情况。
    half3 realtimeShadow = max(subtractedLightmap, shadowColor);
    realtimeShadow = lerp(realtimeShadow, lightmap, shadowStrength);

    // 3）选择最暗的颜色 取小
    return min(lightmap, realtimeShadow);
}

inline void ResetUnityGI(out UnityGI outGI)
{   //2.6.2.1.0
    ResetUnityLight(outGI.light); //传递赋值 初始化
    outGI.indirect.diffuse = 0; //初始化
    outGI.indirect.specular = 0;//初始化
}

inline UnityGI UnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld)
{   //2.6.2.1    
    UnityGI o_gi;//结构体声明   color dir ndotl diffuse specular 
    ResetUnityGI(o_gi); //2.6.2.1.0
    //具有光照贴图支持的基本传递负责处理ShadowMask /出于性能原因在此处进行混合
    #if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
        half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos); //烘焙阴影 
        float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz); //当前片元的Z 深度 
        float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist); //计算阴影淡化
        data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist)); //混合动态阴影和静态阴影 
    #endif
    o_gi.light = data.light;
    o_gi.light.color *= data.atten; //对亮度进行衰减
    #if UNITY_SHOULD_SAMPLE_SH //间接光 diffuse 第一步计算 球谐光照
        o_gi.indirect.diffuse = ShadeSHPerPixel(normalWorld, data.ambient, data.worldPos);
    #endif
    #if defined(LIGHTMAP_ON)
        // Baked lightmaps
        half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy); //获取lm
        half3 bakedColor = DecodeLightmap(bakedColorTex); //解压lightmap
        #ifdef DIRLIGHTMAP_COMBINED //定向光照贴图技术 directional lightmap 略
            fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
                ResetUnityLight(o_gi.light); 
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
            #endif
        #else // not directional lightmap 如果没有定向光照贴图
            o_gi.indirect.diffuse += bakedColor; //间接光 diffuse 第二步计算 加上 lightmap
            #if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
            // 当定义lightmap开启 并且 没有开启shadow mask 并且 开启阴影 
            // 经常会碰到烘了lightmap（已经有阴影） 但角色的实时阴影加进不了 lightmap阴影里，此方法应该是较好的解决
                ResetUnityLight(o_gi.light); //重置参数，清零
                o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
                //lambert  lightmap 和阴影  阴影颜色做混合 减去部分光照
            #endif
        #endif
    #endif
    #ifdef DYNAMICLIGHTMAP_ON //动态lightmap 略
        // Dynamic lightmaps
        fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
        half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);
        #ifdef DIRLIGHTMAP_COMBINED
            half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
            o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
        #else
            o_gi.indirect.diffuse += realtimeColor;
        #endif
    #endif
    o_gi.indirect.diffuse *= occlusion; //间接光 diffuse 第三步计算 乘上 AO
    return o_gi;
}


inline half3 UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)  
{  //2.6.2.2
    half3 specular; 
    // 变量声明 
    #ifdef UNITY_SPECCUBE_BOX_PROJECTION        
        // 我们将直接在glossIn中调整reflUVW（因为我们将它分别两次传递给probe0和probe1两次传递给Unity_GlossyEnvironment）
        // 因此请保留原始内容以传递给BoxProjectedCubemapDirection
        half3 originalReflUVW = glossIn.reflUVW;
        glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, 
                                                        data.worldPos, 
                                                        data.probePosition[0], 
                                                        data.boxMin[0], 
                                                        data.boxMax[0]);
        // 获取立方体贴图的方向向量  视线向量相对于片元的法向量相反反射向量延长
    #endif
    #ifdef _GLOSSYREFLECTIONS_OFF
        specular = unity_IndirectSpecColor.rgb;
    #else
        half3 env0 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
        // 环境球
        #ifdef UNITY_SPECCUBE_BLENDING //反射球混合
            const float kBlendFactor = 0.99999;
            float blendLerp = data.boxMin[0].w;
            UNITY_BRANCH
            if (blendLerp < kBlendFactor)
            {
                #ifdef UNITY_SPECCUBE_BOX_PROJECTION
                    glossIn.reflUVW = BoxProjectedCubemapDirection (originalReflUVW, data.worldPos, data.probePosition[1], data.boxMin[1], data.boxMax[1]);
                #endif
                half3 env1 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0), data.probeHDR[1], glossIn);
                specular = lerp(env1, env0, blendLerp);
            }
            else
            {
                specular = env0;
            }
        #else
            specular = env0;
        #endif
    #endif
    return specular * occlusion; //最后乘上AO
}

// Deprecated old prototype but can't be move to Deprecated.cginc file due to order dependency
// 不推荐使用的旧原型，但由于订单依赖性而无法移至Deprecated.cginc文件
inline half3 UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{
    // normalWorld is not used
    //不使用normalWorld
    return UnityGI_IndirectSpecular(data, occlusion, glossIn);
}

inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half3 normalWorld) 
{   //2.6.3
    return UnityGI_Base(data, occlusion, normalWorld);  //2.6.2.1
}
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half3 normalWorld, Unity_GlossyEnvironmentData glossIn)
{   //2.6.2
    //输入
    // UnityGIInput
    // {
    //     UnityLight light;        //UnityLight 结构体 包含color dir ndotl
    //     float3 worldPos;
    //     half3 worldViewDir;
    //     half atten;
    //     half3 ambient;
    //     float4 lightmapUV;
    //     float4 boxMax[2];
    //     float4 probePosition[2];
    //     float4 probeHDR[2];
    // }
    // 输入 Unity_GlossyEnvironmentData
    // {
    //     half    roughness;
    //     half3   reflUVW;
    // };
    //输出UnityGI返回五个数值 color dir ndotl diffuse specular 
    UnityGI o_gi = UnityGI_Base(data, occlusion, normalWorld); //2.6.2.1
    //lightmap 计算
    o_gi.indirect.specular = UnityGI_IndirectSpecular(data, occlusion, glossIn);  //2.6.2.2
    //间接反射 
    return o_gi;
}

//
// Old UnityGlobalIllumination signatures. Kept only for backward compatibility and will be removed soon
//旧的UnityGlobalIllumination签名。 保留仅用于向后兼容，将很快删除
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half smoothness, half3 normalWorld, bool reflections)
{
    if(reflections)
    {
        Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(smoothness, data.worldViewDir, normalWorld, float3(0, 0, 0));
        return UnityGlobalIllumination(data, occlusion, normalWorld, g);
    }
    else
    {
        return UnityGlobalIllumination(data, occlusion, normalWorld);
    }
}
inline UnityGI UnityGlobalIllumination (UnityGIInput data, half occlusion, half smoothness, half3 normalWorld)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
    // No need to sample reflection probes during deferred G-buffer pass
    bool sampleReflections = false;
#else
    bool sampleReflections = true;
#endif
    return UnityGlobalIllumination (data, occlusion, smoothness, normalWorld, sampleReflections);
}


#endif
