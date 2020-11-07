using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;
#endif

using UnityEngine;
using System.Collections;
using DodGame;

public class EffectBenchParam
{
    public LodLevel m_lodLevel = LodLevel.MediumLevel; //测试的lod
    public int m_testCount = 2; //测试次数
    public float m_testTime = 1.5f;  //每次测试的时
    public float m_viewDist = 10;
}

public class EffectBenchmarkResult
{
    public GameObject m_prefab;
    public string m_prefabPath;
    public int m_maxDrawCall = 0;
    public int m_minDrawCall = 0;
    public int m_maxDrawCallFrameCount = 0;
    public float m_maxDrawCallTime = 0f;
    public int m_maxVerts = 0;
    public int m_maxTris = 0;
    public int m_maxParticleCnt = 0;


    public int m_drawCallTotal = 0;
    public int m_drawCallFrameCount = 0;

    ///测试进度
    public int m_currTestCount = 0;

    public void Reset()
    {
        m_maxDrawCall = 0;
        m_minDrawCall = 0;
        m_maxDrawCallFrameCount = 0;
        m_maxDrawCallTime = 0;
        m_maxVerts = 0;
        m_maxTris = 0;
        m_maxParticleCnt = 0;
        m_drawCallTotal = 0;
        m_drawCallFrameCount = 0;
        m_currTestCount = 0;
    }
}

public class EffectBenchmarkRunner : MonoBehaviour
{
    public Camera m_camera;
    public Transform m_effectNode;

    private List<EffectBenchmarkResult> m_listResult = new List<EffectBenchmarkResult>();
    private bool m_isRunning = false;
    private float m_currProgress = 0f;
    private int m_effectCount = 0;

    private bool m_needStop = false;
    private bool m_waitStart = false;

    public bool IsRunning
    {
        get { return m_isRunning; }
    }

    private int m_isViewing = -1;

    public int CurrViewing
    {
        get { return m_isViewing; }
    }
    
    public float CurrProcess
    {
        get
        {
            return m_currProgress;
        }
    }

    public int EffectTotalCount
    {
        get { return m_effectCount; }
    }

    public int EffectCurrCount
    {
        get { return m_listResult.Count; }
    }

    public EffectBenchmarkResult LastBenchEffect
    {
        get
        {
            if (m_listResult != null && m_listResult.Count > 0)
            {
                return m_listResult[m_listResult.Count - 1];
            }
            return null;
        }
    }

    public List<EffectBenchmarkResult> AllResult
    {
        get { return m_listResult; }
    } 


    public void StartBenchmark(List<GameObject> listEffect, EffectBenchParam testParam)
    {
        if (m_waitStart || m_isViewing >= 0)
        {
            return;
        }

        m_needStop = false;
        m_waitStart = true;

        //LodDebugMgr.Instance.m_lodLevel = testParam.m_lodLevel;
        UnityLodMgr.Instance.LodLevel = (UnityLodLevel)testParam.m_lodLevel;
        StartCoroutine(RunBenchmark(listEffect, testParam));
    }

    public void ViewEffect(int index, EffectBenchParam testParam)
    {
        if (IsRunning || m_isViewing >= 0)
        {
            return;
        }

        m_needStop = false;
        if (index >= 0 && index < m_listResult.Count)
        {
            m_isViewing = index;
            StartCoroutine(TestOneEffect(m_listResult[index], testParam));
        }
    }

    public void CancelViewEffect(int index)
    {
        m_needStop = true;
    }
    
    public void StopRun()
    {
        m_needStop = true;
    }

