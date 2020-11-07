
Shader "JianpingWang/Properties"    //属性示例
{
	Properties
		{	
			[Header(PropertiesShow)]          									  //黑粗显示
			[Space(20)] [Header(Texture)]       								  //上下位置空间
			[Normal] _Normal("Normal", 2D) = "white" {}        					  //法线测试
			[NoScaleOffset] _NoScaleOffset("NoScaleOffset", 2D) = "white" {}      //不显示大小和位移
			[HDR] _HDR("HDR",Color) = (1,1,1,1)                                   //HDR颜色
			[Gamma] _Gamma("Gamma",Color) = (1,1,1,1)							  //Gamma颜色
			[KeywordEnum(None, Add, Multiply)] _Overlay("Overlay mode", Float) = 0
			[Enum(UnityEngine.Rendering.BlendMode)] _Blend ("Blend mode", Float) = 1  //透明度混合
			[Enum(One,1,SrcAlpha,5)] _Blend2 ("Blend mode subset", Float) = 1
			[PowerSlider(3.0)] _Shininess ("Shininess", Range (0.01, 1)) = 0.08
			[IntRange] _Alpha ("Alpha", Range (0, 255)) = 100
			[Space] _Prop1 ("Prop1", Float) = 0
			[PerRendererData] _Prop1 ("Prop1", Float) = 0                         //?
			[MaterialToggle] _MaterialToggle("MaterialToggle",Float)=0
			//https://docs.unity3d.com/Manual/SL-Properties.html
		}

	SubShader
	{
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f 
			{
				float4 pos : SV_POSITION;
			};

			v2f vert (appdata_base i)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target 
			{
				return fixed4(1,1,1,1);
			}

			ENDCG
		}
	}


}