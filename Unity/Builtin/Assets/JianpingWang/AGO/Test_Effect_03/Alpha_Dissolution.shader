
Shader "wqq/Alpha_Dissolution"    
{
    Properties 
    {
        _DiffuseColor ("DiffuseColor", Color) = (1,1,1,1)
        _Textuers ("Textuers(RGBA)", 2D) = "white" {}
        _U_speed ("U_speed", Float ) = 0
        _V_speed ("V_speed", Float ) = 0
        _TextureB ("TextureB(RGB)", 2D) = "white" {}
        _TexB_U_speed ("TexB_U_speed", Float ) = 0
        _TexB_V_speed ("TexB_V_speed", Float ) = 0
        _OpactiyTex ("OpactiyTex(R)", 2D) = "white" {}
        [MaterialToggle] _Dissolutionon_off ("Dissolution on_off", Float ) = 1
        _Dissolution_Tex ("Dissolution_Tex(R)", 2D) = "white" {}
        [MaterialToggle] _UVON ("UV ON", Float ) = 0
        [MaterialToggle] _Diss_UV ("Diss_UV", Float ) = 0
        _Diss_U ("Diss_U", Float ) = 0
        _Diss_V ("Diss_V", Float ) = 0
    }
    SubShader 
    {
        Tags {  "IgnoreProjector"="True"   "Queue"="Transparent"   "RenderType"="Transparent"}

        LOD 100

        Pass 
        {
            
            Tags { "LightMode"="ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0

            sampler2D _Textuers; 
            half4 _Textuers_ST;
            half4 _DiffuseColor;
            half _U_speed;
            half _V_speed;
            sampler2D _OpactiyTex; 
            half4 _OpactiyTex_ST;
            sampler2D _Dissolution_Tex; 
            half4 _Dissolution_Tex_ST;
            fixed _Dissolutionon_off;
            fixed _UVON;
            fixed _Diss_UV;
            half _Diss_U;
            half _Diss_V;
            sampler2D _TextureB; 
            half4 _TextureB_ST;
            half _TexB_U_speed;
            half _TexB_V_speed;
            
            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 texcoord1 : TEXCOORD1;
                float4 vertexColor : COLOR;
            };
            struct v2f 
            {
                float4 pos : SV_POSITION;
                float2 uv1 : TEXCOORD1;
                float4 vertexColor : COLOR;
                float2 texBuv : TEXCOORD2;
                float2 texuv : TEXCOORD3;
                float2 texDissolutionuv : TEXCOORD4;
                float2 texOpactiyuv : TEXCOORD5;
            };
            
            v2f vert (appdata v) 
            {
                v2f o = (v2f)0;
                o.uv1 = v.texcoord1;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );

                half4 Time = _Time; 
                half2 fixUv1 = v.texcoord0 + half2((_TexB_U_speed * Time.g), (Time.g * _TexB_V_speed));
                o.texBuv = TRANSFORM_TEX(fixUv1, _TextureB);                

                half2 a = half2((_U_speed * Time.g),(Time.g * _V_speed)) + v.texcoord0;
                half2 b = v.texcoord0 + v.texcoord1;
                half2 _UVON_var = lerp( a, b, _UVON);
                o.texuv = TRANSFORM_TEX(_UVON_var, _Textuers);  

                half2 fixUv3 = (v.texcoord0 + half2((_Diss_U*Time.g),(Time.g*_Diss_V)));
                half2 fixUv33 = lerp( v.texcoord0, fixUv3, _Diss_UV );
                o.texDissolutionuv = TRANSFORM_TEX(fixUv33, _Dissolution_Tex);

                o.texOpactiyuv =  TRANSFORM_TEX(v.texcoord0, _OpactiyTex);

                return o;
            }
            
            fixed4 frag(v2f i ) : COLOR 
            {
                fixed4 texB = tex2D(_TextureB, i.texBuv);    //使用了RGB
                fixed4 tex = tex2D(_Textuers, i.texuv);      //使用了RGBA
                fixed4 texDissolution = tex2D(_Dissolution_Tex, i.texDissolutionuv);    //使用了R
                fixed4 texOpactiy = tex2D(_OpactiyTex, i.texOpactiyuv);   //使用了R

                fixed4 finalColor = 0;
                finalColor.rgb = texB.rgb * _DiffuseColor.rgb * i.vertexColor.rgb * tex.rgb; 
                finalColor.a  = i.vertexColor.a * texOpactiy.r * lerp(1.0, step(i.uv1.r, texDissolution.r), _Dissolutionon_off ) * tex.a * _DiffuseColor.a;

                return finalColor;
            }
            ENDCG
        }       
        
    }
   
}
