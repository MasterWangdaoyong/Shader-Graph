// JianpingWang
// 时间：20201128
// 功能：Shader面板

using System;
using UnityEngine;
// using TargetAttributes = UnityEditor.BuildTargetDiscovery.TargetAttributes;

// namespace UnityEditor
// {
//     internal class Time_PBR_Editor : ShaderGUI
//     {
// //        
//         private enum WorkflowMode
//         {
//             Specular,
//             Metallic,
//             Dielectric
//         }

//         public enum BlendMode
//         {
//             Opaque,
//             Cutout,
//             // Fade,   // 老派Alpha混合模式，菲涅耳不影响透明度
//             Transparent // 物理上可行的透明模式，实现为alpha预乘
//         }

//         // public enum SmoothnessMapChannel
//         // {
//         //     SpecularMetallicAlpha,
//         //     AlbedoAlpha,
//         // }
// //
//         private static class Styles //面板属性说明
//         {
//             // public static GUIContent uvSetLabel = EditorGUIUtility.TrTextContent("UV Set");

//             public static GUIContent albedoText = EditorGUIUtility.TrTextContent("Albedo", "Albedo (RGB) and Transparency (A)");
//             // public static GUIContent alphaCutoffText = EditorGUIUtility.TrTextContent("Alpha Cutoff", "Threshold for alpha cutoff");
//             // public static GUIContent specularMapText = EditorGUIUtility.TrTextContent("Specular", "Specular (RGB) and Smoothness (A)");
//             public static GUIContent metallicMapText = EditorGUIUtility.TrTextContent("Metallic", "Metallic (R) and Smoothness (A)");
//             public static GUIContent smoothnessText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness value");
//             public static GUIContent smoothnessScaleText = EditorGUIUtility.TrTextContent("Smoothness", "Smoothness scale factor");
//             public static GUIContent smoothnessMapChannelText = EditorGUIUtility.TrTextContent("Source", "Smoothness texture and channel");
//             public static GUIContent highlightsText = EditorGUIUtility.TrTextContent("Specular Highlights", "Specular Highlights");
//             public static GUIContent reflectionsText = EditorGUIUtility.TrTextContent("Reflections", "Glossy Reflections");
//             public static GUIContent normalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map");
//             // public static GUIContent heightMapText = EditorGUIUtility.TrTextContent("Height Map", "Height Map (G)");
//             public static GUIContent occlusionText = EditorGUIUtility.TrTextContent("Occlusion", "Occlusion (G)");
//             public static GUIContent emissionText = EditorGUIUtility.TrTextContent("Color", "Emission (RGB)");
//             // public static GUIContent detailMaskText = EditorGUIUtility.TrTextContent("Detail Mask", "Mask for Secondary Maps (A)");
//             // public static GUIContent detailAlbedoText = EditorGUIUtility.TrTextContent("Detail Albedo x2", "Albedo (RGB) multiplied by 2");
//             // public static GUIContent detailNormalMapText = EditorGUIUtility.TrTextContent("Normal Map", "Normal Map");

//             public static string primaryMapsText = "Main Maps";
//             // public static string secondaryMapsText = "Secondary Maps";
//             public static string forwardText = "Forward Rendering Options";
//             // public static string renderingMode = "Rendering Mode";
//             public static string advancedText = "Advanced Options";
//             // public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
//         }


// //      材质属性 变量声明
//         // MaterialProperty blendMode = null;
//         MaterialProperty albedoMap = null;
//         MaterialProperty albedoColor = null;
//         // MaterialProperty alphaCutoff = null;
//         MaterialProperty specularMap = null;
//         MaterialProperty specularColor = null;
//         MaterialProperty metallicMap = null;
//         MaterialProperty metallic = null;
//         MaterialProperty smoothness = null;
//         MaterialProperty smoothnessScale = null;
//         MaterialProperty smoothnessMapChannel = null;
//         MaterialProperty highlights = null;
//         MaterialProperty reflections = null;
//         MaterialProperty bumpScale = null;
//         MaterialProperty bumpMap = null;
//         MaterialProperty occlusionStrength = null;
//         MaterialProperty occlusionMap = null;
//         // MaterialProperty heigtMapScale = null;
//         // MaterialProperty heightMap = null;
//         MaterialProperty emissionColorForRendering = null;
//         MaterialProperty emissionMap = null;
//         // MaterialProperty detailMask = null;
//         // MaterialProperty detailAlbedoMap = null;
//         // MaterialProperty detailNormalMapScale = null;
//         // MaterialProperty detailNormalMap = null;
//         // MaterialProperty uvSetSecondary = null;

