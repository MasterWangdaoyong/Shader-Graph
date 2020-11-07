/*****************************
*文件名：DodPBSCore.cginc
*作者：aiya
*时间：2020/2/10
*描述：角色PBR材质着色器
******************************/

#include "DodPBSUtils.cginc"

//顶点着色器输入结构体
struct a2v{
	float4 vertex : POSITION;
    float4 tangent : TANGENT;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
};

//顶点着色器输出结构体
struct v2f{
	float4 pos : SV_POSITION;	//裁剪空间下的坐标
	float3 wPos : TEXCOORD0;	//世界空间下的坐标
	half3 wTangent : TEXCOORD1;
	half3 wBinormal : TEXCOORD2;
	half3 wNormal : TEXCOORD3;
	half4 uv : TEXCOORD4;
	SHADOW_COORDS(5)
};

//材质参数
sampler2D _MainTex;
float4 _MainTex_ST;
float _DiffScale;
float _DiffWrap;
sampler2D _BumpTex;
float4 _BumpTex_ST;
sampler2D _MaskTex;
float _Smoothness;
float _ReflectScale;
float _SpecScale;
float _EmissScale;
float _EmissGloss;
fixed4 _RimColor;
float _RimBias;
float _RimScale;
float _ToonScale;
float _AttenScale;

/**************************
@功能：PBS顶点着色器
@参数：v，顶点着色器输入结构体
@输出：o，顶点着色器输出结构体
***************************/
v2f vertPBS(a2v v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
	o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;

	//TBN矩阵
	TRANSFER_TANGENTTOWORLD(o, v);

	//阴影计算
	TRANSFER_SHADOW(o);

	return o;
}

/*******************************
@功能：PBS片元着色器
@参数：i，顶点着色器输出结构体
*******************************/
fixed4 fragPBS(v2f i) : SV_Target
{
	half3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(i.wPos));
	half3 halfDir = normalize(viewDir + lightDir);

	//将法线从切线空间转换到世界空间中
	half3 tNormal = UnpackNormal(tex2D(_BumpTex, i.uv.zw));
	half3 normalDir = GetWorldNormal(tNormal, i.wTangent, i.wBinormal, i.wNormal);

	//变量的预计算
	half NdotL = max(0, dot(normalDir, lightDir));
	half NdotH = max(0, dot(normalDir, halfDir));
	half NdotV = max(0, dot(normalDir, viewDir));
	half LdotH = max(0.32h, dot(lightDir, halfDir));

	fixed3 albedo = tex2D(_MainTex, i.uv.xy);

	//R-Metallic, G-Emission, B-Skin, A-Roughness
	fixed4 mask = tex2D(_MaskTex, i.uv.xy);

//////// Lighting:
	half atten = SHADOW_ATTENUATION(i);
	half3 ambient = DodVertexGIForward(normalDir);

/////// Diffuse:
	half wrap = (NdotL + _DiffWrap) / (1 + _DiffWrap);
	half diffBody = NdotL * atten;
	half diffSkin = lerp(_AttenScale, 1, wrap) * atten;	//HACK:用于单独计算皮肤部分的漫反射系数
	diffSkin = max(diffSkin, _AttenScale);	

	//直接光照的漫反射部分：身体 + 皮肤 区分计算
	half3 directDiff = _LightColor0.rgb * (diffBody * (1 - mask.b) + diffSkin * mask.b);

	//间接光照的漫反射部分直接使用环境光照
	half3 indirectDiff = ambient;
	half3 diffuse = (directDiff + indirectDiff) * _DiffScale;
		
	//计算皮肤部分toon效果
	half3 tmpColor = albedo * diffuse * (1 - mask.r);
	half3 toonColor = ToonEffect(tmpColor);
	toonColor = lerp(1, toonColor, _ToonScale);

	//漫反射颜色
	fixed3 diffColor = tmpColor * (1 - mask.b) + tmpColor * mask.b * toonColor;
	
/////// Specular:
	float smoothness = (1 - mask.a) * _Smoothness;
	float roughness = GetRoughness(smoothness);
	float specTerm = GGX_Specular(NdotL, NdotV, NdotH, roughness);
	float3 specColorm = lerp (half3(0.220916301, 0.220916301, 0.220916301), albedo, mask.r);

	//高光颜色
	fixed3 specColor = specTerm * _LightColor0.rgb * FresnelTerm(specColorm, LdotH);

/////// Reflection:
	half3 reflUVW = reflect(-viewDir, normalDir);
	fixed3 indirectSpec = GetReflectIndirectSpecular(reflUVW, roughness);
	fixed3 reflColor = indirectSpec * albedo * mask.r * _ReflectScale;
	//反射部分直接加到高光上
	specColor += reflColor;

/////// Rim:
	half cosA = saturate(_RimBias + NdotV);
	half rimFresnel = DodFresnelLerpFast(cosA);

	//边缘光颜色
	fixed3 rimColor = albedo * _RimColor * rimFresnel * _RimScale;

/////// Emission:
	fixed3 emiss = albedo * mask.g;

	//自发光颜色
	fixed3 emissColor = pow(emiss, _EmissGloss) * _EmissScale;

////// Final:
	fixed4 finalColor = (fixed4)1.0;
	finalColor.rgb = diffColor + specColor + rimColor + emissColor;
	return finalColor;
}