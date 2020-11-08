//20200613 开始分析  JianpingWang 于深圳 台风混暑午的太阳    //mian = JianpingWang
//20200726 再次分析
//20201108 小查看
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "DodFog.cginc"

#define PI 3.1415926535897932384626433832795   //定义派值，圆周率
#define Dod_ColorSpaceDielectricSpec half4(0.04, 0.04, 0.04, 1.0 - 0.04)  //入射角标准介质反射率系数
															//alpha = 0.96
#define Dod_ShadowRange 0.35	//自定义变量值

half3 G2L(half3 value)      //Gamma转linear  //常用标准版，性能会消耗高些 
{
	#if defined(LINEARCOLOR)
		return value * value;   //如果有定义LINEARCOLOR，就返回 pow(x, 2)到拟类线性
	#else
		return value;		//否则返回原样
	#endif
}

half3 L2G(half3 value)		//linear转Gamma
{
	#if defined(LINEARCOLOR)
		return pow(value,half3(0.5,0.5,0.5));  //如果有定义LINEARCOLOR，就返回 pow(x, 0.5)到伽玛
	#else
		return value;  		//否则返回原样
	#endif
}

half3 G2Lsrgb(half3 srgb)	//pow(x,2)拟函数，优化版
{
	#if defined(LINEARCOLOR)	//如果有定义LINEARCOLOR，就返回 pow(x, 2)到线性   //优化版，高性能，拟函数 
		return srgb * (srgb * (srgb * 0.305306011 + 0.682171111) + 0.012522878);
	#else
		return srgb;		//否则返回原样
	#endif
}

struct appdate
{
    float4 vertex : POSITION;
	float3 normal : NORMAL;
    float2 texcoord : TEXCOORD0;
	float2 texcoord2 : TEXCOORD1;
	fixed4 color : COLOR;
	#if defined(NORMAL_ON)
		float4 tangent   : TANGENT;
	#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 pos : SV_POSITION;
	float3 worldNormal : TEXCOORD0;
	float3 worldPos : TEXCOORD1;
    float2 uv : TEXCOORD2;
	DOD_FOG_COORDS(3)
	#ifdef LIGHTMAP_ON
		float2 uvLM : TEXCOORD4;
	#endif
	float3 viewDir : TEXCOORD5;
	#if defined(SHADOW_ON)		//阴影，这里指的是配合角色阴影。像只给地面shader等等
		SHADOW_COORDS(13)	
	#endif
	#if defined(NORMAL_ON)		//法线
		float3 tangent   : TEXCOORD6;
		float3 binormal : TEXCOORD7;
	#endif
	#if defined(TERRAIN)     //地形
		float2 tc_Control : TEXCOORD8;
		float2 tc_Splat0 : TEXCOORD9;
		float2 tc_Splat1 : TEXCOORD10;
		float2 tc_Splat2 : TEXCOORD11;
		float2 tc_Splat3 : TEXCOORD12;
	#endif
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

	sampler2D _MainTex;
	sampler2D _NormalTex;
	sampler2D _MaskTex;
	float4 _MainTex_ST;
	float _Metallic;
	float _roughness;
	float _Emission;
	half4 _EmissionColor;
	float4 _MainColor;
	#if defined(TERRAIN)  //地形的定义
		sampler2D _Splat0;
		sampler2D _Splat1;
		sampler2D _Splat2;
		sampler2D _Splat3;
		sampler2D _Control;
		float4 _Splat0_ST,_Splat1_ST,_Splat2_ST,_Splat3_ST,_Control_ST;
	#endif
	#if defined(CUTOFF)
		half _Cutoff;
	#endif

float FadeShadows (float3 wordposi, float attenuation) //阴影  待深入学习
{
    #if HANDLE_SHADOWS_BLENDING_IN_GI
        float viewZ =dot(_WorldSpaceCameraPos - wordposi, UNITY_MATRIX_V[2].xyz);
        float shadowFadeDistance =UnityComputeShadowFadeDistance(wordposi, viewZ);
        float shadowFade = UnityComputeShadowFade(shadowFadeDistance);
        attenuation = saturate(shadowFade+attenuation);
    #endif
    return attenuation;
}

half OneMinusReflectivityFromMetallicDod(fixed metallic)
{		//Dod_ColorSpaceDielectricSpec = half4(0.04, 0.04, 0.04, 1.0 - 0.04)
    fixed A = Dod_ColorSpaceDielectricSpec.a;
    return A - metallic * A;      //假设metallic为1  那么结果就是 0.96 － 0.96 ＝ 0   如果为0 那么结果就是 0.96    取反并利用声明定义限制参数的范围
	// return 0.96 - metallic * 0.96;  //取反 最大数不为1，为0.96， 最小数取0
}

v2f SceneVert (appdate v)
{
    v2f o;

	UNITY_INITIALIZE_OUTPUT(v2f,o);
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

	o.pos = UnityObjectToClipPos(v.vertex);		//顶点位置转换到裁剪屏幕空间，传进片元
	o.worldNormal = UnityObjectToWorldNormal(v.normal);  //把模型空间法线转换到世界空间
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; //模型顶点信息转换到世界空间内
	o.viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);   //摄相机向量
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  //UV