//         MaterialEditor m_MaterialEditor;
//         // WorkflowMode m_WorkflowMode = WorkflowMode.Specular;

//         // bool m_FirstTimeApply = true;

//         public void FindProperties(MaterialProperty[] props)    //查找Shader变量
//         {
//             blendMode = FindProperty("_Mode", props);
//             albedoMap = FindProperty("_MainTex", props);
//             albedoColor = FindProperty("_Color", props);
//             alphaCutoff = FindProperty("_Cutoff", props);
//             // specularMap = FindProperty("_SpecGlossMap", props, false);
//             // specularColor = FindProperty("_SpecColor", props, false);
//             metallicMap = FindProperty("_MetallicGlossMap", props, false);
//             metallic = FindProperty("_Metallic", props, false);
//             // if (specularMap != null && specularColor != null)
//             //     m_WorkflowMode = WorkflowMode.Specular;
//             // else if (metallicMap != null && metallic != null)
//                 m_WorkflowMode = WorkflowMode.Metallic;
//             // else
//                 // m_WorkflowMode = WorkflowMode.Dielectric;
//             smoothness = FindProperty("_Glossiness", props);
//             smoothnessScale = FindProperty("_GlossMapScale", props, false);
//             smoothnessMapChannel = FindProperty("_SmoothnessTextureChannel", props, false);
//             highlights = FindProperty("_SpecularHighlights", props, false);
//             reflections = FindProperty("_GlossyReflections", props, false);
//             bumpScale = FindProperty("_BumpScale", props);
//             bumpMap = FindProperty("_BumpMap", props);
//             // heigtMapScale = FindProperty("_Parallax", props);
//             // heightMap = FindProperty("_ParallaxMap", props);
//             occlusionStrength = FindProperty("_OcclusionStrength", props);
//             occlusionMap = FindProperty("_OcclusionMap", props);
//             emissionColorForRendering = FindProperty("_EmissionColor", props);
//             emissionMap = FindProperty("_EmissionMap", props);
//             // detailMask = FindProperty("_DetailMask", props);
//             // detailAlbedoMap = FindProperty("_DetailAlbedoMap", props);
//             // detailNormalMapScale = FindProperty("_DetailNormalMapScale", props);
//             // detailNormalMap = FindProperty("_DetailNormalMap", props);
//             // uvSetSecondary = FindProperty("_UVSec", props);
//         }

//         public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props) //循环检测 一直刷新着
//         {
//             FindProperties(props); //MaterialProperty可以设置动画，因此我们不缓存它们，而是在每个事件中都获取它们，以确保正确更新动画值
//             m_MaterialEditor = materialEditor;
//             Material material = materialEditor.target as Material;

//             //如果我们要切换一些现有设置，请确保已设置所需的设置（即关键字/渲染队列）
//             //作为标准着色器的材质。
//             //在发出任何GUI代码之前执行此操作，以防止后续GUILayout语句中出现布局问题（案例780071）
//             if (m_FirstTimeApply)
//             {
//                 MaterialChanged(material, m_WorkflowMode);
//                 m_FirstTimeApply = false;
//             }

//             ShaderPropertiesGUI(material);
//         }

//         public void ShaderPropertiesGUI(Material material)  //GUI面板绘制
//         {
//             //使用默认的labelWidth
//             EditorGUIUtility.labelWidth = 0f;

//             //检测材料的任何变化
//             EditorGUI.BeginChangeCheck();
//             {
//                 BlendModePopup();

