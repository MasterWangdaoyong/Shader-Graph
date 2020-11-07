#ifndef SceneItemSSS      //JianpingWang  //20200608
#define SceneItemSSS

#include "UnityCG.cginc"
#include "AutoLight.cginc"			
#include "Lighting.cginc"
#include "DodScenePbsCore.cginc"

sampler2D  _BumpMap, _Thickness, _MatCap;
half _ThicknessScale, _BumpScale, _Shininess;
fixed4 _SubColor, _SpecColora;


struct appdata
{
    float4 vertex 	 : POSITION;
    float2 texcoord  : TEXCOORD0;
    float2 texcoord2 : TEXCOORD1;       
    float3 normal 	 : Normal;
    float4 tangent 	 : Tangent; 
};

struct v2f 
{
    float4 pos  	: SV_POSITION;
    float2 uv 		: TEXCOORD0;    
    #if defined (TIER3andTIER2) 
        float4 TtoW0 	: TEXCOORD2;
        float4 TtoW1 	: TEXCOORD3;
        float4 TtoW2 	: TEXCOORD4;
    #endif
    DOD_FOG_COORDS(6)
    #if defined (LIGHTMAP)
        float2 uvLM : TEXCOORD7;
        float3 worldPos : TEXCOORD1;					
    #endif
};



///////////////////////////////////////////////拟SSS 分级3  		
inline half4 LightingTranslucent3 (half4 Talbedo, half3 SSStex, half Shininess, half3 Normal, half3 lightDir, half3 viewDir, half atten, half4 _SubColor, half4 _SpecColora,  half3 lm, sampler2D _MatCap)
{	
    viewDir 	= normalize ( viewDir );
    lightDir 	= normalize ( lightDir );
    half Thickness = SSStex.g * _ThicknessScale;
    half3 transAlbedo2 = Talbedo.rgb * Thickness * _SubColor.rgb;

    //---------采用matcap  不使用cubemap
    half2 matUV = half2(0,0);
    matUV.x = dot(normalize(UNITY_MATRIX_IT_MV[0].xyz), Normal);
    matUV.y = dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), Normal);
    matUV   = matUV * 0.5 + 0.5;
    half3 matCapTex = tex2D(_MatCap, half2(matUV.x, 1.0 - matUV.y)).rgb;
    //---------				
    half3 matCapColor  = Talbedo.rgb * matCapTex;
    
    half3 h 	= normalize (lightDir + viewDir);
    half  diff 	= max (0, dot (Normal, lightDir));
    half  nh 	= max (0, dot (Normal, h));
    half  spec 	= pow (nh, Shininess*128.0) * Talbedo.a * _SpecColora.rgb;
    half3 diffAlbedo =  Talbedo.rgb * lm  + (Talbedo.rgb * diff  + spec) * _LightColor0.rgb * atten;
    
    half4 c;
    c.rgb 	= diffAlbedo + (transAlbedo2 + matCapColor) * SSStex.r;
    c.rgb  *= _SubColor.a;  //备注：效果调整时如果非SSS区域太暗可放置上面相乘，只控制SSS区域的明暗调节
    c.a 	= 1;

    return c;
}
///////////////////////////////////////////////拟SSS 

///////////////////////////////////////////////拟SSS 分级2  去掉matcap反射  去掉光滑
inline half4 LightingTranslucent2 (half4 Talbedo, half3 SSStex, half3 Normal, half3 lightDir, half atten, half4 _SubColor, half3 lm)
{					
    lightDir = normalize ( lightDir );
    half Thickness = SSStex.g * _ThicknessScale * SSStex.r;			

    half3 	transAlbedo2 = Talbedo.rgb * Thickness * _SubColor.rgb;
    
    half  diff 	= max (0, dot (Normal, lightDir));
    half3 diffAlbedo =  Talbedo.rgb * lm  + (Talbedo.rgb * diff) * _LightColor0.rgb * atten;			
    
    half4 c;
    c.rgb 	= transAlbedo2 + diffAlbedo;
    c.rgb  *= _SubColor.a;
    c.a 	= 1;

    return c;
}
///////////////////////////////////////////////拟SSS 

v2f vert (appdata v) 
{
    v2f o;

    o.uv 	= TRANSFORM_TEX(v.texcoord, _MainTex);
    o.pos 	   = UnityObjectToClipPos(v.vertex);

    #if defined (LIGHTMAP)
        o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    #endif
    
    #if defined (TIER3andTIER2)     
        fixed3 worldNormal   = UnityObjectToWorldNormal(v.normal);  
        fixed3 worldTangent  = UnityObjectToWorldDir(v.tangent.xyz);                                   
        fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
        o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, o.worldPos.x);
        o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, o.worldPos.y);
        o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, o.worldPos.z);
    #endif

    DOD_TRANSFER_FOG(o.fogCoord, v.vertex);

    return o;
}




fixed4 frag (v2f i) : SV_Target  
{
    half4 Albedo = tex2D(_MainTex, i.uv);
    half4 finiColor = Albedo;

    #if defined (TIER3andTIER2) 
        half3 viewDir  = UnityWorldSpaceViewDir(i.worldPos);
        half3 lightDir = _WorldSpaceLightPos0.xyz;				
        half3 bump     = normalize(UnpackNormal(tex2D(_BumpMap, i.uv)));
        bump.xy *= _BumpScale;
        bump.z   = sqrt(1.0 - saturate(dot(bump.xy , bump.xy)));
        bump     = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
    						
        half3 SSStex   = tex2D(_Thickness, i.uv).rgb; 
        													
    #endif

    #if defined (LIGHTMAP)
        half3 lm = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);
        lm = lm * 2;     
        half backatten = UnitySampleBakedOcclusion(i.uvLM, i.worldPos);

        #if defined (TIER3)	
            half4 Talbedo   = half4(G2L(Albedo.rgb), SSStex.b);
            finiColor = LightingTranslucent3 (Talbedo, SSStex, _Shininess, bump, lightDir, viewDir, backatten, _SubColor, _SpecColora, lm, _MatCap);
        #elif defined (TIER2)
            finiColor = LightingTranslucent2 (Albedo, SSStex, bump, lightDir, backatten, _SubColor, lm);				
        #elif defined (TIER1)
            finiColor.rgb = simpleLight (lm, Albedo, backatten) * _SubColor.a;
            finiColor.a = 1;
        #endif

    #endif
    
    #if defined (LIGHTMAP)
        finiColor.rgb = pbrLightmapTmp(finiColor.rgb);	
    #endif
    
    DOD_APPLY_FOG(i.fogCoord, i.worldPos, finiColor.rgb);

    return finiColor;
}



#endif