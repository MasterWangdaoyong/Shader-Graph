using UnityEngine;
using System.Collections;
using System.IO;
using System.Text;
//批量生成prefabs JianpingWang 20190619
public class ObjExporter
{

    public static string MeshToString(MeshFilter mf)
    {
        Mesh m = mf.sharedMesh;
        //  Material[] mats = mf.GetComponent<MeshRenderer>().sharedMaterials;

        StringBuilder sb = new StringBuilder();

        sb.Append("g ").Append(mf.name).Append("\n");
        for (int i = 0; i < m.vertices.Length; i++)
            sb.Append(string.Format("v {0} {1} {2}\n", -m.vertices[i].x, m.vertices[i].y, m.vertices[i].z));
        sb.Append("\n");
        for (int i = 0; i < m.normals.Length; i++)
            sb.Append(string.Format("vn {0} {1} {2}\n", -m.normals[i].x, m.normals[i].y, m.normals[i].z));
        sb.Append("\n");
        for (int i = 0; i < m.uv.Length; i++)
            sb.Append(string.Format("vt {0} {1}\n", m.uv[i].x, m.uv[i].y));

        for (int material = 0; material < m.subMeshCount; material++)
        {
            sb.Append("\n");

            int[] triangles = m.GetTriangles(material);
            for (int i = 0; i < triangles.Length; i += 3)
            {
                //Because we inverted the x-component, we also needed to alter the triangle winding.
                sb.Append(string.Format("f {1}/{1}/{1} {0}/{0}/{0} {2}/{2}/{2}\n",
                    triangles[i] + 1, triangles[i + 1] + 1, triangles[i + 2] + 1));
            }
        }
        return sb.ToString();
    }

    public static void MeshToFile(MeshFilter mf, string filename)
    {
        using (StreamWriter sw = new StreamWriter(filename))
        {
            sw.Write(MeshToString(mf));
        }
    }
}