	#if defined(NORMAL_ON)  //实现一个自定义转法线矩阵   把切线空间下的法线贴图转到世界空间下
		half4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);
		float3x3 tangentToWorld = CreateTangentToWorldPerVertex(o.worldNormal, tangentWorld.xyz, tangentWorld.w);
		o.tangent = tangentToWorld[0];
		o.binormal = tangentToWorld[1];
	#endif

	#ifdef LIGHTMAP_ON  //UV
		o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#endif

	#if defined(TERRAIN)  //地形
		o.tc_Control = TRANSFORM_TEX(v.texcoord, _Control);
		o.tc_Splat0 = TRANSFORM_TEX(v.texcoord,_Splat0);
		o.tc_Splat1 = TRANSFORM_TEX(v.texcoord,_Splat1);
		o.tc_Splat2 = TRANSFORM_TEX(v.texcoord,_Splat2);
		o.tc_Splat3 = TRANSFORM_TEX(v.texcoord,_Splat3);
	#endif

	#if defined(SHADOW_ON)
		TRANSFER_SHADOW(o);  //阴影
	#endif
	DOD_TRANSFER_FOG(o.fogCoord, v.vertex);   //雾气
    return o;
}


half3 DiffuseAndSpecularFromMetallicDod (half3 albedo, float metallic , out half3 specColor)   //跟官方一模一样
{
    specColor = lerp(Dod_ColorSpaceDielectricSpec.rgb, albedo, metallic);
    fixed oneMinusReflectivityDod = OneMinusReflectivityFromMetallicDod(metallic);
    return albedo * oneMinusReflectivityDod;
}

// inline half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
// {
//     specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
//     oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
//     return albedo * oneMinusReflectivity;
// }



float SmithJointGGXVisibilityTermDod (float NdotL, float NdotV, float roughness)   //跟官方有些不一样
{
    float a = roughness;
//	half k = (a*a)/8.0;
    float lambdaV = NdotL * (NdotV * (1.0 - a) + a);
    float lambdaL = NdotV * (NdotL * (1.0 - a) + a);

    return min(0.5 / (lambdaV + lambdaL + 1e-5), 128.0);		//此处不一样
}
// 后面的调用
// float a2 = roughness * roughness;
// float visTerm = SmithJointGGXVisibilityTermDod( ndl, ndv, a2);
	
// Ref: http://jcgt.org/published/0003/02/03/paper.pdf   
// inline float SmithJointGGXVisibilityTerm (float NdotL, float NdotV, float roughness)  //官方的
// {
// #if 0
//     // Original formulation:
//     //  lambda_v    = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5f;
//     //  lambda_l    = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5f;
//     //  G           = 1 / (1 + lambda_v + lambda_l);

//     // Reorder code to be more optimal
//     half a          = roughness;
//     half a2         = a * a;

//     half lambdaV    = NdotL * sqrt((-NdotV * a2 + NdotV) * NdotV + a2);
//     half lambdaL    = NdotV * sqrt((-NdotL * a2 + NdotL) * NdotL + a2);

