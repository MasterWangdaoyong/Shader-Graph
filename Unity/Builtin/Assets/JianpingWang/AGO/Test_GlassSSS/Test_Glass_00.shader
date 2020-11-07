Shader "Unlit/Test_GlassSSS_00"    //JianpingWang //20200614 //台风雷阵雨又晴
{
    Properties
    {
        _BaseColor("_BaseColor", Color) = (1,1,1,1)

        [NoScaleOffset]
        _matcap ("Matcap", 2D) = "gray" {}

        _BumpScale("BumpScale", Range(0, 1)) = 1
		[NORMAL]_BumpMap ("Normal", 2D) = "bump" {}

		_thickness ("ThicknessMask (RGB)", 2D) = "bump" {}

        _FenierEdge("Fenier Range", Range(-2, 2)) = 0.0
        _FenierIntensity("Fenier intensity", Range(0, 10)) = 2.0

        _Refintensity("_Refintensity", float) = 1

        _SpColor("_SpColor", Color) = (1,1,1,1)

        _Noise ("Noise", 2D) = "gray" {}
        _NoiseScale ("NoiseScale", float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent"  "Queue"="Transparent" "IgnoreProjector"="True"}
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" } 
            
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"			
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal 	 : Normal;
                float4 tangent 	 : Tangent; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 TtoW0 	: TEXCOORD2;
                float4 TtoW1 	: TEXCOORD3;
                float4 TtoW2 	: TEXCOORD4;
                float2 uv2 : TEXCOORD5;
                float2 uv3 : TEXCOORD6;
                fixed4 diff : COLOR0;  
            };

            sampler2D _matcap, _BumpMap, _thickness;
            half4 _BumpMap_ST, _thickness_ST;
            half _BumpScale;
            half _FenierEdge, _FenierIntensity;
            half _Refintensity;
            half4 _BaseColor, _SpColor;
            sampler2D _Noise;
            half4 _Noise_ST;
            half _NoiseScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BumpMap);
                o.uv2 = TRANSFORM_TEX(v.uv, _thickness);
                o.uv3 = TRANSFORM_TEX(v.uv, _Noise);

                half3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal   = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent  = UnityObjectToWorldDir(v.tangent.xyz);                                   
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                o.diff = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz)) * _LightColor0;              
                o.diff.rgb += ShadeSH9(half4(worldNormal, 1));

                return o;
            }

            inline float3 RFLerpColor (in float3 rfmatCap,in float Thickness)
            {
            float3 c1 = _BaseColor.rgb * 0.5;
            float3 c2 = rfmatCap * _BaseColor.rgb;
            float cMask = Thickness;
                return lerp(c1, c2, cMask); //这里也可以 *v.color.rgb 用顶点色来控制玻璃局部色彩，制作出彩色玻璃的效果
            };

            inline float EdgeThickness (in float NoV ,in float eThickness )
            {
            float fThickness = (eThickness - 0.5) * 0.5;
            float ET = saturate((NoV - _FenierEdge + fThickness) * _FenierIntensity);
            return ET * eThickness ;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                fixed4 c = fixed4(1,1,1,1);

                half3 worldPos = half3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                half3 viewDir  = UnityWorldSpaceViewDir(worldPos);
                half3 lightDir = _WorldSpaceLightPos0.xyz;				
                half3 bump     = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
                bump.xy *= _BumpScale;
                bump.z   = sqrt(1.0 - saturate(dot(bump.xy , bump.xy)));
                bump     = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
    						
                
                //反射
                half2 matUV = half2(0,0);
                matUV.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), bump);
                matUV.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), bump);
                matUV   = matUV * 0.5 + 0.5;
                half3 matCapTex = tex2D(_matcap, half2(matUV.x, 1.0 - matUV.y)).rgb;

                half3 noiseTex = tex2D(_Noise, i.uv3).rgb;


                //折射
                half3 thick = tex2D(_thickness, i.uv2).rgb;
                thick = thick + thick * noiseTex.r * _NoiseScale;

                float3 V = normalize(_WorldSpaceCameraPos - worldPos);
                float NoV = dot(bump, V);
                float sThickness = thick.r; //杯体本身实心玻璃部分  thick.r * i.color.r;
                float ET = 1 - saturate((NoV - _FenierEdge) * _FenierIntensity) + sThickness;

                float3 rfmatCap = tex2D(_matcap, half2(matUV.x, 1.0 - matUV.y) + thick.r * _Refintensity);
                float3 rfmatColor= RFLerpColor(rfmatCap, ET);

                c.rgb = rfmatColor + matCapTex * _SpColor;
                // c.rgb *= i.diff.rgb;  
                // c.rgb = thick;

                float alpha = saturate(max(matCapTex.r, ET) * _BaseColor.a);
                
                // c.a = alpha;
                c.a = 1;   //两个版本一个透，一个不透

                return c;
            }
            ENDCG
        }
    }
}






