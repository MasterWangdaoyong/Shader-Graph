//20200716 晴
Shader "JianpingWang/Test_PBR"   
{
    Properties
    {
		_Color("Color",color) = (0.82, 0.67, 0.16,1)	//颜色
		_MainTex("Albedo",2D) = "white"{}	//反照率
		_MetallicGlossMap("Metallic",2D) = "white"{} //金属图，r通道存储金属度，a通道存储光滑度
		_BumpMap("Normal Map",2D) = "bump"{}//法线贴图
		_OcclusionMap("Occlusion",2D) = "white"{}//环境光遮挡纹理
		_MetallicStrength("MetallicStrength",Range(0,1)) = 1 //金属强度
		_GlossStrength("Smoothness",Range(0,1)) = 0.5 //光滑强度
		_BumpScale("Normal Scale",float) = 1 //法线影响大小
		_EmissionColor("Color",color) = (0,0,0) //自发光颜色
		_EmissionMap("Emission Map",2D) = "white"{}//自发光贴图
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "TEST_PBR_MAIN.cginc"
           
            ENDCG
        }
    }
}