//     // Simplify visibility term: (2.0f * NdotL * NdotV) /  ((4.0f * NdotL * NdotV) * (lambda_v + lambda_l + 1e-5f));
//     return 0.5f / (lambdaV + lambdaL + 1e-5f);  // This function is not intended to be running on Mobile,
//                                                 // therefore epsilon is smaller than can be represented by half
// #else
//     // Approximation of the above formulation (simplify the sqrt, not mathematically correct but close enough)
//     float a = roughness;
//     float lambdaV = NdotL * (NdotV * (1 - a) + a);
//     float lambdaL = NdotV * (NdotL * (1 - a) + a);

// #if defined(SHADER_API_SWITCH)
//     return 0.5f / (lambdaV + lambdaL + 1e-4f); // work-around against hlslcc rounding error
// #else
//     return 0.5f / (lambdaV + lambdaL + 1e-5f);
// #endif

// #endif
// }





float GGXTermNotN (float NdotH, float roughness)		//跟官方有些不一样
{
    float a2 = roughness * roughness;
    float d = (NdotH * a2 - NdotH) * NdotH + 1.0; 
    return min(a2 / (d * d + 1e-5), 128.0);    //此处不一样
}

// float a2 = roughness * roughness;
// float normTerm = GGXTermNotN(ndh, a2);

// inline float GGXTerm (float NdotH, float roughness)  //官方
// {
//     float a2 = roughness * roughness;
//     float d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
//     return UNITY_INV_PI * a2 / (d * d + 1e-7f); // This function is not intended to be running on Mobile,
//                                             // therefore epsilon is smaller than what can be represented by half
// }



//specularColor = lerp (0.04, baseColor, metallic);  //unity_ColorSpaceDielectricSpec = half4(0.04, 0.04, 0.04, 1.0 - 0.04)
//FresnelTermCustom(specularColor, ldh);
float3 FresnelTermCustom (float3 F0, float cosA)   //跟官方有些不一样
{
    float t = Pow5 (1.0 - cosA);   
    return F0 + (float3(1.0,1.0,1.0)-F0) * t;  //此处不一样
}

// inline half3 FresnelTerm (half3 F0, half cosA)  //官方
// {
//     half t = Pow5 (1 - cosA);   // ala Schlick interpoliation
//     return F0 + (1-F0) * t;
// }


//specular =  SpecularBRDF(max(0.0,dot(normalDir, lightDir)), ndv, ndh, ldh, roughness, specularColor) * LightmapDir.a;
//specularColor = lerp (0.04, baseColor, metallic);  //unity_ColorSpaceDielectricSpec = half4(0.04, 0.04, 0.04, 1.0 - 0.04)
float3 SpecularBRDF(float ndl, float ndv, float ndh, float ldh, float roughness, float3 specularColor)
{
    float a2 = roughness * roughness;
    float visTerm = SmithJointGGXVisibilityTermDod( ndl, ndv, a2);
    float normTerm = GGXTermNotN(ndh, a2);
    return visTerm * normTerm * FresnelTermCustom(specularColor, ldh);
}




half3 pbrLightmapTmp(half3 finalcolor)
{
	half3 colorT = half3(0.0,0.0,0.0);
		#if defined(DOD_PLATFORM_PC)
			colorT = finalcolor/(half3(0.78,0.78,0.78)+finalcolor)*1.165;
		#elif defined(DOD_PLATFORM_MOBILE) 
			return L2G(finalcolor);
		#endif
	return colorT;
}


half3 DodDecodeHDR (half4 data, bool useAlpha, half scale)
{
	half alpha = useAlpha ? data.a : 1.0;
	return (scale * alpha) * data.rgb;
}

half3 GetReflectIndirect(half3 worldRefl, half roughness)// IBL  image based lighting  环境反射  待深入研究？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
{	
	half mip = roughness * UNITY_SPECCUBE_LOD_STEPS;
	// UNITY_SPECCUBE_LOD_STEPS ＝ 6  常数为6


	//half3 worldRefl = reflect(-viewDir, normalDir); 
	half4 rgbm = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, mip);
	//UNITY_SAMPLE_TEXCUBE_LOD LOD采样 模糊化
	//unity_SpecCube0 ？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
	half3 specular = DodDecodeHDR(rgbm, unity_SpecCube0_HDR.w == 1, unity_SpecCube0_HDR.x);
	//DodDecodeHDR ？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
	return specular * (1-roughness);
}

