using UnityEngine;
using UnityEditor;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.Rendering;

//20190820 jianping
public static class SceneShadows_02
{
    [MenuItem("GameObject/SceneShadows/receiveShadows_on", false, 0)]
    static void SceneShadowsMode_On()
    {
        SceneShadowsMode(true);
    }

    [MenuItem("GameObject/SceneShadows/receiveShadows_off", false, 0)]
    static void SceneShadowsMode_Off()
    {
        SceneShadowsMode(false);
    }
       
    static void SceneShadowsMode(bool mode)
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
                        renderer.receiveShadows = mode;
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
                        meshRenderer.receiveShadows = mode;
                    }
                }
            }
            AssetDatabase.Refresh();
        }

    }
}
