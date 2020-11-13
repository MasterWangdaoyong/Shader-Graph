
//控制时间传达实时数据控制材质球表现2
using System;
using System.Collections;

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

/// <summary> shader 属性类型 </summary>
public enum EShaderPropertyType
{
    Range = 0,
    Float,
    //贴图Tiling/Offset   
    TexEnv,
    Color,
}

/// <summary> Mat 属性类型 </summary>
public struct MatInfo
{
    public Renderer render;

    public Material mat;
    public Material shaderMat;
    public string matPath;
    public MatInfo(Renderer render, Material mat, Material shaderMat, string matPath)
    {
        this.render = render;
        this.mat = mat;
        this.shaderMat = shaderMat;
        this.matPath = matPath;
    }
};


public class Material_Animation : MonoBehaviour
{
    public float times = 2;
    public bool loop = true;
    public float delayTime;


    public AnimationCurve curve = new AnimationCurve(new Keyframe(0, 0), new Keyframe(1, 1));
    public bool useCurveMove = false;
    /// <summary>
    /// 是否为播放状态
    /// </summary>
    public bool _isPlay = false;

    /// <summary>
    /// Shader应用属性
    /// </summary>
    public EShaderPropertyType eShaderPropertyType = EShaderPropertyType.Float;
    [HideInInspector]
    public int eShaderPropertyTypeIndex;
    //public Gradient colorGradient;
    [HideInInspector]
    public Dictionary<string, List<string>> shaderPropertys = new Dictionary<string, List<string>>();

    [SerializeField]
    public List<CurveAnimColorShaderPro> colorGradients = new List<CurveAnimColorShaderPro>();
    public Renderer selfRender;
    public Material mat;
    public Material idelMat;
    //-------------------------------------------------------------------------------
    [HideInInspector]
    public List<CurveAnimRangeShaderPro> rangeLists = new List<CurveAnimRangeShaderPro>();

    //-------------------------------------------------------------------------------
    [HideInInspector]
    public List<CurveAnimFloatShaderPro> floatList = new List<CurveAnimFloatShaderPro>();

    //-------------------------------------------------------------------------------
    [HideInInspector]
    public List<CurveAnimTexSTShaderPro> textureSTList = new List<CurveAnimTexSTShaderPro>();

    //-------------------------------------------------------------------------------
    [HideInInspector]
    public Renderer[] childRenderers;
    [HideInInspector]
    public List<MatInfo> childShaderMatInfos = new List<MatInfo>();
    private bool isDebug;
    private bool _currentObjeActive;
    void Awake()
    {
        StartGetIdleData();
        _currentObjeActive = this.gameObject.activeInHierarchy;
    }
    void Start()
    {
        StartCoroutine(DelayOne());
        DelayTimeRun();
    }
    /// <summary>
    /// Play模式下默认延迟一帧应用曲线
    /// </summary>
    /// <returns></returns>
    IEnumerator DelayOne()
    {
        yield return null;
        Debug.Log("<color=red>" + "延迟一帧结束---" + "</color>");
    }
    //延迟执行
    public void DelayTimeRun()
    {
        Invoke("StartCurveInit", delayTime);
    }
    //初始化数据
    private void StartCurveInit()
    {
        SetUseCurve(true);
        //数据需要放在Awake先加载
        //StartGetIdleData();
    }
    private float _tempTime;
    public void SetUseCurve(bool state)
    {
        useCurveMove = state;
        _tempTime = 0;
    }

    void Update()
    {
        if (!useCurveMove) return;
        ShaderPropertyChange(mat, Time.deltaTime);
    }

    void OnEnable()
    {
        if (Application.isPlaying)
        {
            StartCoroutine(DelayOne());
            DelayTimeRun();
            SetUseCurve(true);
        }
    }

    void OnDisable()
    {
        if (Application.isPlaying)
        {
            SetUseCurve(false);
            ResetIdleState(idelMat, selfRender.sharedMaterial);
            ResetAllChild();
        }
    }
    //===================================================================================================================================================================================
    //===================================================================================================================================================================================

    /// <summary>
    /// 重置初始状态--主要应用在编辑器模式下
    /// </summary>
    public void ResetIdleState(Material tartget, Material self)
    {
        //To do
        CopyMat(tartget, self);
    }


    /// <summary>
    /// 拷贝材质数据--主要做恢复默认数据
    /// </summary>
    /// <param name="targerMat"></param>
    /// <param name="selfMat"></param>
    public void CopyMat(Material targerMat, Material selfMat)
    {
        if (targerMat == null)
        {
            Debug.Log("<color=red>" + "目标材质不存在" + "</color>");
            return;
        }
        selfMat.CopyPropertiesFromMaterial(targerMat);
        Debug.Log(targerMat.name + "<color=blue>数据拷贝到</color>" + selfMat.name);
    }