// half3 GrassLight(half3 lightmapColor, half3 baseColor,half3 worldNormal,half shadow)
// {
// 	half3 finalColor = half3(0.0,0.0,0.0);
// 	baseColor =G2L( baseColor);
// 	lightmapColor.rgb =clamp( (lightmapColor.rgb),half3(0.287,0.287,0.287),half3(0.55,0.55,0.55));
// 	half3 diffuse = (clamp(shadow+0.135 ,0.1,1.0)) * baseColor;
// 	diffuse = baseColor *(clamp(shadow+0.335 ,0.0,1.0));
// 	return  diffuse;
// }

//half3 GetLightmapIndirect(half3 indrect)
//{
//	#if defined (UNITY_HARDWARE_TIER3) || defined (UNITY_HARDWARE_TIER2)
//		return clamp(G2Lsrgb(indrect),fixed3(0.28,0.28,0.28),fixed3(3.0,3.0,3.0));
//	#elif defined (UNITY_HARDWARE_TIER1)
//		return indrect;
//	#endif
//}

half3 PbrLight(float3 worldPos, half3 lightDir,half4 LightmapDir, half3 viewDir, half3 normalDir, half3 baseColor, half3 PbrMask)
{
	half3 finalColor = half3(0.0,0.0,0.0);  //变量声明，并初始化

	half roughness = PbrMask.b;  //赋值
	half metallic = PbrMask.r;   //赋值
	baseColor = G2L(baseColor);  //转线性，高消耗，拟函数

	half3 specularColor = half3(1.0,1.0,1.0);  //变量声明，并初始化
	//lightmap版本 basecolor
	half3 albedo = DiffuseAndSpecularFromMetallicDod(baseColor, metallic, specularColor); //baseColor为线性基础贴图， metallic为基础金属贴图， specularColor为重赋值(output)
	//函数返还为albedo颜色 (PBR albedo部分)
	//specularColor = lerp (0.04, baseColor, metallic);  //unity_ColorSpaceDielectricSpec = half4(0.04, 0.04, 0.04, 1.0 - 0.04)


	half ndv = abs(dot(normalDir, viewDir));  //绝对值，负数也取正  
	half3 viewReflectDir = reflect(-viewDir, normalDir);  //反射
	half3 halfDir = normalize(viewDir + lightDir); 
	half ndh = clamp(dot(normalDir, halfDir),0.0,1.0);
	half ldh =clamp(dot(lightDir, halfDir),0.0,1.0);
	half nl =clamp(dot(lightDir, normalDir),0.0,1.0);
	LightmapDir.rgb = G2L(LightmapDir.rgb);  //线性转换

	//PBR BRDF diffuse部分
	half3 diffuse = albedo * nl * LightmapDir.a * _LightColor0 * 2.0 + lerp( albedo * LightmapDir, albedo * LightmapDir * LightmapDir.a, Dod_ShadowRange);
		//          基础贴图 *  lambert * 阴影 * 太阳光颜色 * 2 + 混合（ 基础贴图 * lightmap , 基础贴图 * lightmap * 阴影， 0.35）
		//          实时部分 * 阴影 + LightMap部分 * 阴影        
		//          LightmapDir.a = 阴影 ＝ fixed backatten = UnitySampleBakedOcclusion(i.uvLM,worldPos);   //获取lightmap阴影，前提是mix灯光的shadowmask属性
  

	//PBR BRDF 高光部分
	half3 specular = half3(0.0, 0.0, 0.0);   //变量声明，并初始化
	specular =  SpecularBRDF(max(0.0,dot(normalDir, lightDir)), ndv, ndh, ldh, roughness, specularColor) * LightmapDir.a;
	//specularColor = lerp (0.04, baseColor, metallic);  //unity_ColorSpaceDielectricSpec = half4(0.04, 0.04, 0.04, 1.0 - 0.04)
	//SpecularBRDF * 阴影
		
	half3 reflectColor = GetReflectIndirect(viewReflectDir, roughness) * roughness;
		
	finalColor = diffuse + specular + reflectColor;
		
	return finalColor;
}

