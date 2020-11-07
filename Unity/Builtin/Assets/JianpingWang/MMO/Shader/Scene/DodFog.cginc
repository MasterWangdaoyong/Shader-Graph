
#define DOD_FOG_COORDS(index) float2 fogCoord : TEXCOORD##index;
#define DOD_TRANSFER_FOG DodCalcFogCoord
#define DOD_APPLY_FOG DodApplyFog


uniform float3 _FogColor;
uniform float _HeightControl;
uniform float _SmoothFog;
uniform float _FogStart;
uniform float _FogEnd;
uniform float _FogBlend;

uniform float _SkyboxFogHeight;  //-2到2
uniform float _SkyboxFogSmooth;  //0到1

uniform float3 _SunColor;
uniform float _SunSize;

inline half3 LinearToGamma(half3 RGB)   //无POW   
{
	float3 S1 = sqrt(RGB);
	float3 S2 = sqrt(S1);
	float3 S3 = sqrt(S2);
	float3 sRGB = 0.585122381 * S1 + 0.783140355 * S2 - 0.368262736 * S3;
	return sRGB;
}

// inline half getMiePhase(half eyeCos, half eyeCos2)    //精简版标准米氏
// {
//     half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
//     temp = pow(temp, pow(_SunSize,0.65) * 10);
//     temp = max(temp,1.0e-4); // prevent division by zero, esp. in half precision
//     temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;            
//     return temp;
// }

// Calculates the sun shape 
inline half calcSunAttenuation(half3 vertex)     //太阳形状
{   
	half3 lightPos = _WorldSpaceLightPos0.xyz;
	half3 ray = normalize(mul((float3x3)unity_ObjectToWorld, -1 * vertex));     
	half3 delta = lightPos - (-1 *ray);
	half dist = length(delta);
	half spot = 1.0 - smoothstep(0.0, _SunSize, dist);
	return spot * spot;        
	// half focusedEyeCos = pow(saturate(dot(lightPos, ray)), _SunSizeConvergence);
	// return getMiePhase(-focusedEyeCos, focusedEyeCos * focusedEyeCos);
}

inline half sunAskyAfog(half3 worldPos)  //向太阳方向   //可假散射   //可混合到雾气色
{
	half3 LightDir = normalize(-1 * UnityWorldSpaceLightDir(worldPos));
	half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
	half LDV = dot(LightDir, viewDir);				
	LDV = smoothstep(0, 1, LDV);
	return LDV;
}

inline half3 skyboxFogAndSun(half3 vertex, float3 worldPos, half3 texColor)
{
	half3 suncolor = GammaToLinearSpace(_SunColor);
	half LDV = sunAskyAfog(worldPos);
	half3 c = texColor + LDV * suncolor * 0.8;
	c += suncolor * calcSunAttenuation(vertex);   //太阳形状
	return c;
}



inline void DodCalcFogCoord(inout float2 fogCoord, float3 vertex)
{
	fogCoord = 0;

	#if defined (DOD_FOG_NONE)
		return;
	#endif  

	#if defined(FOG_SKY_BOX)
			fogCoord.y = (vertex.y - _SkyboxFogHeight) / _SkyboxFogSmooth;
			fogCoord.y = saturate(fogCoord.y);			
	#else
		
		half3 viewPos = UnityObjectToViewPos(vertex);
		half3 worldPos = mul(unity_ObjectToWorld, vertex);   
		half z = length(viewPos);						 
		half factor = 0;
		half Yfactor = 0; 
	
		#if defined(DOD_FOG_LINEAR)
			// factor = (end-z)/(end-start) = z * (-1/(end-start)) + (end/(end-start))
			factor = (_FogEnd - z) / (_FogEnd - _FogStart);
			Yfactor = (worldPos.y - _HeightControl) / _SmoothFog; 
		#elif defined(DOD_FOG_EXP)
			factor = 0;
		#elif defined(DOD_FOG_EXP2)
			factor = 0;
		#endif

		fogCoord.x = saturate(factor);
		fogCoord.y = saturate(Yfactor);	

	#endif
}


