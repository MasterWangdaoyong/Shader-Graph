
using System;
using System.Collections.Generic;
using System.IO;
using DodGame;
using UnityEditor;
using UnityEngine;
using YouMe;

namespace XGame
{
    class EffectBenchmarkWindow : EditorWindow
    {

        //定义技能编辑器scene
        private static readonly string m_editorScene = "Assets/Scenes/SceneEffect.unity";
        private bool m_nextFrameRun = false;
        private EffectBenchParam m_testParam = new EffectBenchParam();
        Vector2 m_scrollPos = new Vector2(0, 0);

        private int m_lastViewIndex = -1;

        private Texture2D MakeTex(int width, int height, Color col)
        {
            Color[] pix = new Color[width * height];
            for (int i = 0; i < pix.Length; ++i)
            {
                pix[i] = col;
            }
            Texture2D result = new Texture2D(width, height);
            result.SetPixels(pix);
            result.Apply();
            return result;
        }

        
        [MenuItem("Window/Effect Benchmark")]
        static void OpenEditorWindow()
        {
            BLogger.SetLogHandler(new EditorLogHandler());
            BLogger.SetLevel((uint)BLogLevel.ALL);

            var window = GetWindow(typeof(EffectBenchmarkWindow), false, "特效性能测试");
            window.minSize = new Vector2(455, 300);
        }

        private bool CheckScene()
        {
            bool needPrepare = false;
            if (!m_editorScene.Equals(EditorApplication.currentScene))
            {
                EditorApplication.OpenScene(m_editorScene);
                needPrepare = true;
            }

            if (!EditorApplication.isPlaying)
            {
                EditorApplication.isPlaying = true;
                needPrepare = true;
            }

            return needPrepare;
        }

        private EffectBenchmarkRunner GetRunner()
        {
            if (!EditorApplication.isPlaying)
            {
                return null;
            }

            string previewGoName = "EffectBenchmarkRunner";
            GameObject go = GameObject.Find("/" + previewGoName);
            EffectBenchmarkRunner runner = null;
            if (go == null)
            {
                go = new GameObject(previewGoName);
                go.transform.position = Vector3.zero;

                runner = XGoUtil.AddMonoBehaviour<EffectBenchmarkRunner>(go);
            }
            else
            {
                runner = go.GetComponent<EffectBenchmarkRunner>();
            }

            return runner;
        }

        private List<GameObject> GetBenchEffectList()
        {
            var listObj = Selection.GetFiltered(typeof(GameObject), SelectionMode.Assets);
            if (listObj != null)
            {
                var result = new List<GameObject>();
                foreach (var obj in listObj)
                {
                    var go = obj as GameObject;
                    if (go != null)
                    {
                        string assetPath = AssetDatabase.GetAssetPath(go);
                        if (!string.IsNullOrEmpty(assetPath))
                        {
                            result.Add(go);
                        }
                    }
                }

                return result.Count > 0 ? result : null;
            }

            return null;
        }

        public void OnInspectorUpdate()
        {
            Repaint();
        }

        public void OnGUI()
        {
            var runner = GetRunner();

            EditorGUILayout.BeginVertical();

            m_testParam.m_lodLevel = (LodLevel)EditorGUILayout.EnumPopup(m_testParam.m_lodLevel);
            m_testParam.m_testCount = EditorGUILayout.IntField("测试次数", m_testParam.m_testCount);
            m_testParam.m_testTime = EditorGUILayout.FloatField("测试时长", m_testParam.m_testTime);
            m_testParam.m_viewDist = EditorGUILayout.FloatField("相机距离", m_testParam.m_viewDist);
            
            if (runner != null && runner.IsRunning)
            {
                if (GUILayout.Button("取消测试"))
                {
                    runner.StopRun();
                }

                var lastEffect = runner.LastBenchEffect;

                float progress = 0;
                string text;
                if (lastEffect != null && runner.EffectTotalCount > 0)
                {
                    text = string.Format("当前测试进度{0}/{1}, testing {2}",
                        runner.EffectCurrCount, runner.EffectTotalCount, lastEffect.m_currTestCount);

                    progress = (float)runner.EffectCurrCount/(float) runner.EffectTotalCount;
                }
                else
                {
                    text = string.Format("当前测试进度{0}/{1}",
                        runner.EffectCurrCount, runner.EffectTotalCount);
                    progress = 1;
                }

                Rect trackContentRect = GUILayoutUtility.GetLastRect();
                trackContentRect.position = trackContentRect.position + new Vector2(0, trackContentRect.height + 10);
                trackContentRect.width = this.position.width;

                EditorGUI.ProgressBar(trackContentRect, progress, text);
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();
                EditorGUILayout.Space();

            }
            else
            {
                if (runner != null && m_nextFrameRun)
                {
                    GUILayout.Label("准备测试中..");

                    m_nextFrameRun = false;
                    var effectList = GetBenchEffectList();
                    if (effectList != null)
                    {
                        runner.StartBenchmark(effectList, m_testParam);
                    }
                }
                else
                {
                    if (GUILayout.Button("测试选中的特效"))
                    {
                        m_lastViewIndex = -1;
                        CheckScene();
                        m_nextFrameRun = true;
                    }
                }
            }

            var allResult = runner != null ? runner.AllResult : null;
            if (allResult != null)
            {
                m_scrollPos = GUILayout.BeginScrollView(m_scrollPos);
                for (int i = 0; i < allResult.Count; i++)
                {
                    var result = allResult[i];
                    EditorGUILayout.BeginHorizontal();
                    string fileName = Path.GetFileNameWithoutExtension(result.m_prefabPath);
                    EditorGUILayout.ObjectField(result.m_prefab, typeof(GameObject), false);
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    string val = string.Format("max drawcall:{0}, frame:{1}, time:{2}",
                        result.m_maxDrawCall,
                        result.m_maxDrawCallFrameCount, result.m_maxDrawCallTime);
                    GUILayout.Label(val);
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    val = string.Format("max verts:{0}, max tris:{1}", result.m_maxVerts, result.m_maxTris);
                    GUILayout.Label(val);
                    EditorGUILayout.EndHorizontal();

                    EditorGUILayout.BeginHorizontal();
                    val = string.Format("max particle count:{0}", result.m_maxParticleCnt);
                    GUILayout.Label(val);
                    EditorGUILayout.EndHorizontal();

                    if (runner.CurrViewing == i)
                    {
                        bool needView = false;
                        var color = GUI.color;
                        if (m_lastViewIndex == i)
                        {
                            GUI.color = Color.green;
                        }
                        needView = GUILayout.Button("Cancel");
                        GUI.color = color;

                        if (needView)
                        {
                            runner.CancelViewEffect(i);
                        }
                    }
                    else
                    {
                        bool needView = false;
                        var color = GUI.color;
                        if (m_lastViewIndex == i)
                        {
                            GUI.color = Color.green;
                        }
                        needView = GUILayout.Button("View");
                        GUI.color = color;

                        if (needView)
                        {
                            runner.ViewEffect(i, m_testParam);
                            m_lastViewIndex = i;
                        }
                    }

                    EditorGUILayout.Space();
                }

                GUILayout.EndScrollView();
            }

            EditorGUILayout.EndVertical();
        }
    }
}