half3 PbrTerrainLight(float3 worldPos, half3 lightDir,half4 LightmapDir, half3 viewDir, half3 normalDir, half3 baseColor, half3 PbrMask)
{
	half3 finalColor = half3(0.0,0.0,0.0);  //变量声明，并初始化

	half roughness = PbrMask.b; //赋值
	half metallic = PbrMask.r;  //赋值
	baseColor = G2L(baseColor); //转线性，高消耗
	half3 specularColor = half3(1.0,1.0,1.0); //变量声明，并初始化
	//lightmap baseColor
	baseColor = DiffuseAndSpecularFromMetallicDod(baseColor, metallic, specularColor); //函数调用
	half ndv = abs(dot(normalDir,viewDir)); //？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？
	half3 halfDir = normalize(viewDir + lightDir); //blinnphong 光照模型
	half ndh = clamp(dot(normalDir,halfDir),0.0,1.0);  //blinnphong 光照模型
	half ldh =clamp(dot(lightDir,halfDir),0.0,1.0); //blinnphong 光照模型
	half nl =clamp(dot(lightDir,normalDir),0.0,1.0);//lambert 光照模型
	LightmapDir.rgb = G2L(LightmapDir.rgb); //把lightmap转到线性空间
	half3 diffuse;
	diffuse = baseColor * nl * LightmapDir.a*_LightColor0*2.0 + lerp( baseColor * LightmapDir,baseColor * LightmapDir * LightmapDir.a , Dod_ShadowRange);
	//          基础贴图 * lambert * 阴影 * 太阳光颜色 * 2 + 混合（基础贴图 * lightmap, 基础贴图 * lightmap * 阴影， 0.35）
	//SPECULAR
	half3 directSpecular = half3(0.0,0.0,0.0);  //变量声明，并初始化
	directSpecular =  SpecularBRDF(max(0.0, dot(normalDir,lightDir)), ndv, ndh, ldh, roughness, specularColor) * LightmapDir.a;
					//函数调用，    lambert光照模型 
	half3 specular = clamp( directSpecular,0.0,1.0);	//变量声明，并指定高光光照
	finalColor = diffuse + specular;	//lambert + 高光
	return finalColor;
}

half3 simpleLight(half3 LightmapDir, half3 baseColor, half shadow)
{
	half3 finalColor = half3(0.0,0.0,0.0);  //初始化
	baseColor = G2L(baseColor);				//数据转换，如果有定义LINEARCOLOR，就返回 pow(x, 2)到线性
	LightmapDir.rgb = G2L(LightmapDir.rgb);	 //数据转换，如果有定义LINEARCOLOR，就返回 pow(x, 2)到线性
	half3 diffuse;
	LightmapDir *= 0.8;    //？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？？   待测试
	diffuse = LightmapDir * baseColor + LightmapDir * baseColor * shadow;     //lightmap + 阴影叠加
	finalColor = diffuse;
	return finalColor;
}

half3 simpleLight(half3 LightmapDir, half3 baseColor, half shadow, fixed nl)
{
	half3 finalColor = half3(0.0,0.0,0.0);  //初始化
	baseColor = G2L(baseColor);   //数据转换，如果有定义LINEARCOLOR，就返回 pow(x, 2)到线性
	LightmapDir.rgb = G2L(LightmapDir.rgb);   //数据转换，如果有定义LINEARCOLOR，就返回 pow(x, 2)到线性
	half3 diffuse;   		//变量声明
		#if defined(LINEARCOLOR)
			diffuse = baseColor * shadow * _LightColor0 * 2.0 * nl + lerp( baseColor * LightmapDir , baseColor * LightmapDir * shadow, Dod_ShadowRange);
			//          基础贴图 * 阴影 * 太阳光颜色 * 2倍 * lambert + 混合（ 基础贴图 * lightmap , 基础贴图 * lightmap * 阴影， 0.35)
		#else
			diffuse = baseColor * shadow * _LightColor0 * nl + lerp( baseColor * LightmapDir, baseColor * LightmapDir * shadow, Dod_ShadowRange);
			//          基础贴图 * 阴影 * 太阳光颜色 * lambert + 混合（ 基础贴图 * l ightmap ,   基础贴图 * lightmap * 阴影    ， 0.35)
		#endif
	finalColor = diffuse; //指定赋值
	return finalColor; //返回
}

