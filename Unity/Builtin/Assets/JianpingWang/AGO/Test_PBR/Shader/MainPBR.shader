Shader "JianpingWang/PBR"  // 20201020
{
    Properties 
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _MetallicGlossMap ("MetallicRoughness", 2D) = "white" {}
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        
        _BumpScale("Scale", Float) = 1.0
        [Normal] _BumpMap("Normal Map", 2D) = "bump" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}
    }

    CGINCLUDE
        #define aUNITY_SETUP_BRDF_INPUT aMetallicSetup
    ENDCG  //定义不同的工作流  MetallicSetup 函数名 

    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma target 3.0
            
            #pragma vertex vert 
            #pragma fragment frag 
            #pragma multi_compile_fwdbase


            #define _aNORMALMAP
            #define _EMISSION
            // #pragma multi_compile _ LOD_FADE_CROSSFADE

            
            #include "CoreFunction.cginc"

            ENDCG
        }


        // ------------------------------------------------------------------
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------


            // #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            // #pragma shader_feature_local _METALLICGLOSSMAP
            // #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // #pragma shader_feature_local _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            // #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
    }
}