    /// <summary>
    /// 缓存默认数据
    /// </summary>
    public void StartGetIdleData()
    {
        //会把自身也获取到-索引从1开始
        childRenderers = transform.GetComponentsInChildren<Renderer>();
        if (childRenderers == null) return;
        selfRender = childRenderers[0];
        if (selfRender)
        {
            mat = selfRender.sharedMaterial;
            if (mat != null)
            {
                idelMat = new Material(mat.shader);
                CopyMat(mat, idelMat);
            }
        }
        if (childRenderers.Length > 0)
        {
            for (int i = 0; i < childRenderers.Length; i++)
            {
                MatInfo matInfo = new MatInfo();

                if (childRenderers[i].sharedMaterial != null)
                {
                    matInfo.render = childRenderers[i];
                    matInfo.shaderMat = (childRenderers[i].sharedMaterial);

                    if (childRenderers[i].sharedMaterial != null)
                    {
                        // string shaderPath = childRenderers[i].sharedMaterial.name;
                        // Material idleMat = new Material(Shader.Find(shaderPath));
                        Material idleMat = Instantiate(matInfo.shaderMat);
                        idleMat.name = idelMat.name + "_IdleChild_";
                        matInfo.mat = idleMat;
#if UNITY_EDITOR
                        matInfo.matPath = UnityEditor.AssetDatabase.GetAssetPath(childRenderers[i].sharedMaterial);
#endif

                    }

                    if (!childShaderMatInfos.Contains(matInfo))
                        childShaderMatInfos.Add(matInfo);
                }
            }

        }
    }
    public void ResetAllChild()
    {
        if (childShaderMatInfos == null || childShaderMatInfos.Count <= 0) return;

        for (int i = 0; i < childShaderMatInfos.Count; i++)
        {
            ResetIdleState(childShaderMatInfos[i].mat, childShaderMatInfos[i].shaderMat);
            Debug.Log("子对象材质：" + childShaderMatInfos[i].mat.name + "==回复：" + childShaderMatInfos[i].shaderMat.name);
        }
    }

    public void StartGetIdleDataEditor()
    {
        //会把自身也获取到-索引从1开始
        childRenderers = transform.GetComponentsInChildren<Renderer>();
        if (childRenderers == null || childRenderers.Length <= 0) return;
        selfRender = childRenderers[0];
        if (selfRender)
        {
            mat = selfRender.sharedMaterial;
            if (mat != null)
            {
                idelMat = new Material(mat.shader);
                CopyMat(mat, idelMat);
            }
        }
        if (childRenderers.Length > 0)
        {
            for (int i = 0; i < childRenderers.Length; i++)
            {
                MatInfo matInfo = new MatInfo();

                if (childRenderers[i].sharedMaterial != null)
                {
                    matInfo.render = childRenderers[i];
                    matInfo.shaderMat = (childRenderers[i].sharedMaterial);

                    if (childRenderers[i].sharedMaterial != null)
                    {
                        Material idleMat = Instantiate(matInfo.shaderMat);
                        idleMat.name = idelMat.name + "_IdleChild_";
                        matInfo.mat = idleMat;

#if UNITY_EDITOR
                        matInfo.matPath = UnityEditor.AssetDatabase.GetAssetPath(childRenderers[i].sharedMaterial);
#endif
                    }

                    if (!childShaderMatInfos.Contains(matInfo))
                        childShaderMatInfos.Add(matInfo);
                }
            }

        }
    }

    private float _percentage;
    public float GetPercentage
    {
        get { return _percentage; }
    }
    /// <summary>
    /// 材质属性改变
    /// </summary>
    public void ShaderPropertyChange(Material mat, float deltaTime)
    {
        //  Debug.Log("GameName=" +this.gameObject.name + "Mat=" +mat);
        switch (eShaderPropertyType)
        {
            case EShaderPropertyType.Range:
                ShaderPropertyChange(mat, SetRangeProperty, deltaTime);
                break;
            case EShaderPropertyType.Float:
                ShaderPropertyChange(mat, SetFloatProperty, deltaTime);
                break;
            case EShaderPropertyType.TexEnv:
                ShaderPropertyChange(mat, SetTexSTProperty, deltaTime);
                break;
            case EShaderPropertyType.Color:
                ShaderPropertyChange(mat, SetColorProperty, deltaTime);
                break;
            default:
                break;
        }
    }
    private delegate void CacheShederPropertyFunction(Material mat, string propertyName);
    private delegate void SerShaderPropertyFunction(Material mat, float percentage);

    /// <summary>
    /// 修改材质属性
    /// </summary>
    /// <param name="mat"></param>
    /// <param name="serShaderPropertyFunction"></param>
    private void ShaderPropertyChange(Material mat, SerShaderPropertyFunction serShaderPropertyFunction, float deltaTime)
    {
        if (mat == null)
        {
            Debug.Log("<color=red>当前没有材质球</color>");
            useCurveMove = false;
            _tempTime = 0;
            return;
        }
        if (_tempTime < times)
        {
            _tempTime += deltaTime;
            _percentage = _tempTime / times;
            serShaderPropertyFunction(mat, _percentage);
        }
        else
        {
            if (loop)
            {
                //To do
            }
            else
            {
                useCurveMove = false;
            }
            _tempTime = 0;
        }
    }