inline void DodApplyFog(float2 fogCoord, float3 worldPos, inout fixed3 finalColor)  
{
	#if defined (DOD_FOG_NONE)
		return;
	#endif		
	
	#if defined (DOD_FOG_LINEAR)

			fixed3 finalFog = _FogColor;
			fixed3 texColor = finalColor;
			
			half heightContorl = 1.0 - saturate(((worldPos.y - _HeightControl) / _SmoothFog));
			heightContorl = smoothstep(0, 1, heightContorl);
			
			#if defined (DOD_SUN_ON)
				half LDV = sunAskyAfog(worldPos);
				finalFog = lerp(_FogColor, _FogColor * _SunColor + _SunColor, LDV);
			#endif					
			
			fixed3 linearfog1 = lerp(finalColor, finalFog, 1 - fogCoord.x);
			fixed3 heightfog  = lerp(finalColor, finalFog, heightContorl);
			fixed3 linearfog2 = lerp(heightfog, finalColor, fogCoord.x);
			fixed3 lerpHeightLinear = lerp(linearfog2, linearfog1, _FogBlend);	
			finalColor = lerpHeightLinear;

			#if defined (FOG_SKY_BOX)
				finalColor  = lerp(texColor, finalFog, 1 - fogCoord.y);
			#endif 

	#endif
	
}







// ////20200613 开始分析  JianpingWang 于深圳 台风混暑午的太阳    //mian = JianpingWang
// //202007   结束分析  参考资料：
// //自己在ASE里重实现一版，理清算法思路，理清逻辑思路，提升美术效果，又清理又优化。   在美术几位同事反馈下都要比这版要强上很多。

// //需要后面再重做一次原版分析 

// #define DOD_FOG_COORDS(index) float2 fogCoord : TEXCOORD##index;
// //DOD_FOG_COORDS为定义的宏，index为参数；后面说明index参数为float2型，并指出变量名fogCoord是在TEXCOORD空间下，而这个空间也是变动的，index输入参数为##index
// #define DOD_TRANSFER_FOG DodCalcFogCoord
// //DOD_TRANSFER_FOG为定义的宏，DodCalcFogCoord为函数名；用宏调用函数
// #define DOD_APPLY_FOG DodApplyFog
// //DOD_APPLY_FOG为定义的宏，DodApplyFog为函数名；用宏调用函数

// uniform fixed4 _DODFogColor;
// uniform float _DODDepthFogStart;
// uniform float _DODDepthFogEnd;
// uniform float _HeighFogStart;
// uniform fixed4 _HightFogColor;
// uniform float _HeighFogEnd;
// uniform float _DODFogIntensity;

// uniform float _SkyboxFogHeight;
// uniform float _DODSkyboxFogIntensity;
// uniform float3 _DODSunColor;

// uniform float _BlendScale;  //main
// uniform half _SunSize;  //main

  
// //计算雾
// inline void DodCalcFogCoord(inout float2 fogCoord, float3 vertex)  //inout 为传出参数 float2型 变量， float3 vertex指的是顶点的原始数据
// {
// 	fogCoord = 0; //初始化0
// 	#if defined (DOD_FOG_NONE)
// 		return;//如果在shader里定义宏DOD_FOG_NONE，则返回空
// 	#endif

// 	#if defined(FOG_SKY_BOX)
// 		fogCoord.y = vertex.y; //如果在shader里定义宏FOG_SKY_BOX，则返回顶点的Y轴数据为fogCoord的Y
// 	#else
// 		//深度雾
// 		float3 viewPos = UnityObjectToViewPos(vertex); //顶点转换到观查空间
// 		float z = length(viewPos); //计算观查空间中，从摄相机点到的顶点长度（深度）

// 		float factor = 0;//初始化

// 		factor = (_DODDepthFogEnd - z) / (_DODDepthFogEnd - _DODDepthFogStart); //线性雾的基本公式
// 		// factor = (end-z)/(end-start) = z * (-1/(end-start)) + (end/(end-start))  // factor = exp(-density*z) // factor = exp(-(density*z)^2)
// 		fogCoord.x = saturate(factor);  //把计算过后的线性数据钳据到0到1范围内，并指定给fogCoord的X

// 		float3 worldPos = mul(unity_ObjectToWorld, vertex);//顶点的世界坐标
// 		fogCoord.y = worldPos.y;//把顶点的世界坐标的Y值给了fogCoord的Y
// 	#endif
// }

// //混合雾的颜色
// inline void DodApplyFog(float2 fogCoord, float3 worldPos, inout fixed3 finalColor)
// {							//fogCoord为顶点传过来的数据，并且都是已计算过后的。  worldPos为顶点的世界坐标，inout 为最后混后的，经过各种结算后的结果
// 	//此处缺少最先前的初始化？？finalColor ＝ fixed3(0,0,0);
// 	#if defined (DOD_FOG_NONE)
// 		return;//如果在shader里定义宏DOD_FOG_NONE，则返回空
// 	#endif