// //MatCap 普通版
// half2 MatCapUV ;
// matCapUV.x = dot(UNITY_MATRIX_IT_MV[0].xyz,v.normal);
// matCapUV.y = dot(UNITY_MATRIX_IT_MV[1].xyz,v.normal);
// matCapUV = matCapUV * 0.5 + 0.5;


// //MatCap 矫正版
// // float3 N = normalize(UnityObjectToWorldNormal(v.normal));
// // float3 viewPos = UnityObjectToViewPos(v.vertex);
//   float2 MatCapUV (in float3 N,in float3 viewPos)
//   {
//     float3 viewNorm = mul((float3x3)UNITY_MATRIX_V, N);
//         float3 viewDir = normalize(viewPos);
//         float3 viewCross = cross(viewDir, viewNorm);
//         viewNorm = float3(-viewCross.y, viewCross.x, 0.0);
//         float2 matCapUV = viewNorm.xy * 0.5 + 0.5;
//         return matCapUV; 
//   }


// //反射
// [HDR]_SpColor("Sp Color", Color) = (1.0,1.0,1.0,1.0)
// //给高光一个单独的色彩来控制反射的色彩与强度
// float3 spmatCap= tex2D(_CapTex,matCapuv);
// spmatCap *=_SpColor.rgb

// o.color.rgb = spmatCap  ;
// o.color.a = spmatCap .r;


//--------------------------------------------------------------------------
// //折射
// float3 thicknessTex= tex2D(_MaskTex, i.uv);
// float sThickness = thicknessTex.r * i.color.r; //杯体本身实心玻璃部分


// //玻璃侧面厚度
// _FenierEdge("Fenier Range", Range(-2, 2)) = 0.0
// _FenierIntensity("Fenier intensity", Range(0, 10)) = 2.0
// //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
// float NoV = dot(N,V);

// float EdgeThickness (in float NoV)
// {
//    float ET = saturate((NoV-_FenierEdge)*_FenierIntensity);
//    return ET;
// }


// //合并折射区域   厚度图加非捏尔
// _FenierEdge("FenierRange", Range(-2, 2)) = 0.0
// _FenierIntensity("Fenierintensity", Range(0, 10)) = 2.0
// //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
// float NoV = dot(N,V);
// float3 thicknessTex= tex2D(_MaskTex, i.uv) ;
// float sThickness = thicknessTex.r * i.color.r; //杯体本身实心玻璃部分
// float fThickness = thicknessTex.g;// 杯体菲尼尔厚度

// float EdgeThickness (in float NoV ,in float eThickness )
// {
//    fThickness = (eThickness -0.5)*0.5;
//    float ET = saturate((NoV-_FenierEdge+fThickness)*_FenierIntensity);
//    return 1-ET*eThickness ;
// }


// //折射混合
// float Refintensity = Thickness*_Refintensity;
// float3 rfmatCap = tex2D(_RfCapTex,matCapuv+Refintensity);
// float3 rfmatColor= RFLerpColor(rfmatCap,Thickness)
// //_BaseColor添加一个自定义的颜色参数，就可以自由控制玻璃本体色彩
// float3 RFLerpColor (in float3 rfmatCap,in float Thickness)
// {
//   float3 c1 = _BaseColor.rgb*0.5;
//   float3 c2 = rfmatCap*_BaseColor.rgb;
//   float cMask = Thickness;
//     return lerp(c1,c2,cMask ); //这里也可以 *v.color.rgb 用顶点色来控制玻璃局部色彩，制作出彩色玻璃的效果
// }


// //制作alpha
// float alpha = saturate(max(spmatCap.r*_SpColor.a ,Thickness)*_BaseColor.a);
// //_SpColor 是给高光颜色单独一个色彩控制项
// //alpha这里的计算是为了可以分别控制高光的透明度，以及整体杯子的透明度
// col.rgb = rfColor+spColor;//反射与折射合并
// col.a = alpha;