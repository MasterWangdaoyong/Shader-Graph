
// 2/3  B




#include "Test_cgincA.cginc"   


struct appdata 
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 tangent : TANGENT;
};

struct v2f 
{
    float4 pos : SV_POSITION;
    float3 worldPos : TEXCOORD0;
    half3 worldTangent : TEXCOORD1;
    half3 worldBinormal : TEXCOORD2;
    half3 worldNormal : TEXCOORD3;
    half4 uv : TEXCOORD4;
    
};

sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _BumpMap;
float4 _BumpMap_ST;
 

v2f vert(appdata v)
{
    v2f o;

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    TRANSFER_TANGENTTOWORLD(o, v);

    return o; 
}

fixed4 frag(v2f i) : SV_Target 
{
    half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
	
    half3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
	half3 normalDir = GetWorldNormal(tangentNormal, i.worldTangent, i.worldBinormal, i.worldNormal);

    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;

    fixed3 diffuse = _LightColor0.rgb * max(0, dot(normalDir, lightDir)) * albedo;

    return fixed4(diffuse, 1);
}
