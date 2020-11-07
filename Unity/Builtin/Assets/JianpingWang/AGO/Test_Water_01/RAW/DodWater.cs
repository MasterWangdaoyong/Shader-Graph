using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DodWater : MonoBehaviour
{
    public LayerMask _cullingMask = ~(1 << 4);
    public Texture2D _waveTex = null;
    [Range(0f, 1f)]
    public float _waveScale = 0.2f;
    public Vector4 _waveDireciotn = new Vector4(1, 1, 1, 1);
    public Vector4 _waveTiling = new Vector4(0.0625f, 0.0625f, 0.0625f, 0.0625f);
   
    //---------------JianpingWang fix
    public Color _MainColor = Color.white;    
    public Texture2D _Gradient = null;
    [Range(0.5f, 3f)]
    public float _MainScale = 1f;
    [Range(0f, 3f)]
    public float _GradientMaskScale = 2f;  
    //---------------

    private Material _waterMat;
    public Material WaterMat
    {
        get
        {
            if(_waterMat == null)
            {
                var renderer = GetComponent<Renderer>();
                if (renderer == null || renderer.sharedMaterial == null || renderer.sharedMaterial.shader.name != "Dodjoy/Scene/Scene_Water_GlassReflection")
                {
                    var s = Shader.Find("Dodjoy/Scene/Scene_Water_GlassReflection");
                    if(s != null)
                    {
                        renderer.sharedMaterial = new Material(s);
                        renderer.sharedMaterial.name = "DodWater (Instance)";
                    }
                }
                _waterMat = renderer.sharedMaterial;
            }
            return _waterMat;
        }
    }
    private Camera _reflectionCam;
    public Camera ReflectionCam
    {
        get
        {
            if (_reflectionCam == null && CurrentCam != null)
            {
                var trans = transform.Find("__Reflection Camera");
                if(trans == null)
                {
                    //DestroyImmediate(trans.gameObject);

                    trans = new GameObject("__Reflection Camera").transform;
                    trans.SetParent(transform);
                }

                if(trans.GetComponent<Camera>() == null)
                {
                    _reflectionCam = trans.gameObject.AddComponent<Camera>();
                }
                else
                {
                    _reflectionCam = trans.gameObject.GetComponent<Camera>();
                }
                
                _reflectionCam.CopyFrom(CurrentCam);
                _reflectionCam.hideFlags = HideFlags.HideAndDontSave;

                _reflectionRT = RenderTexture.GetTemporary(CurrentCam.pixelWidth, CurrentCam.pixelHeight, 24);
                _reflectionCam.targetTexture = _reflectionRT;
                _reflectionCam.enabled = false;
            }
            return _reflectionCam;
        }
    }

    public Camera CurrentCam
    {
        get
        {
            return Camera.main;
        }
    }

    private RenderTexture _reflectionRT;
    private bool _isRendering;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnDisable()
    {
        if(_reflectionRT != null)
        {
            RenderTexture.ReleaseTemporary(_reflectionRT);
            _reflectionRT = null;
        }

        if(_reflectionCam != null)
        {
            //DestroyImmediate(_reflectionCam.gameObject);
            _reflectionCam = null;
        }
    }


    void SetWaterMatParam()
    {
        WaterMat.SetTexture("_WaveTex", _waveTex);
        WaterMat.SetFloat("_WaveScale", _waveScale);
        WaterMat.SetVector("_WaveTiling", _waveTiling);
        WaterMat.SetVector("_WaveDireciotn", _waveDireciotn);       
        WaterMat.SetTexture("_ReflectionTex", _reflectionRT);

        //---------------JianpingWang fix
        WaterMat.SetColor("_MainColor", _MainColor);        
        WaterMat.SetTexture("_Gradient", _Gradient);
        WaterMat.SetFloat("_MainScale", _MainScale);
        WaterMat.SetFloat("_GradientMaskScale", _GradientMaskScale);        
        //---------------
    }


    private void OnWillRenderObject()
    {
        if(CurrentCam == null || ReflectionCam == null)
        {
            return;
        }

        if (_isRendering)
        {
            return;
        }

        _isRendering = true;

        var reflectM = CaculateReflectMatrix();
        ReflectionCam.worldToCameraMatrix = CurrentCam.worldToCameraMatrix * reflectM;

        var normal = transform.up;
        var d = -Vector3.Dot(normal, transform.position);
        var plane = new Vector4(normal.x, normal.y, normal.z, d);
        var clipMatrix = CalculateObliqueMatrix(plane, ReflectionCam);
        ReflectionCam.projectionMatrix = clipMatrix;

        GL.invertCulling = true;
        ReflectionCam.Render();
        GL.invertCulling = false;

        UpdateCamearaParams(CurrentCam, ReflectionCam);
        SetWaterMatParam();
        _isRendering = false;
    }

    private void UpdateCamearaParams(Camera srcCamera, Camera destCamera)
    {
        if (destCamera == null || srcCamera == null)
            return;

        destCamera.clearFlags = srcCamera.clearFlags;
        destCamera.backgroundColor = srcCamera.backgroundColor;
        destCamera.farClipPlane = srcCamera.farClipPlane;
        destCamera.nearClipPlane = srcCamera.nearClipPlane;
        destCamera.orthographic = srcCamera.orthographic;
        destCamera.fieldOfView = srcCamera.fieldOfView;
        destCamera.aspect = srcCamera.aspect;
        destCamera.orthographicSize = srcCamera.orthographicSize;

        destCamera.cullingMask = _cullingMask;
    }

    Matrix4x4 CaculateReflectMatrix()
    {
        var normal = transform.up;
        var d = -Vector3.Dot(normal, transform.position);
        var reflectM = new Matrix4x4();
        reflectM.m00 = 1 - 2 * normal.x * normal.x;
        reflectM.m01 = -2 * normal.x * normal.y;
        reflectM.m02 = -2 * normal.x * normal.z;
        reflectM.m03 = -2 * d * normal.x;

        reflectM.m10 = -2 * normal.x * normal.y;
        reflectM.m11 = 1 - 2 * normal.y * normal.y;
        reflectM.m12 = -2 * normal.y * normal.z;
        reflectM.m13 = -2 * d * normal.y;

        reflectM.m20 = -2 * normal.x * normal.z;
        reflectM.m21 = -2 * normal.y * normal.z;
        reflectM.m22 = 1 - 2 * normal.z * normal.z;
        reflectM.m23 = -2 * d * normal.z;

        reflectM.m30 = 0;
        reflectM.m31 = 0;
        reflectM.m32 = 0;
        reflectM.m33 = 1;
        return reflectM;
    }

    private Matrix4x4 CalculateObliqueMatrix(Vector4 plane, Camera camera)
    {
        var viewSpacePlane = camera.worldToCameraMatrix.inverse.transpose * plane;
        var projectionMatrix = camera.projectionMatrix;

        var clipSpaceFarPanelBoundPoint = new Vector4(Mathf.Sign(viewSpacePlane.x), Mathf.Sign(viewSpacePlane.y), 1, 1);
        var viewSpaceFarPanelBoundPoint = camera.projectionMatrix.inverse * clipSpaceFarPanelBoundPoint;

        var m4 = new Vector4(projectionMatrix.m30, projectionMatrix.m31, projectionMatrix.m32, projectionMatrix.m33);        
        var u = 2.0f / Vector4.Dot(viewSpaceFarPanelBoundPoint, viewSpacePlane);
        var newViewSpaceNearPlane = u * viewSpacePlane;

        //M3' = P - M4
        var m3 = newViewSpaceNearPlane - m4;

        projectionMatrix.m20 = m3.x;
        projectionMatrix.m21 = m3.y;
        projectionMatrix.m22 = m3.z;
        projectionMatrix.m23 = m3.w;

        return projectionMatrix;
    }

}
