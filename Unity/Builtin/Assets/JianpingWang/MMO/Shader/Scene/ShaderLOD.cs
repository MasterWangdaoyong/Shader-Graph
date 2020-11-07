using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum LODLevel
{
    Low = 200,
    Middle = 300,
    High = 600
}

[ExecuteInEditMode]
public class ShaderLOD : MonoBehaviour
{
    public LODLevel LodLevel = LODLevel.High;

    private void OnValidate()
    {
        SetShaderLOD((int)LodLevel);
    }

    public void SetShaderLOD(int lod)
    {
        LodLevel = (LODLevel) lod;
        Shader.globalMaximumLOD = lod;
    }
    
}