//                 //主要属性
//                 GUILayout.Label(Styles.primaryMapsText, EditorStyles.boldLabel);
//                 DoAlbedoArea(material);
//                 DoSpecularMetallicArea();
//                 DoNormalArea();
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap, heightMap.textureValue != null ? heigtMapScale : null);
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.detailMaskText, detailMask);
//                 DoEmissionArea(material);
//                 EditorGUI.BeginChangeCheck();
//                 m_MaterialEditor.TextureScaleOffsetProperty(albedoMap);
//                 if (EditorGUI.EndChangeCheck())
//                     emissionMap.textureScaleAndOffset = albedoMap.textureScaleAndOffset;//为启发起见，也将主纹理比例和偏移量也应用于发射纹理

//                 EditorGUILayout.Space();

//                 //次要属性
//                 GUILayout.Label(Styles.secondaryMapsText, EditorStyles.boldLabel);
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.detailAlbedoText, detailAlbedoMap);
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.detailNormalMapText, detailNormalMap, detailNormalMapScale);
//                 m_MaterialEditor.TextureScaleOffsetProperty(detailAlbedoMap);
//                 m_MaterialEditor.ShaderProperty(uvSetSecondary, Styles.uvSetLabel.text);

//                 //第三个属性
//                 GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);
//                 if (highlights != null)
//                     m_MaterialEditor.ShaderProperty(highlights, Styles.highlightsText);
//                 if (reflections != null)
//                     m_MaterialEditor.ShaderProperty(reflections, Styles.reflectionsText);
//             }
//             if (EditorGUI.EndChangeCheck())
//             {
//                 foreach (var obj in blendMode.targets)
//                     MaterialChanged((Material)obj, m_WorkflowMode);
//             }

//             EditorGUILayout.Space();

//             // NB renderqueue编辑器未故意显示：我们要基于混合模式覆盖它
//             GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
//             m_MaterialEditor.EnableInstancingField();
//             m_MaterialEditor.DoubleSidedGIField();
//         }

//         internal void DetermineWorkflow(MaterialProperty[] props)
//         {
//             if (FindProperty("_SpecGlossMap", props, false) != null && FindProperty("_SpecColor", props, false) != null)
//                 m_WorkflowMode = WorkflowMode.Specular;
//             else if (FindProperty("_MetallicGlossMap", props, false) != null && FindProperty("_Metallic", props, false) != null)
//                 m_WorkflowMode = WorkflowMode.Metallic;
//             else
//                 m_WorkflowMode = WorkflowMode.Dielectric;
//         }

//         public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
//         {
//             //将标准着色器分配给材质后，_Emission属性丢失
//             //因此在分配新的着色器之前先进行传输
//             if (material.HasProperty("_Emission"))
//             {
//                 material.SetColor("_EmissionColor", material.GetColor("_Emission"));
//             }

//             base.AssignNewShaderToMaterial(material, oldShader, newShader);

//             if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
//             {
//                 SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
//                 return;
//             }

//             BlendMode blendMode = BlendMode.Opaque;
//             if (oldShader.name.Contains("/Transparent/Cutout/"))
//             {
//                 blendMode = BlendMode.Cutout;
//             }
//             else if (oldShader.name.Contains("/Transparent/"))
//             {
//                 //注意：旧版着色器不提供基于物理的透明度
//                 //因此，淡入淡出模式
//                 blendMode = BlendMode.Fade;
//             }
//             material.SetFloat("_Mode", (float)blendMode);

//             DetermineWorkflow(MaterialEditor.GetMaterialProperties(new Material[] { material }));
//             MaterialChanged(material, m_WorkflowMode);
//         }

//         void BlendModePopup()
//         {
//             EditorGUI.showMixedValue = blendMode.hasMixedValue;
//             var mode = (BlendMode)blendMode.floatValue;

//             EditorGUI.BeginChangeCheck();
//             mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
//             if (EditorGUI.EndChangeCheck())
//             {
//                 m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
//                 blendMode.floatValue = (float)mode;
//             }

