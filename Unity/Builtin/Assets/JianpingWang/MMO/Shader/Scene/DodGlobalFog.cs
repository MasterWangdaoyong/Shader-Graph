using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[SerializeField]
public enum FogType
{
    None,
    Linear,
    Exponential,
    Exp2
}

[ExecuteInEditMode]
public class DodGlobalFog : MonoBehaviour
{
    public FogType fog_fogType = FogType.Linear;

    public Color fog_fogcolor = Color.white;  //雾颜色
    public float fog_heightControl = 0f;  //高度控制

    [Range(0f, 1000f)]
    public float fog_smoothfog = 20f;  //平滑控制
    public float fog_fogstart = 20f;  //雾效起始
    public float fog_fogend = 100f;  //雾效完结

    [Range(0f, 0.5f)]
    public float fog_fogblend = 0.25f;    //高度雾与线性雾混合


    [Range(-2f, 2f)]
    public float fog_skyboxFogHeight = 0.0f;  
    [Range(0f, 1f)]
    public float fog_skyboxFogSmooth = 0.5f;
    public Color fog_sunColor = Color.gray;

    [Range(0.1f, 0.6f)]
    public float fog_SunSize = 0.2f;
    public bool fog_SunOn = false;

    void OnEnable()
    {
        SetGlobalFog();
        // SetPlatform();
    }

    void OnDisable()
    {
        SetFogType(FogType.None);
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }


    void OnValidate()
    {
        if(fog_fogend < fog_fogstart)
        {
            fog_fogend = fog_fogstart + 0.1f;
        }


        SetGlobalFog();
    }

    void SetGlobalFog()
    {
        SetFogType(fog_fogType);        
        Shader.SetGlobalColor("_FogColor", fog_fogcolor);
        Shader.SetGlobalFloat("_HeightControl", fog_heightControl);
        Shader.SetGlobalFloat("_SmoothFog", fog_smoothfog);
        Shader.SetGlobalFloat("_FogStart", fog_fogstart);
        Shader.SetGlobalFloat("_FogEnd", fog_fogend);
        Shader.SetGlobalFloat("_FogBlend", fog_fogblend);//按百分比缩小

        Shader.SetGlobalFloat("_SkyboxFogHeight", fog_skyboxFogHeight);
        Shader.SetGlobalFloat("_SkyboxFogSmooth", fog_skyboxFogSmooth);

        Shader.SetGlobalColor("_SunColor", fog_sunColor);
        Shader.SetGlobalFloat("_SunSize", fog_SunSize);
        if (fog_SunOn)
        {
            Shader.EnableKeyword("DOD_SUN_ON");
        }
        else if (!fog_SunOn)
        {
            Shader.DisableKeyword("DOD_SUN_ON");
        }
    }

    // void SetPlatform()
    // {
    //     if (Application.platform == RuntimePlatform.WindowsPlayer)
    //     {
    //         Shader.EnableKeyword("DOD_PLATFORM_PC");
    //         Shader.DisableKeyword("DOD_PLATFORM_MOBILE");
    //     }
    //     else
    //     {
    //         Shader.DisableKeyword("DOD_PLATFORM_PC");
    //         Shader.EnableKeyword("DOD_PLATFORM_MOBILE");
    //     }

    // }

    void SetFogType(FogType fogType)
    {
        switch(fogType)
        {
            case FogType.Linear:   
                Shader.EnableKeyword("DOD_FOG_LINEAR");
                Shader.DisableKeyword("DOD_FOG_EXP");
                Shader.DisableKeyword("DOD_FOG_EXP2");
                Shader.DisableKeyword("DOD_FOG_NONE");
                break;
            case FogType.Exponential:
                Shader.DisableKeyword("DOD_FOG_LINEAR");
                Shader.EnableKeyword("DOD_FOG_EXP");
                Shader.DisableKeyword("DOD_FOG_EXP2");
                Shader.DisableKeyword("DOD_FOG_NONE");
                break;
            case FogType.Exp2:
                Shader.DisableKeyword("DOD_FOG_LINEAR");
                Shader.DisableKeyword("DOD_FOG_EXP");
                Shader.EnableKeyword("DOD_FOG_EXP2");
                Shader.DisableKeyword("DOD_FOG_NONE");
                break;
            default:
                Shader.DisableKeyword("DOD_FOG_LINEAR");
                Shader.DisableKeyword("DOD_FOG_EXP");
                Shader.DisableKeyword("DOD_FOG_EXP2");
                Shader.EnableKeyword("DOD_FOG_NONE");
                break;
        }
    }
}