    //-----------------------------------------------------------------------------------------------------------------
    #region ----\\ Shader ==> Color 属性修改 //----

    public void SetColorProperty(Material mat, float percentage)
    {
        if (colorGradients.Count > 0)
        {
            for (int i = 0; i < colorGradients.Count; i++)
            {
                mat.SetColor(colorGradients[i].propertyName, colorGradients[i].colorGradient.Evaluate(percentage));

                //应用子对象
                if (colorGradients[i].applyChild && childShaderMatInfos.Count > 1)
                {
                    for (int j = 1; j < childShaderMatInfos.Count; j++)
                    {
                        childShaderMatInfos[j].shaderMat.SetColor(colorGradients[i].propertyName, colorGradients[i].colorGradient.Evaluate(percentage));
                    }
                }
            }
        }
    }

    #endregion

    //-----------------------------------------------------------------------------------------------------------------
    #region ----\\ Shader ==> Range 属性修改 //----

    public void SetRangeProperty(Material mat, float percentage)
    {
        if (rangeLists.Count > 0)
        {
            for (int i = 0; i < rangeLists.Count; i++)
            {
                if (rangeLists[i].useSelfAnimCurve)
                {
                    if (rangeLists[i].animCurve.keys.Length > 0)
                        rangeLists[i].rangeResult = rangeLists[i].rangeInputMin + rangeLists[i].animCurve.Evaluate(percentage) * Mathf.Abs(rangeLists[i].rangeInputMax - rangeLists[i].rangeInputMin);
                }
                else
                {
                    if (curve.keys.Length > 0)
                        rangeLists[i].rangeResult = rangeLists[i].rangeInputMin + curve.Evaluate(percentage) * Mathf.Abs(rangeLists[i].rangeInputMax - rangeLists[i].rangeInputMin);
                }
                mat.SetFloat(rangeLists[i].propertyName, rangeLists[i].rangeResult);

                //应用子对象
                if (rangeLists[i].applyChild && childShaderMatInfos.Count > 1)
                {
                    for (int j = 1; j < childShaderMatInfos.Count; j++)
                    {
                        childShaderMatInfos[j].shaderMat.SetFloat(rangeLists[i].propertyName, rangeLists[i].rangeResult);
                    }
                }
            }
        }
    }
    #endregion

    //-----------------------------------------------------------------------------------------------------------------
    #region ----\\ Shader ==> Float 属性修改 //----

    public void SetFloatProperty(Material mat, float percentage)
    {
        if (floatList.Count > 0)
        {
            for (int i = 0; i < floatList.Count; i++)
            {
                if (floatList[i].useSelfAnimCurve)
                {
                    floatList[i].floatResult = floatList[i].animCurve.Evaluate(percentage) * floatList[i].scaleCurve;
                }
                else
                {
                    floatList[i].floatResult = curve.Evaluate(percentage) * floatList[i].scaleCurve;
                }

                mat.SetFloat(floatList[i].propertyName, floatList[i].floatResult);
                //应用子对象
                if (floatList[i].applyChild && childShaderMatInfos.Count > 1)
                {
                    for (int j = 1; j < childShaderMatInfos.Count; j++)
                    {
                        childShaderMatInfos[j].shaderMat.SetFloat(floatList[i].propertyName, floatList[i].floatResult);
                    }
                }

            }
        }
    }
    #endregion

    //-----------------------------------------------------------------------------------------------------------------
    #region ----\\ Shader ==> TextureST 属性修改 //---
    private const string tiling = "Tiling";
    private const string offset = "Offset";
    private const string x = "X";
    private const string y = "Y";

    private Vector2 _tempST = Vector2.zero;
    private void SetTexSTProperty(Material mat, float percentage)
    {
        if (textureSTList.Count > 0)
        {
            for (int i = 0; i < textureSTList.Count; i++)
            {
                //使用自身独立曲线还是公用曲线
                if (textureSTList[i].useSelfAnimCurve)
                {
                    if (textureSTList[i].animCurve != null)
                        textureSTList[i].floatResult = textureSTList[i].animCurve.Evaluate(percentage) * textureSTList[i].scaleCurve;
                }
                else
                {
                    textureSTList[i].floatResult = curve.Evaluate(percentage) * textureSTList[i].scaleCurve;
                }

                SetShedrtTexST(mat, textureSTList[i].targetPropertyName, textureSTList[i].specificStr, textureSTList[i].axisName, textureSTList[i].floatResult);

                if (textureSTList[i].applyChild && childShaderMatInfos.Count > 1)
                {
                    for (int j = 1; j < childShaderMatInfos.Count; j++)
                    {
                        SetShedrtTexST(childShaderMatInfos[j].shaderMat, textureSTList[i].targetPropertyName, textureSTList[i].specificStr, textureSTList[i].axisName, textureSTList[i].floatResult);
                    }
                }
            }
        }
    }
    public void SetShedrtTexST(Material mat, string propertyName, string specificStr, string axis, float value)
    {
        if (string.Equals(specificStr, tiling))
        {
            _tempST = mat.GetTextureScale(propertyName);
            if (axis == x)
            {
                mat.SetTextureScale(propertyName, new Vector2(value, _tempST.y));
            }
            else if (axis == y)
            {
                mat.SetTextureScale(propertyName, new Vector2(_tempST.x, value));
            }
        }
        else if (string.Equals(specificStr, offset))
        {
            _tempST = mat.GetTextureOffset(propertyName);

            if (axis == x)
            {
                mat.SetTextureOffset(propertyName, new Vector2(value, _tempST.y));
            }
            else if (axis == y)
            {
                mat.SetTextureOffset(propertyName, new Vector2(_tempST.x, value));
            }
        }
    }
    #endregion

