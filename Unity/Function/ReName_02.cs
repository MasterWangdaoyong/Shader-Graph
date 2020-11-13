using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Text.RegularExpressions;
using System.IO;
//批量重命名资源　　　JianpingWang 20190619 
public class ReName_02 : MonoBehaviour
{
    [MenuItem("Assets/ReName")]
    public static void ToRename()
    {

        Object[] m_objects = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);//选择的所以对象

        int index = 0;//序号

        foreach (Object item in m_objects)
        {

            //string m_name = item.name;
            if (Path.GetExtension(AssetDatabase.GetAssetPath(item)) != "")//判断路径是否为空
            {

                string path = AssetDatabase.GetAssetPath(item);


                AssetDatabase.RenameAsset(path, "Prefabs_" + item.name );
                //AssetDatabase.RenameAsset(path, index +""+ item.name +"资源类型（自定义）" );
                index++;
            }

        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }


    [MenuItem("Assets/CleanName")]
    public static void CleanName()
    {

        Object[] m_objects = Selection.GetFiltered(typeof(Object), SelectionMode.DeepAssets);//选择的所以对象

        int index = 0;//序号

        foreach (Object item in m_objects)
        {

            //string m_name = item.name;
            if (Path.GetExtension(AssetDatabase.GetAssetPath(item)) != "")//判断路径是否为空
            {

                string path = AssetDatabase.GetAssetPath(item);


                AssetDatabase.RenameAsset(path, "" +index);
                //AssetDatabase.RenameAsset(path, index +""+ item.name +"资源类型（自定义）" );
                index++;
            }

        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}