// 	#if defined(LINEARCOLOR)
// 		_DODFogColor *= _DODFogColor; //如果在shader里定义宏LINEARCOLOR，pow(x,2)近似线性颜色
// 	#endif

// 	_HightFogColor *= _HightFogColor; //pow(x,2)近似线性颜色

// 	float3 worldPosDir = normalize(worldPos);  //归一化世界坐标信息
// 	half3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));  //得到太阳光向量 _WorldSpaceLightPos0.xyz   需重新复习该知识点
// 	half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));    //得到观查向量？！  需重新复习该知识点_WorldSpaceCameraPos.xyz

// 	#if defined (FOG_SKY_BOX)
// 		#if defined (HIGHTFOG) || defined (DOD_SUN_ON)

// 			fixed3 hightfog = fixed3(0.0,0.0,0.0); //初始化
// 			fixed hightY = worldPos.y - _HeighFogStart;
// 			fogCoord.y -= _SkyboxFogHeight/5;
// 			half3 skyDownFog = lerp(_HightFogColor,finalColor,lerp(clamp((fogCoord.y+0.3),0.0,1.0),1.0,1-_DODSkyboxFogIntensity));
// 			// half3 skyfog = lerp(skyDownFog,_DODFogColor, lerp(0.0,(1-smoothstep(0, _SkyboxFogHeight, fogCoord.y<=0.0?abs(fogCoord.y)*2:fogCoord.y)),_DODSkyboxFogIntensity));
// 			half3 skyfog = skyDownFog; //main
// 			#if defined(DOD_SUN_ON)
// 				half vl = (dot(viewDir,-worldLightDir));
// 				skyfog = lerp(skyfog,finalColor,vl);
// 			#endif
// 			finalColor = skyfog;
// 		#endif
// 	#elif defined(DOD_FOG_LINEAR)
// 		// fixed3 fogColor = lerp(_DODFogColor, finalColor, fogCoord.x*fogCoord.x);
// 		// fixed3 finalFog = fogColor;
// 		fixed3 finalFog = finalColor; //main
// 		#if defined(HIGHTFOG)
// 			fixed3 hightfog = fixed3(0.0,0.0,0.0);
// 			fixed hightY = worldPos.y - _HeighFogStart;
// 			// fixed hight = clamp((_HeighFogEnd-hightY)/hightY*1.65,0.0,1.0);
// 			fixed hight = (_HeighFogEnd - hightY) / hightY * _BlendScale; //main
// 			hight = clamp(hight, 0.0, 2.0); //main

// 			// hightfog = lerp(_HightFogColor,finalColor,fogCoord.x*fogCoord.x*fogCoord.x);
// 			// finalFog = lerp(fogColor,hightfog,hight);
// 			hightfog = lerp(_HightFogColor, finalColor, fogCoord.x * fogCoord.x * fogCoord.x);	//main	//高度雾	
// 		#endif
// 		#if defined(DOD_SUN_ON)
// 				half vl = clamp((dot(viewDir,-worldLightDir)),0.0,1.0);
// 				// fixed3 sunfog = lerp((_DODSunColor + finalFog)*vl, finalColor, fogCoord.x*fogCoord.x);
// 				fixed3 sunfog = lerp(hightfog + (_DODSunColor + hightfog) * vl, hightfog, fogCoord.x * fogCoord.x ); //main	//假太阳大气雾效散射
// 				// finalFog = lerp(finalFog,sunfog,smoothstep(0,1,vl));
// 				finalFog = lerp(finalFog, sunfog, hight);  //main
// 		#endif
// 		finalColor = finalFog;

// 	#endif

// }


// ///////////////////////////////////////////////    //main 
// // inline half getMiePhase(half eyeCos, half eyeCos2)    //精简版标准米氏
// // {
// //     half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
// //     temp = pow(temp, pow(_SunSize,0.65) * 10);
// //     temp = max(temp,1.0e-4); // prevent division by zero, esp. in half precision
// //     temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;            
// //     return temp;
// // }

// 	// Calculates the sun shape
// inline half calcSunAttenuation(half3 lightPos, half3 ray)     //太阳形状
// {        
// 	half3 delta = lightPos - ray;
// 	half dist = length(delta);
// 	half spot = 1.0 - smoothstep(0.0, _SunSize, dist);
// 	return spot * spot;        
// 	// half focusedEyeCos = pow(saturate(dot(lightPos, ray)), _SunSizeConvergence);
// 	// return getMiePhase(-focusedEyeCos, focusedEyeCos * focusedEyeCos);
// }
// ///////////////////////////////////////////////