    /// <summary>
    /// 获取指定键对应的list<string>
    /// </summary>
    /// <param name="dicKey"></param>
    /// <returns>返回list 对应的数组</returns>
    public string[] GetDicList(string dicKey)
    {
        string[] result = new string[] { };

        if (shaderPropertys != null && shaderPropertys.ContainsKey(dicKey))
        {
            result = shaderPropertys[dicKey].ToArray();
        }
        return result;
    }

    /// <summary>
    /// 获取指定键对应的List Count
    /// </summary>
    /// <param name="dicKey"></param>
    /// <returns></returns>
    public int GetDicListCount(string dicKey)
    {
        int result = 0;
        if (shaderPropertys != null && shaderPropertys.ContainsKey(dicKey))
        {
            result = shaderPropertys[dicKey].Count;
        }
        return result;
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(Material_Animation))]
public class Material_AnimationEditor : BaseEditor
{

    private Material_Animation _target;
    private double _previousTime;
    private string _prefabPath = "Assets/E3D-TranformTools/Prefabs/";

    private SerializedProperty customColorGradients;
    private string[] shaderCtrStr = new string[] { "滑动条", "浮点值", "纹理UV", "颜色" };
    GUIContent delete = new GUIContent("删除");
    Color idleBackColor;
    private const float deletBtnWidth = 100;
    private const float curveHeight = 60;
    private const float curveWidth = 160;
    Shader tempShader;
    Renderer renderer;
    void OnEnable()
    {
        base.OnEnable();
        _target = (Material_Animation)target;
        if (Application.isEditor && Application.isPlaying == false)
        {
            _target.SetUseCurve(false);
            _target.StartGetIdleDataEditor();
        }


        renderer = _target.GetComponent<Renderer>();
        if (renderer == null)
        {
            Debug.Log("<color=red>" + "当前对象没有render组件-" + "</color>");
            return;
        }
        if (renderer.sharedMaterial)
            tempShader = renderer.sharedMaterial.shader;
        string shaderPath = tempShader.name;
        Debug.Log("shaderPath = " + shaderPath);
        _target.idelMat = new Material(Shader.Find(shaderPath));
        _target.idelMat.name = _target.idelMat.name + "_Idle";

        Debug.Log(_target.idelMat.name);
        if (tempShader)
        {
            _target.CopyMat(renderer.sharedMaterial, _target.idelMat);
            _target.shaderPropertys.Clear();
            DicAdd(ShaderUtil.ShaderPropertyType.Color);
            DicAdd(ShaderUtil.ShaderPropertyType.Float);
            DicAdd(ShaderUtil.ShaderPropertyType.Range);
            DicAdd(ShaderUtil.ShaderPropertyType.TexEnv);
        }
        else
        {
            Debug.Log("<color=red>" + "当前对象不存在材质信息！！" + "</color>");
            return;
        }

        idleBackColor = GUI.backgroundColor;
        _previousTime = EditorApplication.timeSinceStartup;
        EditorApplication.update += InspectorUpdate;
    }

    void OnDisable()
    {
        EditorApplication.update -= InspectorUpdate;
        if (!Application.isPlaying && _target.useCurveMove)
        {
            if (_target && renderer != null)
                _target.ResetIdleState(_target.idelMat, renderer.sharedMaterial);
        }

        //对象停止播放时恢复默认
        if (_target && _target.useCurveMove == false)
        {
            if (_target && renderer != null)
                _target.ResetIdleState(_target.idelMat, renderer.sharedMaterial);
        }
    }

