//20180908 深圳 阴
Shader "Darkgold/Unlit/sample_00"
{     //Unlit 为无光模式
      //纹理的平铺大小属性未能实现
	Properties
	{  //检视面板中属性
		_TintColor("Color",  Color) = (0.5,0.5,0.5,1)
		_Blend_Amount("Blend", Range(0,1)) = 0
		//上面数据是float型数据？   是的
		_MainTex ("FirstTexture", 2D) = "white" {}
		_SecondTex("SecondTexture", 2D) = "white" {}
		
		
		//颜色渐变
		[Header(Color Ramp Sample)]
		//头说明 粗黑体字 Color Ramp Sample   添加一个标签文本
		[NoScaleOffset]     
		_ColorRamp_SampleTexture("RampTexture", 2D) = "white" {}
		//[NoScaleOffset]指的是    没有平铺位移属性可调控
		_ColorRamp_Evaluation("EvaluationPosition", Range(0,1)) = 0.5
		//上面数据是float型数据？待深入学习此类型 range数据

								
		//纹理剔除（Texture Cutout）
		[Header(Cutout Visuals)]
		_Cutout_tex("CutoutTexture", 2D) = "" {}
		_Cutout_value("CutoutValue", Range(0,1)) = 0


		//世界坐标-梯度（World Space - Gradient）
		/*[Header(Gradient Value)]
		_Color_high("HighColor", Color) = (1,1,1,1)
		_Color_low("LowColor", Color) = (1,1,1,1)
		_Gradient_Or("GradientOrigin", float) = 1
		*/

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		//渲染类型为非透明物体
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

		//输入顶点函数的结构体
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};


		//顶点输出到片元输入的结构体
			struct v2f
			{  //数值结构  struct
				float2 uv : TEXCOORD0;
				//UV通道？
				UNITY_FOG_COORDS(1)
					//?
				float4 vertex : SV_POSITION;
				//system value?
				//float3 worldPosition : TEXCOORD1;   错在此，不能跟FOG使用同一通道，修改成2就可以了
			};

			
			sampler2D _MainTex;
			//实例化，调取前面属性里面的变量数值
			float4 _MainTex_ST;
			// 这个是什么意思？  _MainTex_ST    sample textures?    
			float4 _TintColor;
			
			sampler2D _SecondTex;
			float4 _SecondTex_ST;
			
			float _Blend_Amount;
			//?  返回的是数是float?   测试这么写现在是正确的


			sampler2D _ColorRamp_SampleTexture;
			float _ColorRamp_Evaluation;
			//? 返回的是数是float?   测试这么写现在是正确的
			
			sampler2D _Cutout_tex;
			float _Cutout_value;
			
			float4 _Color_high;
			float4 _Color_low;
			float _Gradient_Or;

			//结构体赋值
			v2f vert (appdata IN)
			{     //v2f类
				v2f o;
				//o.worldPosition = mul(unity_ObjectToWorld, IN.vertex);
				//世界坐标-梯度（World Space - Gradient）
				
				o.vertex = UnityObjectToClipPos(IN.vertex);

				o.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				//o.uv = IN.uv;  上为官方写法，下面为简便赋值写法 
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			//调用结构体数据到片元函数
			fixed4 frag (v2f i) : SV_Target
			{//片元函数  
				
				// sample the texture
				fixed4 mainTexColor = tex2D(_MainTex, i.uv);   //tex2D有点感觉就相当于数值转换   int 转到float    把2D图形数据转换成了float4？
				fixed4 SecondTexColor = tex2D(_SecondTex, i.uv);
				fixed4 endColor = lerp(mainTexColor, SecondTexColor, _Blend_Amount);
				//两张贴图混合    lerp(sample2D, sample2D, float)   待深入学习此函数
								
				//你们写的float2 positionOnRampTex = float2(_ColorRamp_Evaluation, 0.5);
				//我自己的测试，可用float positionOnRampTex = _ColorRamp_Evaluation;
				//float 传递给float 不如直接给上，这样节省了一个创建变量名，效率应该会更好，不太明白tex2D的重载，可能存在多种方法，也可能存在
				//隐式转换？
				//你们写的fixed4 endColor2 = tex2D(_ColorRamp_SampleTexture, positionOnRampTex);
				fixed4 setColorRamp = tex2D(_ColorRamp_SampleTexture, _ColorRamp_Evaluation);
				//我自己的测试，可用
				fixed4 endColor2 = endColor * setColorRamp;

								
				//纹理剔除（Texture Cutout）
				fixed4 cutoutTexColor = tex2D(_Cutout_tex, i.uv);
				//你们写的float4
				clip(cutoutTexColor.rgb - _Cutout_value);
				//clip()  ???   不怎么明白


				//世界坐标-梯度（World Space - Gradient）
				//float4 gradientColor = lerp(_Color_low, _Color_high, i.worldPosition.y * _Gradient_Or);
				//float4 endColor3 = endColor2 * gradientColor;

				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, endColor2);

				return endColor2 * _TintColor;
				//整体的色彩输入  _TintColor个人从美术制作人员角度来说最好是放在最后
				//也不知道在图形学里面是不是对色彩的乘法（色彩的叠加效果）数据是不是对的
			}
			ENDCG
		}
	}
}
