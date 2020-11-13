/*****************************
*文件名：DodEyeCore.cginc
*作者：aiya
*时间：2020/3/17
*描述：角色眼睛着色器
******************************/

#include "DodPBSUtils.cginc" 

//顶点着色器输入结构体
struct a2v{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 texcoord : TEXCOORD0;
};

//顶点着色器输出结构体
struct v2f{
	float4 pos : SV_POSITION;	//裁剪空间下的坐标
	float3 wPos : TEXCOORD0;	//世界空间下的坐标
	half3 wNormal : TEXCOORD1;
	half2 uv : TEXCOORD2;
	half2 reflUV : TEXCOORD3;
	//SHADOW_COORDS(4)
};

//材质参数
fixed4 _MainColor;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _MaskTex;
sampler2D _ReflectMatcap;

float _DiffScale;
float _DiffWrap;
float _SpecScale;
float _ReflScale;
float _ShadowScale;

float _SpecOffsetX;
float _SpecOffsetY;

float _FadeAlpha;

/**************************
@功能：Eye顶点着色器
@参数：v，顶点着色器输入结构体
@输出：o，顶点着色器输出结构体
***************************/
v2f vert(a2v v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

	o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.wNormal = UnityObjectToWorldNormal(v.normal);

	float3 normalDir = normalize ( v.normal);
	o.reflUV = float2(dot(normalize( UNITY_MATRIX_IT_MV[0].xyz), normalDir), dot(normalize(UNITY_MATRIX_IT_MV[1].xyz), normalDir)) * 0.5 + 0.5;

	//TRANSFER_SHADOW(o);
	return o;

}

/*******************************
@功能：Eye片元着色器
@参数：i，顶点着色器输出结构体
*******************************/
fixed4 frag(v2f i) : SV_TARGET
{
	half3 lightDir = normalize(UnityWorldSpaceLightDir(i.wPos));
	half3 viewDir = (UnityWorldSpaceViewDir(i.wPos));
	half3 halfDir = normalize(viewDir + lightDir);
	half3 normalDir = normalize(i.wNormal);

	half NdotL = saturate(dot(normalDir, lightDir));
	half NdotH = saturate(dot(normalDir, halfDir));
	half VdotL = dot(viewDir, lightDir);
	
	fixed4 albedo = tex2D(_MainTex, i.uv);
	fixed4 mask = tex2D(_MaskTex, i.uv);//R-Specular, G-EyeColor, B-Reflect, A-Shadow

	#ifdef FADE_ON
	albedo.a = _FadeAlpha;
	#endif

////// Lighting:
	half3 ambient = DOD_LIGHTMODEL_AMBIENT(normalDir) * albedo;

////// Diffuse:
	float wrap = (NdotL + _DiffWrap) / (1 + _DiffWrap);
	float diff = LIGHTCOLOR.rgb * wrap * _DiffScale;

	fixed3 diffColor = diff * albedo * (1 - mask.g);
	fixed3 eyeColor = lerp(diff * albedo, _MainColor, _MainColor.a) * mask.g;
	diffColor = diffColor + eyeColor;
	//shadow
	diffColor *= (1 - mask.a * _ShadowScale);
	
////// Specular:
	float2 uv = i.reflUV + float2(_SpecOffsetX, _SpecOffsetY) * 0.1;
	fixed4 spec = tex2D(_ReflectMatcap, uv) * mask.g ;
	fixed3 specColor =  spec.a * _SpecScale;
		
////// Reflection:
	fixed4 reflMask = tex2D(_ReflectMatcap, i.reflUV);
	half3 reflColor = reflMask.rgb * mask.g * _ReflScale;
	specColor += reflColor;

////// Final:
	fixed4 finalColor = 0;
	finalColor.rgb = diffColor + specColor + ambient;
	finalColor.a = albedo.a;

	return finalColor;
}
