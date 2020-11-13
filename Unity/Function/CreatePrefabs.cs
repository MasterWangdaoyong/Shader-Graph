using UnityEngine;
using UnityEditor;
using System.Collections;
using System.IO;


//批量生成prefabs JianpingWang 20190619
public class CreatePrefabs : EditorWindow

/// <summary>
/// CreatePrefabs类为批量创建Prefab的窗口类，选择Hierarchy窗口的物体，点击创建Prefab即可在指定目录生成Prefab
/// 如果所选物体含有动态创建的Mesh，必须先在指定目录先生成OBJ文件
/// </summary>

{
    [MenuItem("AssetsManager/批量生成Prefab")]

    static void AddWindow()
    {
        //创建窗口
        CreatePrefabs window = (CreatePrefabs)EditorWindow.GetWindow(typeof(CreatePrefabs), false, "批量生成Prefab");
        window.Show();

    }

    //输入文字的内容
    private string PrefabPath = "Assets/Resources/";
    private string ObjPath = @"Assets/Obj/";
    GameObject[] selectedGameObjects;



    [InitializeOnLoadMethod]
    public void Awake()
    {
        OnSelectionChange();
    }
    void OnGUI()
    {
        GUIStyle text_style = new GUIStyle();
        text_style.fontSize = 15;
        text_style.alignment = TextAnchor.MiddleCenter;

        EditorGUILayout.BeginHorizontal();
        GUILayout.Label("Prefab导出路径:");
        PrefabPath = EditorGUILayout.TextField(PrefabPath);
        if (GUILayout.Button("浏览"))
        { EditorApplication.delayCall += OpenPrefabFolder; }
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();

        GUILayout.Label("    Obj导出路径:");
        ObjPath = EditorGUILayout.TextField(ObjPath);
        if (GUILayout.Button("浏览"))
        { EditorApplication.delayCall += OpenObjFolder; }
        EditorGUILayout.EndHorizontal();

        GUILayout.Label("当前选中了" + selectedGameObjects.Length + "个物体", text_style);
        if (GUILayout.Button("如果包含动态创建的Mesh，请先点击生成Obj", GUILayout.MinHeight(20)))
        {
            foreach (GameObject m in selectedGameObjects)
            {
                CreateObj(m);
            }
            AssetDatabase.Refresh();
        }
        if (GUILayout.Button("生成当前选中物体的Prefab", GUILayout.MinHeight(20)))
        {
            if (selectedGameObjects.Length <= 0)
            {
                //打开一个通知栏  
                this.ShowNotification(new GUIContent("未选择所要导出的物体"));
                return;
            }
            if (!Directory.Exists(PrefabPath))
            {
                Directory.CreateDirectory(PrefabPath);
            }
            foreach (GameObject m in selectedGameObjects)
            {
                CreatePrefab(m, m.name);
            }
            AssetDatabase.Refresh();
        }
    }

    void OpenPrefabFolder()
    {
        string path = EditorUtility.OpenFolderPanel("选择要导出的路径", "", "");
        if (!path.Contains(Application.dataPath))
        {
            Debug.LogError("导出路径应在当前工程目录下");
            return;
        }
        if (path.Length != 0)
        {
            int firstindex = path.IndexOf("Assets");
            PrefabPath = path.Substring(firstindex) + "/";
            EditorUtility.FocusProjectWindow();
        }
    }

    void OpenObjFolder()
    {
        string path = EditorUtility.OpenFolderPanel("选择要导出的路径", "", "");
        if (!path.Contains(Application.dataPath))
        {
            Debug.LogError("导出路径应在当前工程目录下");
            return;
        }
        if (path.Length != 0)
        {
            int firstindex = path.IndexOf("Assets");
            ObjPath = path.Substring(firstindex) + "/";
            EditorUtility.FocusProjectWindow();
        }
    }

    void CreateObj(GameObject go)
    {
        if (!Directory.Exists(ObjPath))
        {
            Directory.CreateDirectory(ObjPath);
        }
        MeshFilter[] meshfilters = go.GetComponentsInChildren<MeshFilter>();
        if (meshfilters.Length > 0)
        {
            for (int i = 0; i < meshfilters.Length; i++)
            {
                ObjExporter.MeshToFile(meshfilters[i], ObjPath + meshfilters[i].gameObject.name + ".obj");

            }
        }
    }
    /// <summary>
    /// 此函数用来根据某物体创建指定名字的Prefab
    /// </summary>
    /// <param name="go">选定的某物体</param>
    /// <param name="name">物体名</param>
    /// <returns>void</returns>
    void CreatePrefab(GameObject go, string name)
    {
        //先创建一个空的预制物体
        //预制物体保存在工程中路径，可以修改("Assets/" + name + ".prefab");
        GameObject tempPrefab = PrefabUtility.CreatePrefab(PrefabPath + name + ".prefab", go);

        MeshFilter[] meshfilters = go.GetComponentsInChildren<MeshFilter>();
        if (meshfilters.Length > 0)
        {
            MeshFilter[] prefabmeshfilters = tempPrefab.GetComponentsInChildren<MeshFilter>();
            for (int i = 0; i < meshfilters.Length; i++)
            {
                Mesh m_mesh = AssetDatabase.LoadAssetAtPath<Mesh>(ObjPath + meshfilters[i].gameObject.name + ".obj");
                prefabmeshfilters[i].sharedMesh = m_mesh;
            }
        }
        //返回创建后的预制物体
    }

    void OnInspectorUpdate()
    {
        //这里开启窗口的重绘，不然窗口信息不会刷新
        this.Repaint();
    }

    void OnSelectionChange()
    {
        //当窗口出去开启状态，并且在Hierarchy视图中选择某游戏对象时调用
        selectedGameObjects = Selection.gameObjects;

    }
}

