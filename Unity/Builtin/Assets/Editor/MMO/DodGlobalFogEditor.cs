using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DodGlobalFog))]
[CanEditMultipleObjects]
public class DodGlobalFogEditor : Editor
{
    [Tooltip("雾类型选择")]
    private SerializedProperty fog_fogType;


    private SerializedProperty fog_fogcolor;
    private SerializedProperty fog_heightControl;  
    private SerializedProperty fog_smoothfog;
    private SerializedProperty fog_fogstart;
    private SerializedProperty fog_fogend;
    private SerializedProperty fog_fogblend;    



    private SerializedProperty fog_skyboxFogHeight;
    private SerializedProperty fog_skyboxFogSmooth;

    private SerializedProperty fog_sunColor;    
    private SerializedProperty fog_SunOn;
    private SerializedProperty fog_SunSize;
    

    GUIStyle m_textStyle;

    void OnEnable()
    {
        fog_fogType = serializedObject.FindProperty("fog_fogType");
        
        fog_fogcolor = serializedObject.FindProperty("fog_fogcolor");
        fog_heightControl = serializedObject.FindProperty("fog_heightControl");
        fog_smoothfog = serializedObject.FindProperty("fog_smoothfog");
        fog_fogstart = serializedObject.FindProperty("fog_fogstart");
        fog_fogend = serializedObject.FindProperty("fog_fogend");
        fog_fogblend = serializedObject.FindProperty("fog_fogblend");

        fog_skyboxFogHeight = serializedObject.FindProperty("fog_skyboxFogHeight");
        fog_skyboxFogSmooth = serializedObject.FindProperty("fog_skyboxFogSmooth");

        fog_sunColor = serializedObject.FindProperty("fog_sunColor");
        fog_SunSize = serializedObject.FindProperty("fog_SunSize");
        fog_SunOn = serializedObject.FindProperty("fog_SunOn"); 
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();


        if (m_textStyle == null)
        {
            m_textStyle = new GUIStyle("HeaderLabel");  
        }

        m_textStyle.alignment = TextAnchor.MiddleCenter;

        GUILayout.Space(10f);
        GUILayout.BeginHorizontal("PopupCurveSwatchBackground");
        GUILayout.Label("Fog", m_textStyle);
        GUILayout.EndHorizontal();


        EditorGUILayout.PropertyField(fog_fogType);

        if((FogType)fog_fogType.intValue != FogType.None)
        {
            
            EditorGUILayout.PropertyField(fog_fogcolor);
            EditorGUILayout.PropertyField(fog_heightControl);
            EditorGUILayout.PropertyField(fog_smoothfog);
            if ((FogType)fog_fogType.intValue == FogType.Linear)
            {
                EditorGUILayout.PropertyField(fog_fogstart);
                EditorGUILayout.PropertyField(fog_fogend);
            }
            // else
            // {
            //     EditorGUILayout.PropertyField(fog_fogblend);
            // }
            EditorGUILayout.PropertyField(fog_fogblend);


            GUILayout.Space(10f);
            GUILayout.BeginHorizontal("PopupCurveSwatchBackground");
            GUILayout.Label("Skybox", m_textStyle);
            GUILayout.EndHorizontal();
            EditorGUILayout.PropertyField(fog_skyboxFogHeight);
            EditorGUILayout.PropertyField(fog_skyboxFogSmooth);


            GUILayout.Space(10f);
            GUILayout.BeginHorizontal("PopupCurveSwatchBackground");
            GUILayout.Label("Sun", m_textStyle);
            GUILayout.EndHorizontal();
            EditorGUILayout.PropertyField(fog_SunSize);
            EditorGUILayout.PropertyField(fog_sunColor);
            EditorGUILayout.PropertyField(fog_SunOn);
        }
        serializedObject.ApplyModifiedProperties();
    }
}
