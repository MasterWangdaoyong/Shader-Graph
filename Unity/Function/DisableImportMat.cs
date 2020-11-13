using UnityEditor;

/// <summary>
/// 去除模型默认导入材质的选项
/// </summary>
public class DisableImportMat : AssetPostprocessor
{
    public void OnPreprocessModel()
    {
        ModelImporter mi = assetImporter as ModelImporter;
        if (mi != null)
        {
            if (mi.importMaterials)
            {
                mi.importMaterials = false;
                mi.importBlendShapes = false;
                mi.importCameras = false;
                mi.importLights = false;
                mi.importVisibility = false;
                mi.importAnimation = false;
                mi.generateSecondaryUV = true;


            }
            
        }
    }
}