//             EditorGUI.showMixedValue = false;
//         }

//         void DoNormalArea()
//         {
//             m_MaterialEditor.TexturePropertySingleLine(Styles.normalMapText, bumpMap, bumpMap.textureValue != null ? bumpScale : null);
//             if (bumpScale.floatValue != 1
//                 && BuildTargetDiscovery.PlatformHasFlag(EditorUserBuildSettings.activeBuildTarget, TargetAttributes.HasIntegratedGPU))
//                 if (m_MaterialEditor.HelpBoxWithButton(
//                     EditorGUIUtility.TrTextContent("Bump scale is not supported on mobile platforms"),
//                     EditorGUIUtility.TrTextContent("Fix Now")))
//                 {
//                     bumpScale.floatValue = 1;
//                 }
//         }

//         void DoAlbedoArea(Material material)
//         {
//             m_MaterialEditor.TexturePropertySingleLine(Styles.albedoText, albedoMap, albedoColor);
//             if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
//             {
//                 m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
//             }
//         }

//         void DoEmissionArea(Material material)
//         {
//             // Emission for GI?
//             if (m_MaterialEditor.EmissionEnabledProperty())
//             {
//                 bool hadEmissionTexture = emissionMap.textureValue != null;

//                 //纹理和HDR颜色控件
//                 m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, false);

//                 //如果指定了纹理并且颜色为黑色，则将颜色设置为白色
//                 float brightness = emissionColorForRendering.colorValue.maxColorComponent;
//                 if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
//                     emissionColorForRendering.colorValue = Color.white;

//                 //更改GI标志并在必要时将其固定为黑色
//                 m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
//             }
//         }

//         void DoSpecularMetallicArea()
//         {
//             bool hasGlossMap = false;
//             if (m_WorkflowMode == WorkflowMode.Specular)
//             {
//                 hasGlossMap = specularMap.textureValue != null;
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.specularMapText, specularMap, hasGlossMap ? null : specularColor);
//             }
//             else if (m_WorkflowMode == WorkflowMode.Metallic)
//             {
//                 hasGlossMap = metallicMap.textureValue != null;
//                 m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMapText, metallicMap, hasGlossMap ? null : metallic);
//             }

//             bool showSmoothnessScale = hasGlossMap;
//             if (smoothnessMapChannel != null)
//             {
//                 int smoothnessChannel = (int)smoothnessMapChannel.floatValue;
//                 if (smoothnessChannel == (int)SmoothnessMapChannel.AlbedoAlpha)
//                     showSmoothnessScale = true;
//             }

//             int indentation = 2; //与纹理属性的标签对齐
//             m_MaterialEditor.ShaderProperty(showSmoothnessScale ? smoothnessScale : smoothness, showSmoothnessScale ? Styles.smoothnessScaleText : Styles.smoothnessText, indentation);

//             ++indentation;
//             if (smoothnessMapChannel != null)
//                 m_MaterialEditor.ShaderProperty(smoothnessMapChannel, Styles.smoothnessMapChannelText, indentation);
//         }

//         public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
//         {
//             switch (blendMode)
//             {
//                 case BlendMode.Opaque:
//                     material.SetOverrideTag("RenderType", "");
//                     material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
//                     material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
//                     material.SetInt("_ZWrite", 1);
//                     material.DisableKeyword("_ALPHATEST_ON");
//                     material.DisableKeyword("_ALPHABLEND_ON");
//                     material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
//                     material.renderQueue = -1;
//                     break;
//                 case BlendMode.Cutout:
//                     material.SetOverrideTag("RenderType", "TransparentCutout");
//                     material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
//                     material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
//                     material.SetInt("_ZWrite", 1);
//                     material.EnableKeyword("_ALPHATEST_ON");
//                     material.DisableKeyword("_ALPHABLEND_ON");
//                     material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
//                     material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
//                     break;
//                 case BlendMode.Fade:
//                     material.SetOverrideTag("RenderType", "Transparent");
//                     material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
//                     material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
//                     material.SetInt("_ZWrite", 0);
//                     material.DisableKeyword("_ALPHATEST_ON");
//                     material.EnableKeyword("_ALPHABLEND_ON");
//                     material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
//                     material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
//                     break;
//                 case BlendMode.Transparent:
//                     material.SetOverrideTag("RenderType", "Transparent");
//                     material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
//                     material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
//                     material.SetInt("_ZWrite", 0);
//                     material.DisableKeyword("_ALPHATEST_ON");
//                     material.DisableKeyword("_ALPHABLEND_ON");
//                     material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
//                     material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
//                     break;
//             }
//         }