    //更新时间。
    private void InspectorUpdate()
    {
        //编辑器下Time的增量需要使用EditorApplication.timeSinceStartup 前后的差值
        var deltaTime = EditorApplication.timeSinceStartup - _previousTime;
        _previousTime = EditorApplication.timeSinceStartup;

        if (!Application.isPlaying && _target.useCurveMove)
        {
            _target.ShaderPropertyChange(renderer.sharedMaterial, (float)deltaTime);
            SceneView.RepaintAll();
            Repaint();
        }
    }
    public override void OnInspectorGUI()
    {
        this.DrawMonoScript();
        serializedObject.Update();
        customColorGradients = serializedObject.FindProperty("colorGradients");
        EditorGUILayout.BeginVertical(GUI.skin.box);

        _target.times = EditorGUILayout.FloatField("Times：", _target.times);
        _target.loop = EditorGUILayout.Toggle("Loop：", _target.loop);
        _target.delayTime = EditorGUILayout.FloatField("Delay：", _target.delayTime);

        EditorGUILayout.LabelField("Curve：");
        _target.curve = EditorGUILayout.CurveField("", _target.curve, GUILayout.Height(60), GUILayout.MinWidth(100));

        VFXCtrType_Mat();

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Play", GUILayout.MinWidth(100)))
        {
            _target._isPlay = true;
            //To Do
            TargetReset();
            _target.DelayTimeRun();
        }
        if (GUILayout.Button("Reset", GUILayout.MinWidth(100)))
        {
            _target._isPlay = false;
            //To Do
            TargetReset();
        }

        EditorGUILayout.EndHorizontal();
        EditorGUILayout.BeginHorizontal();
        EditorGUI.BeginDisabledGroup(_target._isPlay);
        if (GUILayout.Button("IC", GUILayout.MinWidth(100)))
        {
            _target.ResetIdleState(_target.idelMat, renderer.sharedMaterial);
            _target.ResetAllChild();
        }
        EditorGUI.EndDisabledGroup();

        if (GUILayout.Button("Help", GUILayout.MinWidth(100)))
        {
            Application.OpenURL("www.xxx.com");
        }
        EditorGUILayout.EndHorizontal();
        EditorGUILayout.EndVertical();

        EditorGUILayout.HelpBox("使用注意！\n 1:材质属性控制", MessageType.Warning);
        serializedObject.ApplyModifiedProperties();

        EditorUtility.SetDirty(_target);
    }

    private void TargetReset()
    {
        if (_target)
        {
            _target.SetUseCurve(false);
            Debug.Log("idle=" + _target.idelMat.name + "== CurrentMat=" + renderer.sharedMaterial.name);
            _target.ResetIdleState(_target.idelMat, renderer.sharedMaterial);
            _target.ResetAllChild();
        }
    }
    /// <summary>
    /// 材质类型
    /// </summary>
    private void VFXCtrType_Mat()
    {
        EditorGUILayout.BeginVertical();
        _target.eShaderPropertyTypeIndex = EditorGUILayout.Popup("MatCtrlType:", _target.eShaderPropertyTypeIndex, shaderCtrStr);
        _target.eShaderPropertyType = (EShaderPropertyType)_target.eShaderPropertyTypeIndex;

        switch (_target.eShaderPropertyType)
        {
            case EShaderPropertyType.Range:
                ShaderPropertyEditorShow(ref _target.rangeLists, "Range:", DrawCustomRangeDataList);
                break;
            case EShaderPropertyType.Float:
                ShaderPropertyEditorShow(ref _target.floatList, "Float:", DrawCustomFloatDataList);
                break;
            case EShaderPropertyType.TexEnv:
                ShaderPropertyEditorShow(ref _target.textureSTList, "Texture_ST", DrawCustomTexSTDataList);
                break;
            case EShaderPropertyType.Color:
                ShaderPropertyEditorShow(ref _target.colorGradients, "Color:", DrawCustomGradientDataList);
                break;
            default:
                break;
        }

        EditorGUILayout.EndVertical();
    }

