
// 3/3  C




Shader "JianpingWang/Test_cginc_shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "LightMode"="ForwardBase" }
        LOD 100
        

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert   
            //需要声明
            #pragma fragment frag 
            //需要声明
            #include "Test_cgincB.cginc"

            
            ENDCG
        }
    }
}