//         static SmoothnessMapChannel GetSmoothnessMapChannel(Material material)
//         {
//             int ch = (int)material.GetFloat("_SmoothnessTextureChannel");
//             if (ch == (int)SmoothnessMapChannel.AlbedoAlpha)
//                 return SmoothnessMapChannel.AlbedoAlpha;
//             else
//                 return SmoothnessMapChannel.SpecularMetallicAlpha;
//         }

//         static void SetMaterialKeywords(Material material, WorkflowMode workflowMode)
//         {
//             //注意：由于多重编辑和材质动画，关键字必须基于材质值而不是基于MaterialProperty
//             //（MaterialProperty值可能来自渲染器材质属性块）
//             SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap") || material.GetTexture("_DetailNormalMap"));
//             if (workflowMode == WorkflowMode.Specular)
//                 SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap"));
//             else if (workflowMode == WorkflowMode.Metallic)
//                 SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));
//             SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
//             SetKeyword(material, "_DETAIL_MULX2", material.GetTexture("_DetailAlbedoMap") || material.GetTexture("_DetailNormalMap"));

//             //材质的GI标志在内部跟踪是否完全启用了发射，启用了发射但没有任何作用
//             //或已启用，可以在运行时进行修改。 此状态取决于当前标志和发射颜色的值。
//             //如果更改模式或颜色，则修正程序可确保材料处于正确的状态。
//             MaterialEditor.FixupEmissiveFlag(material);
//             bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
//             SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);

//             if (material.HasProperty("_SmoothnessTextureChannel"))
//             {
//                 SetKeyword(material, "_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A", GetSmoothnessMapChannel(material) == SmoothnessMapChannel.AlbedoAlpha);
//             }
//         }

//         static void MaterialChanged(Material material, WorkflowMode workflowMode)
//         {
//             SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));

//             SetMaterialKeywords(material, workflowMode);
//         }

//         static void SetKeyword(Material m, string keyword, bool state)
//         {
//             if (state)
//                 m.EnableKeyword(keyword);
//             else
//                 m.DisableKeyword(keyword);
//         }
//     }
// } // namespace UnityEditor


// 参考 ： http://www.qiankanglai.me/2016/09/25/shader-feature/
//Shader部分
// #pragma
//  shader_feature _EMISSIONMAP
// #if _EMISSIONMAP
// sampler2D _EmissionMap;
// #endif

// fixed4 sgpbr_frag(v2f i) : SV_Target
// {
//   fixed3 Color = 0;
// #if _EMISSIONMAP
//   Color += tex2D(_EmissionMap, i.tex).rgb;
// #endif
//   return fixed4(Color, 1);
// }
// 这里比较好理解，相当于自发光相关的代码都利用_EMISSIONMAP这个宏包起来了。
// ps.记得在最后加上CustomEditor "SGPBRInspector"…

//C#部分
// 这里参考了官方的Standard的编辑器代码S tandardShaderGUI.cs。其实和其他inspector一样，最核心的几行就是根据某个属性是否贴了贴图，打开或关闭对应的宏…
// override public void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
// {
//   MaterialProperty emissionMap = ShaderGUI.FindProperty("_EmissionMap", props);
//   bool emissionEnabled = emissionMap.textureValue != null;
//   Material material = materialEditor.target as Material;
//   if (emissionEnabled)
//       material.EnableKeyword("_EMISSIONMAP");
//   else
//       material.DisableKeyword("_EMISSIONMAP");
// }