fixed4 SceneFrag (v2f i) : SV_Target
{
	half4 col = tex2D(_MainTex, i.uv);    //基础贴图采样
	half3 worldPos = normalize(i.worldPos);  //归一化世界坐标
	col *= _MainColor;   //基础贴图乘基础颜色

	#if defined(CUTOFF)
		clip(col.a - _Cutoff);   //透明剔除
	#endif
	
	#if defined(TRANSPARENT)     
	col.a = col.a * _MainColor.a;   //透明混合
	#endif

	half4 mask = tex2D(_MaskTex,i.uv);     //mask贴图采样   //MASK图的G通道控制自发光

	#if defined(MIDLIGHT_ON) || defined(PRSLIGHT_ON)
		half3 worldNormal = normalize(i.worldNormal);	//顶点法线信息，归一化			
		half3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));    //太阳光方向失量，归一化		
		half3 ndl = max(0.0,dot(worldNormal,worldLightDir));     //lanbert光照         
		half3 viewDir = normalize(i.viewDir);				//摄相机到顶点的失量，归一化
	#endif

	#if defined(NORMAL_ON) 			
		float3x3 tangentTransform = float3x3(i.tangent, i.binormal, worldNormal);   //切线转到世界的变换矩阵
		half3 normalLocal = UnpackNormal(tex2D(_NormalTex, i.uv));		//解法线数据
		half3 normalMapDir = normalize(mul(normalLocal, tangentTransform));			//把切线空间下的法线转换到世界坐标下
	#endif		

	#if defined(TERRAIN)
		fixed4 splat_control = tex2D (_Control, i.tc_Control).rgba;		//地形系统
		fixed3 lay1 = tex2D (_Splat0, i.tc_Splat0);    //贴图一
		fixed3 lay2 = tex2D (_Splat1, i.tc_Splat1);	   //贴图二
		fixed3 lay3 = tex2D (_Splat2, i.tc_Splat2);		//贴图三
		fixed3 lay4 = tex2D (_Splat3, i.tc_Splat3);		//贴图四
		col.rgb = (lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a);  //四图混合
	#endif

	#ifdef LIGHTMAP_ON	
		half4 lm ;    //变量声名
		half4 indirectColor;   //变量声名
		indirectColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);  //lightmap原始数据，HDR空间，非Decode。？？？？？？？？？？？？？？？？？？？？？？？？？？？？待深入理解
		lm = indirectColor * 2.0;	//HDR数据再乘上2倍
		fixed backatten = UnitySampleBakedOcclusion(i.uvLM,worldPos);   //获取lightmap阴影，前提是mix灯光的shadowmask属性
		lm.a = backatten;      //把阴影转存到前变量的A通道
		half4 maskRGBA = mask;
		half3 emiss = mask.g*_EmissionColor * _Emission+half3(1.0,1.0,1.0);   //MASK图的G通道控制自发光，并提高1

		#if defined(PRSLIGHT_ON) //高配
			maskRGBA.r = mask.r * _Metallic;   //MASK图的R通道控制金属度
			maskRGBA.b = mask.a * (1-_roughness);   //MASK图的A通道控制粗糙度，并反相
			col.rgb = PbrLight(worldPos, worldLightDir, lm, viewDir, normalMapDir, col.rgb, maskRGBA.rgb);  //函数调取，待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
		#elif defined(MIDLIGHT_ON)  //中配
			col.rgb = simpleLight(lm.rgb, col.rgb, backatten, ndl);  //函数调取 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
		#elif defined(SIMPLELIGHT_ON)	//低配
			col.rgb = simpleLight(lm.rgb, col.rgb, backatten);  //函数调取 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
		#endif

		col.rgb *= emiss;  //混合自发光
	#endif

	fixed4 finalColor = col; //变量声名

	#if defined(SHADOW_ON)  //阴影处理
		fixed shadow = SHADOW_ATTENUATION(i);	//函数调取 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
		shadow = FadeShadows(i.worldPos, shadow); //函数调取 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
		shadow = clamp(shadow, 0.5, 1.0); //把阴影钳取到0.5－1
		finalColor *= shadow;	//阴影混合 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
	#endif

	DOD_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);  ////函数调取 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明

	#ifdef LIGHTMAP_ON
		finalColor.rgb = pbrLightmapTmp(finalColor.rgb);	//函数调取	 待写完，得写清楚，后面要添加上分析说明，待写完，得写清楚，后面要添加上分析说明
	#endif
				
    return finalColor;
}