    IEnumerator RunBenchmark(List<GameObject> listEffect, EffectBenchParam testParam)
    {
        yield return null;

        m_waitStart = false;
        m_currProgress = 0f;
        m_isRunning = true;

        m_effectCount = listEffect.Count;
        m_listResult.Clear();
        for (int i = 0; i < listEffect.Count && !m_needStop; i++)
        {
            var newResult = new EffectBenchmarkResult();
            newResult.m_prefab = listEffect[i];

#if UNITY_EDITOR
            newResult.m_prefabPath = AssetDatabase.GetAssetPath(newResult.m_prefab);
#endif

            m_listResult.Add(newResult);

            
            yield return StartCoroutine(TestOneEffect(newResult, testParam));
            m_currProgress = i/(float) listEffect.Count;
        }

        ///结束，循环打印结果
        for (int i = 0; i < m_listResult.Count; i++)
        {
            var result = m_listResult[i];

            Debug.LogError(string.Format("[{0}] {1}", i, result.m_prefabPath), result.m_prefab);

            ///打印结果
            Debug.LogError(string.Format("max drawcall:{0}(frame:{1}, time:{2}), max verts:{3}, max tris:{4}", result.m_maxDrawCall,
                result.m_maxDrawCallFrameCount, result.m_maxDrawCallTime, result.m_maxVerts, result.m_maxTris), result.m_prefab);

        }

        m_isRunning = false;
        m_currProgress = 1;
    }

    int GetCurrParticleCount(GameObject goEffect)
    {
        int maxPartCnt = 0;
        var allParticle = goEffect.GetComponentsInChildren<ParticleSystem>();
        if (allParticle != null)
        {
            for (int i = 0; i < allParticle.Length; i++)
            {
                var part = allParticle[i];
                maxPartCnt += part.particleCount;
            }
        }

        return maxPartCnt;
    }

    IEnumerator TestOneEffect(EffectBenchmarkResult result, EffectBenchParam testParam)
    {
        yield return null;
        var go = Instantiate(result.m_prefab) as GameObject;
        if (go == null)
        {
            yield break;
        }

        go.transform.parent = m_effectNode.transform;
        go.transform.localPosition = Vector3.zero;
        go.transform.localRotation = Quaternion.Euler(30, 0, 0);
        go.transform.localPosition = new Vector3(0, 0, testParam.m_viewDist);
        go.SetActive(false);
        
        yield return null;
        yield return null;

        result.Reset();

#if UNITY_EDITOR
        ///开始统计
        for (result.m_currTestCount = 0; result.m_currTestCount < testParam.m_testCount && !m_needStop; result.m_currTestCount++)
        {
            go.SetActive(true);
            yield return null;

            var tick = new BTickWatcher();
            while (tick.ElapseTime() < testParam.m_testTime && !m_needStop)
            {
                var currDrawCall = UnityStats.drawCalls;
                var currVerts = UnityStats.vertices;
                var currTris = UnityStats.triangles;
                var currParticleCnt = GetCurrParticleCount(go);

                if (result.m_maxDrawCall < currDrawCall)
                {
                    result.m_maxDrawCall = currDrawCall;
                    result.m_maxDrawCallFrameCount = 0;
                }
                else if (result.m_maxDrawCall == currDrawCall)
                {
                    result.m_maxDrawCallFrameCount++;
                    result.m_maxDrawCallTime += Time.deltaTime;
                }

                if (result.m_maxVerts < currVerts)
                {
                    result.m_maxVerts = currVerts;
                }
                if (result.m_maxTris < currTris)
                {
                    result.m_maxTris = currTris;
                }
                if (result.m_minDrawCall <= 0 || result.m_minDrawCall > currDrawCall)
                {
                    result.m_minDrawCall = currDrawCall;
                }

                if (result.m_maxParticleCnt < currParticleCnt)
                {
                    result.m_maxParticleCnt = currParticleCnt;
                }

                ///用来计算平均值
                if (currDrawCall > 0)
                {
                    result.m_drawCallTotal += currDrawCall;
                    result.m_drawCallFrameCount++;
                }

                yield return null;
            }
        }
#endif

        DestroyImmediate(go);
        yield return null;
        m_isViewing = -1;
    }
}