    /// <summary>
    /// shader 属性控制
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="list"></param>
    /// <param name="btnLable"></param>
    /// <param name="shaderProperTyShow"></param>
    private void ShaderPropertyEditorShow<T>(ref List<T> list, string btnLable, ShaderProperTyShow shaderProperTyShow)
    {
        if (_target.GetDicListCount(_target.eShaderPropertyType.ToString()) > 0)
        {

            EditorGUILayout.BeginVertical("box");

            shaderProperTyShow();

            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("Creat " + btnLable))
            {
                T t = default(T);
                AddListItem<T>(ref list, t);
            }
            EditorGUILayout.EndHorizontal();

            GUILayout.Space(4);

            EditorGUILayout.EndVertical();
        }
        else
        {
            ShowMessageInfo("当前Shader 没有 " + _target.eShaderPropertyType.ToString() + " 控制属性！", MessageType.Error);
            return;
        }
    }

    /// <summary>
    /// 添加一个List对象
    /// </summary>
    private void AddListItem<T>(ref List<T> list, T temp)
    {
        list.Add(temp);
    }

    /// <summary>
    /// 提示信息显示
    /// </summary>
    /// <param name="message"></param>
    /// <param name="messageType"></param>
    private void ShowMessageInfo(string message, MessageType messageType)
    {
        EditorGUILayout.HelpBox(message, messageType);
    }

    /// <summary>
    /// 绘制贴图Tiling / Offset 控制属性
    /// </summary>
    private void DrawCustomTexSTDataList()
    {
        for (int i = 0; i < _target.textureSTList.Count; i++)
        {

            EditorGUILayout.BeginVertical(GUI.skin.box);
            _target.textureSTList[i].index = EditorGUILayout.Popup("Texture_ST：", _target.textureSTList[i].index, _target.GetDicList(_target.eShaderPropertyType.ToString()));
            _target.textureSTList[i].propertyName = _target.GetDicList(_target.eShaderPropertyType.ToString())[_target.textureSTList[i].index];
            string[] tempStrStr = _target.textureSTList[i].propertyName.Split('/');
            _target.textureSTList[i].targetPropertyName = tempStrStr[0];

            string temp = tempStrStr[tempStrStr.Length - 1];
            _target.textureSTList[i].specificStr = temp.Split('_')[0];
            _target.textureSTList[i].axisName = temp.Split('_')[1];
            EditorGUILayout.LabelField("Property_ST：", _target.textureSTList[i].specificStr + " --> " + _target.textureSTList[i].axisName);

            _target.textureSTList[i].floatResult = EditorGUILayout.FloatField("Value：", _target.textureSTList[i].floatResult);
            _target.textureSTList[i].scaleCurve = EditorGUILayout.FloatField("Value Scale：", _target.textureSTList[i].scaleCurve);


            _target.textureSTList[i].applyChild = EditorGUILayout.ToggleLeft("Apply Child：", _target.textureSTList[i].applyChild, GUILayout.Width(guiLayoutWidth));
            _target.textureSTList[i].useSelfAnimCurve = EditorGUILayout.ToggleLeft("Only Curve：", _target.textureSTList[i].useSelfAnimCurve, GUILayout.Width(guiLayoutWidth));
            if (_target.textureSTList[i].useSelfAnimCurve == true)
            {
                _target.textureSTList[i].animCurve = EditorGUILayout.CurveField("", _target.textureSTList[i].animCurve, GUILayout.Height(curveHeight - 8), GUILayout.MinWidth(guiLayoutWidth));
            }
            HoriDeleteBtn<CurveAnimTexSTShaderPro>(ref _target.textureSTList, i);
            EditorGUILayout.EndVertical();
        }
    }

    /// <summary>
    /// 绘制float 属性
    /// </summary>
    private void DrawCustomFloatDataList()
    {

        for (int i = 0; i < _target.floatList.Count; i++)
        {

            EditorGUILayout.BeginVertical(GUI.skin.box);

            _target.floatList[i].index = EditorGUILayout.Popup("Float:", _target.floatList[i].index, _target.GetDicList(_target.eShaderPropertyType.ToString()));

            _target.floatList[i].propertyName = _target.GetDicList(_target.eShaderPropertyType.ToString())[_target.floatList[i].index];
            EditorGUILayout.LabelField("Property_Float：", _target.floatList[i].propertyName);

            _target.floatList[i].floatResult = EditorGUILayout.FloatField("Value：", _target.floatList[i].floatResult);
            _target.floatList[i].scaleCurve = EditorGUILayout.FloatField("Value Scale：", _target.floatList[i].scaleCurve);


            _target.floatList[i].applyChild = EditorGUILayout.ToggleLeft("Apply Child：", _target.floatList[i].applyChild, GUILayout.Width(guiLayoutWidth));
            _target.floatList[i].useSelfAnimCurve = EditorGUILayout.ToggleLeft("Only Curve：", _target.floatList[i].useSelfAnimCurve, GUILayout.Width(guiLayoutWidth));
            if (_target.floatList[i].useSelfAnimCurve == true)
            {
                _target.floatList[i].animCurve = EditorGUILayout.CurveField("", _target.floatList[i].animCurve, GUILayout.Height(curveHeight - 8), GUILayout.MinWidth(guiLayoutWidth));
            }

            HoriDeleteBtn<CurveAnimFloatShaderPro>(ref _target.floatList, i);

            EditorGUILayout.EndVertical();
        }

    }

    private int guiLayoutWidth = 100;
    /// <summary>
    /// 绘制Range属性
    /// </summary>
    private void DrawCustomRangeDataList()
    {
        if (_target.rangeLists.Count > 0)
        {
            for (int i = 0; i < _target.rangeLists.Count; i++)
            {

                EditorGUILayout.BeginVertical(GUI.skin.box);

                _target.rangeLists[i].index = EditorGUILayout.Popup("Range:", _target.rangeLists[i].index, _target.GetDicList(_target.eShaderPropertyType.ToString()));

                _target.rangeLists[i].propertyName = _target.GetDicList(_target.eShaderPropertyType.ToString())[_target.rangeLists[i].index];
                EditorGUILayout.LabelField("Property_Range：", _target.rangeLists[i].propertyName);
                EditorGUILayout.LabelField("Range Area：", GUILayout.Width(guiLayoutWidth));

                EditorGUILayout.BeginHorizontal();
                _target.rangeLists[i].rangeInputMin = EditorGUILayout.FloatField("", _target.rangeLists[i].rangeInputMin, GUILayout.Width(guiLayoutWidth));
                _target.rangeLists[i].rangeInputMax = EditorGUILayout.FloatField("", _target.rangeLists[i].rangeInputMax, GUILayout.Width(guiLayoutWidth));
                EditorGUILayout.EndHorizontal();

                _target.rangeLists[i].rangeResult = EditorGUILayout.FloatField("Value：", _target.rangeLists[i].rangeResult);

                _target.rangeLists[i].applyChild = EditorGUILayout.ToggleLeft("Apply Child：", _target.rangeLists[i].applyChild, GUILayout.Width(guiLayoutWidth));
                _target.rangeLists[i].useSelfAnimCurve = EditorGUILayout.ToggleLeft("Only Curve：", _target.rangeLists[i].useSelfAnimCurve, GUILayout.Width(guiLayoutWidth));
                if (_target.rangeLists[i].useSelfAnimCurve == true)
                {
                    _target.rangeLists[i].animCurve = EditorGUILayout.CurveField("", _target.rangeLists[i].animCurve, GUILayout.Height(curveHeight - 8), GUILayout.MinWidth(guiLayoutWidth));
                }
                HoriDeleteBtn<CurveAnimRangeShaderPro>(ref _target.rangeLists, i);
                EditorGUILayout.EndVertical();
            }
        }
    }

    /// <summary>
    /// 绘制渐变色
    /// </summary>
    private void DrawCustomGradientDataList()
    {
        if (customColorGradients.arraySize <= 0) return;

        EditorGUILayout.BeginVertical();
        for (int i = 0; i < customColorGradients.arraySize; i++)
        {
            SerializedProperty myGradientData = customColorGradients.GetArrayElementAtIndex(i);
            DrawMyGradientData(myGradientData, i);
            HorizontalLine(GUI.skin, Color.gray);
        }
        EditorGUILayout.EndVertical();
    }

    /// <summary>
    /// 绘制细线
    /// </summary>
    /// <param name="skin"></param>
    /// <param name="color"></param>
    public static void HorizontalLine(GUISkin skin, Color color, RectOffset rectOffset = null)
    {
        GUIStyle splitter = new GUIStyle(skin.box);
        splitter.border = new RectOffset(1, 1, 1, 1);
        splitter.stretchWidth = true;
        if (rectOffset == null)
            splitter.margin = new RectOffset(3, 3, 7, 7);
        else
            splitter.margin = rectOffset;


        Color restoreColor = GUI.contentColor;
        GUI.contentColor = color;
        GUILayout.Box("", splitter, GUILayout.Height(1.0f));

        GUI.contentColor = restoreColor;
    }

    /// <summary>
    /// 绘制渐变色具体属性
    /// </summary>
    /// <param name="item"></param>
    /// <param name="index"></param>
    private void DrawMyGradientData(SerializedProperty item, int index)
    {
        EditorGUILayout.BeginVertical();

        if (_target.colorGradients.Count > 0 && _target.colorGradients.Count > index)
        {
            _target.colorGradients[index].index = EditorGUILayout.Popup("Color：", _target.colorGradients[index].index, _target.GetDicList(_target.eShaderPropertyType.ToString()));
            _target.colorGradients[index].propertyName = _target.GetDicList(_target.eShaderPropertyType.ToString())[_target.colorGradients[index].index];
            EditorGUILayout.LabelField("Property_Color：", _target.colorGradients[index].propertyName);

        }

        SerializedProperty gradient = item.FindPropertyRelative("colorGradient");
        EditorGUILayout.PropertyField(gradient, new GUIContent("GradientColor："));

        SerializedProperty applyChild = item.FindPropertyRelative("applyChild");
        EditorGUILayout.PropertyField(applyChild, new GUIContent("Apply Child："));

        HoriDeleteBtn<CurveAnimColorShaderPro>(ref _target.colorGradients, index);
        EditorGUILayout.EndVertical();
        serializedObject.ApplyModifiedProperties();
    }

    /// <summary>
    /// 删除按钮
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="tempList"></param>
    /// <param name="index"></param>
    private void HoriDeleteBtn<T>(ref List<T> tempList, int index)
    {
        if (GUILayout.Button("Delect"))
        {
            RemoveGradientItem<T>(ref tempList, index);
        }
    }

    private delegate void ShaderProperTyShow();

    /// <summary>
    /// 移除一个List对象
    /// </summary>
    /// <param name="index"></param>
    private void RemoveGradientItem<T>(ref List<T> list, int index)
    {
        if (list.Count > 0 && list.Count > index)
        {
            list.RemoveAt(index);
            serializedObject.ApplyModifiedProperties();
        }
    }

    /// <summary>
    /// 将当前选定对象shader中 指定属性名放入字典列表
    /// </summary>
    /// <param name="shaderPropertyType">shader属性</param>
    private void DicAdd(ShaderUtil.ShaderPropertyType shaderPropertyType)
    {
        List<string> tempList = new List<string>();
        GetShaderPropertyType(ref tempList, shaderPropertyType, tempShader);
        if (!_target.shaderPropertys.ContainsKey(shaderPropertyType.ToString()))
            _target.shaderPropertys.Add(shaderPropertyType.ToString(), tempList);
    }

    public struct TexST
    {
        public string tiling_X;
        public string tiling_Y;
        public string offset_X;
        public string offset_Y;

        public TexST(string a, string b, string c, string d)
        {
            this.tiling_X = a;
            this.tiling_Y = b;
            this.offset_X = c;
            this.offset_Y = d;
        }
    };

    /// <summary>
    /// 获取指定shader 类型
    /// </summary>
    public void GetShaderPropertyType(ref List<string> propertys, ShaderUtil.ShaderPropertyType shaderPropertyType, Shader shader)
    {
        if (shader == null || ShaderUtil.GetPropertyCount(shader) <= 0)
        {
            Debug.Log("<color=red>" + "当前对象shader不存在 或者 shader属性数量为空！！" + "</color>");
            return;
        }

        for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++)
        {
            if (ShaderUtil.GetPropertyType(shader, i) == shaderPropertyType &&
                ShaderUtil.IsShaderPropertyHidden(shader, i) == false)
            {
                string propertyName = ShaderUtil.GetPropertyName(shader, i);

                if (shaderPropertyType == ShaderUtil.ShaderPropertyType.TexEnv)
                {
                    TexST tempST = new TexST(propertyName + "/Tiling_X", propertyName + "/Tiling_Y", propertyName + "/Offset_X", propertyName + "/Offset_Y");
                    if (!propertys.Contains(tempST.tiling_X))
                        propertys.Add(tempST.tiling_X);

                    if (!propertys.Contains(tempST.tiling_Y))
                        propertys.Add(tempST.tiling_Y);

                    if (!propertys.Contains(tempST.offset_X))
                        propertys.Add(tempST.offset_X);

                    if (!propertys.Contains(tempST.offset_Y))
                        propertys.Add(tempST.offset_Y);
                }
                else
                {
                    if (!propertys.Contains(propertyName))
                        propertys.Add(propertyName);
                }

            }
        }
    }

}
#endif


