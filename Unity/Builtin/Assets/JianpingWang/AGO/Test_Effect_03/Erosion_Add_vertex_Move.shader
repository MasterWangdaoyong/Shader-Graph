
Shader "TestEffect/Erosion_Add_vertex_Move" 
{
    Properties 
    {
        [Header(Base)] 
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Texture ("Texture(RGB)", 2D) = "white" {}
        [Space(20)] [Header(MoveTex)] 
        _vertex_move ("Vertex_move(RGB)", 2D) = "white" {}
        _moveXYZ ("modelXYZ", Vector) = (0,0,0,0)
        _vertex_v ("Vertex_v", Float ) = 0
        _vertex_u ("Vertex_u", Float ) = 0
    }
    SubShader 
    {

        Tags {  "IgnoreProjector"="True"   "Queue"="Transparent"     "RenderType"="Transparent"  }

        Pass 
        {
            Tags { "LightMode"="ForwardBase"  }
            Blend One One
            Cull Off
            ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _Texture; 
            half4 _Texture_ST;
            fixed4 _Color;
            sampler2D _vertex_move; 
            half4 _vertex_move_ST;
            half4 _moveXYZ;
            half _vertex_v;
            half _vertex_u;

            struct appdata 
            {
                float4 vertex       : POSITION;
                float3 normal       : NORMAL;
                float2 texcoord     : TEXCOORD0;
                float4 vertColor    : COLOR;
            };
            struct v2f 
            {
                float4 pos         : SV_POSITION;
                float4 vertColor   : COLOR;
                float2 UV          : TEXCOORD3;
            };

            v2f vert (appdata v) 
            {
                v2f o = (v2f)0;               

                half Time = _Time.y;
                half2 TimeUv = half2((_vertex_u*Time),(Time*_vertex_v))+ v.texcoord;
                half4 _vertex_move_var = tex2Dlod(_vertex_move,half4(TRANSFORM_TEX(TimeUv, _vertex_move),0,0));    //使用了RGB   //显式纹理LOD采样
                v.vertex.xyz += (_vertex_move_var.rgb * v.normal *_moveXYZ.rgb);
                
                o.UV = TRANSFORM_TEX(v.texcoord, _Texture);
                o.vertColor = v.vertColor;

                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            
            fixed4 frag(v2f i) : COLOR 
            {
                fixed4 tex = tex2D(_Texture, i.UV);       //使用了RGBA  

                fixed4 finalColor = fixed4(0,0,0,0);
                finalColor = _Color * tex  * i.vertColor;

                return finalColor;
            }
            ENDCG
        }
        
    }
}
