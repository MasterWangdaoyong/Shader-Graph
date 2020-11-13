using UnityEngine; 
using UnityEditor;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;

public static class SceneShadows
{
    [MenuItem("GameObject/SceneShadows/On", false, 0)]
    static void SceneShadowsMode_On()
    {
        SceneShadowsMode(ShadowCastingMode.On);
    }

    [MenuItem("GameObject/SceneShadows/Off", false, 0)]
    static void SceneShadowsMode_Off()
    {
        SceneShadowsMode(ShadowCastingMode.Off);
    }

    [MenuItem("GameObject/SceneShadows/TwoSided", false, 0)]
    static void SceneShadowsMode_TwoSided()
    {
        SceneShadowsMode(ShadowCastingMode.TwoSided);
    }

    [MenuItem("GameObject/SceneShadows/ShadowsOnly", false, 0)]
    static void SceneShadowsMode_ShadowsOnly()
    {
        SceneShadowsMode(ShadowCastingMode.ShadowsOnly);
    }

    
    static void SceneShadowsMode(ShadowCastingMode mode)
    {
        GameObject obj = Selection.activeObject as GameObject;
        if (obj != null)
        {
            Renderer[] rendererList = obj.GetComponentsInChildren<Renderer>(true);
            if (rendererList != null && rendererList.Length > 0)
            {
                for (int i = 0; i < rendererList.Length; i++)
                {
                    Renderer renderer = rendererList[i];
                    if (renderer != null)
                    {
                        renderer.shadowCastingMode = mode;
                    }
                }
            }

            MeshRenderer[] meshRendererList = obj.GetComponentsInChildren<MeshRenderer>(true);
            if (meshRendererList != null && meshRendererList.Length > 0)
            {
                for (int j = 0; j < meshRendererList.Length; j++)
                {
                    MeshRenderer meshRenderer = meshRendererList[j];
                    if (meshRenderer != null)
                    {
                        meshRenderer.shadowCastingMode = mode;
                    }
                }
            }

            SkinnedMeshRenderer[] skinnedMeshRendererList = obj.GetComponentsInChildren<SkinnedMeshRenderer>(true);
            if (skinnedMeshRendererList != null && skinnedMeshRendererList.Length > 0)
            {
                for (int k = 0; k < skinnedMeshRendererList.Length; k++)
                {
                    SkinnedMeshRenderer skinnedMeshRenderer = skinnedMeshRendererList[k];
                    if (skinnedMeshRenderer != null)
                    {
                        skinnedMeshRenderer.shadowCastingMode = mode;
                    }
                }
            }
            AssetDatabase.Refresh();
        }

    }
}
