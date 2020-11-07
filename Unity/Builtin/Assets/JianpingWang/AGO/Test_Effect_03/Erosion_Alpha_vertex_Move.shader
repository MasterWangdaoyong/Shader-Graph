
Shader "TestEffect/Erosion_Alpha_vertex_Move" 
{
    Properties 
    {
        [Header(Base)] 
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _Texture ("Texture(RGBA)", 2D) = "white" {}
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
            Blend SrcAlpha OneMinusSrcAlpha
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






// Shader "MagesBox/Erosion_Alpha_vertex_Move"    
// {
//     Properties 
//     {
//         _Texture ("Texture(RGBA)", 2D) = "white" {}
//         _Color ("Color", Color) = (0.5,0.5,0.5,1)
//         _Erosion_Texture ("Erosion_Texture(R)", 2D) = "white" {}
//         _Soft_Value ("Soft_Value", Float ) = 0
//         _Make ("Make(RGBA)", 2D) = "white" {}
//         _node_2890 ("node_2890", Float ) = 0
//         _node_7462 ("node_7462", Float ) = 0
//         _vertex_move ("vertex_move(RBG)", 2D) = "white" {}
//         _Vector ("Vector", Vector) = (0,0,0,0)
//         _vertex_v ("vertex_v", Float ) = 0
//         _vertex_u ("vertex_u", Float ) = 0
//     }
//     SubShader 
//     {
//         Tags { "IgnoreProjector"="True"  "Queue"="Transparent"   "RenderType"="Transparent"   }
//         Pass 
//         {
//             Tags {  "LightMode"="ForwardBase"  }
//             Blend SrcAlpha OneMinusSrcAlpha
//             Cull Off
//             ZWrite Off
            
//             CGPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
            
//             #include "UnityCG.cginc"

//             #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
//             #pragma target 3.0

//             sampler2D _Texture; 
//             half4 _Texture_ST;
//             fixed4 _Color;
//             sampler2D _Erosion_Texture; 
//             half4 _Erosion_Texture_ST;
//             half _Soft_Value;
//             sampler2D _Make; 
//             half4 _Make_ST;
//             half _node_2890;
//             half _node_7462;
//             sampler2D _vertex_move; 
//             half4 _vertex_move_ST;
//             half4 _Vector;
//             half _vertex_v;
//             half _vertex_u;

//             struct VertexInput 
//             {
//                 float4 vertex : POSITION;
//                 float3 normal : NORMAL;
//                 float2 texcoord0 : TEXCOORD0;
//                 float4 texcoord1 : TEXCOORD1;
//                 float4 vertexColor : COLOR;
//             };
//             struct VertexOutput 
//             {
//                 float4 pos : SV_POSITION;
//                 float4 uv1 : TEXCOORD1;
//                 float4 vertexColor : COLOR;
//                 float2 texUv2 : TEXCOORD2;
//                 float2 makeUv2 : TEXCOORD3;
//                 float2 Erosion : TEXCOORD4;
//             };

//             VertexOutput vert (VertexInput v) 
//             {
//                 VertexOutput o = (VertexOutput)0;
//                 o.uv1 = v.texcoord1;
//                 o.vertexColor = v.vertexColor;

//                 half Time = _Time.y;
//                 half2 Vtime = half2((_vertex_u*Time),(Time*_vertex_v)) + v.texcoord0;
//                 half2 vertexM = TRANSFORM_TEX(Vtime, _vertex_move);
//                 half4 _vertex_move_var = tex2Dlod(_vertex_move, half4(vertexM, 0.0, 0));   //使用了RGB
//                 v.vertex.xyz += (_vertex_move_var.rgb * v.normal * _Vector.xyz);

//                 half2 texUv = v.texcoord1 + v.texcoord0;
//                 o.texUv2 = TRANSFORM_TEX(texUv, _Texture);

//                 half2 makeUv = half2((_node_7462 * Time),( Time * _node_2890)) + v.texcoord0;
//                 o.makeUv2 = TRANSFORM_TEX(makeUv, _Make);

//                 o.Erosion = TRANSFORM_TEX(v.texcoord0, _Erosion_Texture);

//                 o.pos = UnityObjectToClipPos( v.vertex );
//                 return o;
//             }

//             fixed4 frag(VertexOutput i) : COLOR 
//             { 
//                 fixed4 tex = tex2D(_Texture, i.texUv2);             //使用了RGBA
//                 fixed4 texMake = tex2D(_Make, i.makeUv2);           //使用了RGBA
//                 fixed4 Erotex = tex2D(_Erosion_Texture, i.Erosion);     //使用了R

//                 half node_7638 = saturate(((Erotex.r * _Soft_Value) - lerp(_Soft_Value, -1.5, i.uv1.y)));

//                 fixed4 finalColor = 0;
//                 finalColor.rgb = _Color.rgb * tex.rgb * texMake.rgb * i.vertexColor.rgb * node_7638;
//                 finalColor.a = texMake.a * i.vertexColor.a * node_7638 * tex.a * _Color.a;
                
//                 return finalColor;
//             }
//             ENDCG
//         }        
//     }
// }

