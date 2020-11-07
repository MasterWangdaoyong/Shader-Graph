using UnityEngine;
using UnityEditor;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEditor.SceneManagement;

///* 20201013 
///* JianpingWang
///* 去除所有Script
public static class RemoveSceneScript
{
    [MenuItem("GameObject/RemoveSceneScript", false, 0)]
    static void SceneScript_On()
    {
        SceneScript(true);
    }
       
    static void SceneScript(bool mode)
    {
        GameObject obj = Selection.activeObject as GameObject;
        if (obj != null)
        {
            var behaviours = obj.GetComponentsInChildren<MonoBehaviour>();
            // 脚本的获取。 script类型为MonoBehaviour
            for (int i = 0; i < behaviours.Length; i++)
            {
                var behaviour = behaviours[i];
                //变量声明 与赋值
                GameObject.DestroyImmediate(behaviour);
                // 去除。 GameObject.DestroyImmediate(Object obj, bool allowDestroyingAssets = false)
            }

    //  ScriptableObject[] objList = obj.GetComponentsInChildren<ScriptableObject>(true);
    //         if (objList != null && objList.Length > 0)
    //         {
    //             for (int i = 0; i < objList.Length; i++)
    //             {
    //                 if (objList[i] != null)
    //                 {                        
    //                     // objList[i].OnDestroy;
    //                     // Debug.Log(objList[i]);
    //                 }
    //             }
    //         }

            AssetDatabase.Refresh();
        }

    }

}