/// <summary>
/// 材质属性基类
/// </summary>
[System.Serializable]
public class CurveAnimShaderProBase
{
    /// <summary>
    /// 记录下拉属性对应的索引
    /// </summary>
    public int index = 0;
    /// <summary>
    /// 属性名
    /// </summary>
    public string propertyName;
    /// <summary>
    /// 是否应用到所有子对象
    /// </summary>
    public bool applyChild = true;

    /// <summary>
    /// 曲线倍率
    /// </summary>
    public float scaleCurve = 1;

    /// <summary>
    /// 默认是否使用自己的曲线
    /// </summary>
    public bool useSelfAnimCurve = false;
    /// <summary>
    /// 动画曲线
    /// </summary>
    public AnimationCurve animCurve = new AnimationCurve();
}

/// <summary>
/// 材质Color类型数据
/// </summary>
[System.Serializable]
public class CurveAnimColorShaderPro : CurveAnimShaderProBase
{
    [SerializeField]
    /// <summary>
    /// 颜色渐变
    /// </summary>
    public Gradient colorGradient = new Gradient();

    public CurveAnimColorShaderPro() { }
    public CurveAnimColorShaderPro(int index, Gradient gradient, string colorProperty, bool applyChild = true)
    {
        this.index = index;
        this.colorGradient = gradient;
        this.applyChild = applyChild;
        this.propertyName = colorProperty;
    }

}

