using UnityEngine;
using System.Collections;
using UnityEditor;

[CanEditMultipleObjects]
[CustomEditor(typeof(Transform))]
public class TransformInspector : Editor {
	SerializedProperty mPos;
	SerializedProperty mScale;
	public override void OnInspectorGUI()
	{
		EditorGUIUtility.labelWidth = 15f;
		mPos = serializedObject.FindProperty("m_LocalPosition");
		mScale = serializedObject.FindProperty("m_LocalScale");
		
		DrawPosition();
		DrawRotation();
		DrawScale();
		
		serializedObject.ApplyModifiedProperties();
	}
	
	void DrawPosition ()
	{
		GUILayout.BeginHorizontal();
		{
			bool reset = GUILayout.Button("P", GUILayout.Width(20f));
			EditorGUILayout.LabelField("Position",GUILayout.Width(50f));
			EditorGUILayout.PropertyField(mPos.FindPropertyRelative("x"));
			EditorGUILayout.PropertyField(mPos.FindPropertyRelative("y"));
			EditorGUILayout.PropertyField(mPos.FindPropertyRelative("z"));
			if (reset) mPos.vector3Value = Vector3.zero;
		}
		GUILayout.EndHorizontal();
	}
	
	void DrawScale ()
	{
		GUILayout.BeginHorizontal();
		{
			bool reset = GUILayout.Button("S", GUILayout.Width(20f));
			EditorGUILayout.LabelField("Scale",GUILayout.Width(50f));
			EditorGUILayout.PropertyField(mScale.FindPropertyRelative("x"));
			EditorGUILayout.PropertyField(mScale.FindPropertyRelative("y"));
			EditorGUILayout.PropertyField(mScale.FindPropertyRelative("z"));
			if (reset) mScale.vector3Value = Vector3.one;
		}
		GUILayout.EndHorizontal();
	}
	
	void DrawRotation ()
	{
		GUILayout.BeginHorizontal();
		{
			bool reset = GUILayout.Button("R", GUILayout.Width(20f));
			EditorGUILayout.LabelField("Rotation",GUILayout.Width(50f));
			Vector3 ls = (serializedObject.targetObject as Transform).localEulerAngles;
			FloatField("X",ref ls.x);
			FloatField("Y",ref ls.y);
			FloatField("Z",ref ls.z);
			if (reset)
				(serializedObject.targetObject as Transform).localEulerAngles = Vector3.zero;
			else
				(serializedObject.targetObject as Transform).localEulerAngles = ls;
		}
		GUILayout.EndHorizontal();
	}
	
	void FloatField(string name,ref float f)
	{
		f = EditorGUILayout.FloatField(name,f);
	}
}