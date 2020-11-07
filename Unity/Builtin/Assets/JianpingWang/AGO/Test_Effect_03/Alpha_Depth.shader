
Shader "wqq/Alpha" 
{
    Properties 
    {
        _Textuers ("Textuers", 2D) = "white" {}
        [HDR]_DiffuseColor ("DiffuseColor", Color) = (1,1,1,1)
        _DepthBlend ("Depth Blend", Float ) = 0
        [MaterialToggle] _Depthon_off ("Depth on_off", Float ) = 1
        _Opacity ("Opacity", 2D) = "white" {}
        _V_Speed ("V_Speed", Float ) = 0
        _U_Speed ("U_Speed", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
    }
    SubShader 
    {
        Tags 
        { "IgnoreProjector"="True"  "Queue"="Transparent"   "RenderType"="Transparent"  }
        LOD 100
        Pass 
        {
            Name "FORWARD"
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

            uniform sampler2D _CameraDepthTexture;
            uniform sampler2D _Textuers; uniform float4 _Textuers_ST;
            uniform float4 _DiffuseColor;
            uniform float _DepthBlend;
            uniform fixed _Depthon_off;
            uniform sampler2D _Opacity; uniform float4 _Opacity_ST;
            uniform float _U_Speed;
            uniform float _V_Speed;

            struct VertexInput 
            {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput 
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
                float4 projPos : TEXCOORD1;
            };

            VertexOutput vert (VertexInput v) 
            {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }

            float4 frag(VertexOutput i, float facing : VFACE) : COLOR 
            {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float sceneZ = max(0,LinearEyeDepth (UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)))) - _ProjectionParams.g);
                float partZ = max(0,i.projPos.z - _ProjectionParams.g);
////// Lighting:
////// Emissive:
                float4 Time = _Time;
                float2 node_8657 = (i.uv0+float2((_U_Speed*Time.g),(Time.g*_V_Speed)));
                float4 _Textuers_var = tex2D(_Textuers,TRANSFORM_TEX(node_8657, _Textuers));
                float3 emissive = (_Textuers_var.rgb*_DiffuseColor.rgb*i.vertexColor.rgb);
                float3 finalColor = emissive;
                float4 _Opacity_var = tex2D(_Opacity,TRANSFORM_TEX(i.uv0, _Opacity));
                fixed4 finalRGBA = fixed4(finalColor,(_Textuers_var.a*i.vertexColor.a*lerp( 1.0, saturate((sceneZ-partZ)/_DepthBlend), _Depthon_off )*_Opacity_var.r*_DiffuseColor.a));
                return finalRGBA;
            }
            ENDCG
        }
        
    }   
}