/// <summary>
/// 材质Range类型数据
/// </summary>
[System.Serializable]
public class CurveAnimRangeShaderPro : CurveAnimShaderProBase
{
    public float rangeResult = 0;
    public float rangeInputMin = 0;
    public float rangeInputMax = 1;
    public CurveAnimRangeShaderPro() { }
    public CurveAnimRangeShaderPro(float range, float rangIdleMin, float rangeIdleMax)
    {
        this.rangeResult = range;
        this.rangeInputMin = rangIdleMin;
        this.rangeInputMax = rangeIdleMax;
    }
}

/// <summary>
/// 材质Float类型数据
/// </summary>
[System.Serializable]
public class CurveAnimFloatShaderPro : CurveAnimShaderProBase
{
    public float floatResult = 0;

    public CurveAnimFloatShaderPro() { }
    public CurveAnimFloatShaderPro(float result)
    {
        this.floatResult = result;
    }
}

/// <summary>
/// 材质TextureST类型数据
/// </summary>
[System.Serializable]
public class CurveAnimTexSTShaderPro : CurveAnimShaderProBase
{
    public Vector2 textureScale;
    public Vector2 textureOffset;
    public float floatResult = 0;
    /// <summary>
    /// shader 贴图对应的属性名
    /// </summary>
    public string targetPropertyName;
    /// <summary>
    /// tiling / Offset x或者y分量
    /// </summary>
    public string axisName;
    /// <summary>
    /// 具体是Tiling / Offset
    /// </summary>
    public string specificStr;
    public CurveAnimTexSTShaderPro() { }
    public CurveAnimTexSTShaderPro(Vector2 tiling, Vector2 offset)
    {
        this.textureScale = tiling;
        this.textureOffset = offset;
    }
}
