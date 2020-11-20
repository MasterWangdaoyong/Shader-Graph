Shader "Darkgold/Unlit/sample_diffuseLighting"            //漫反射光照（Diffuse Lighting）     20181012
{     
	Properties
	{
		
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		//Tags { "RenderType"="Opaque" }
		Tags { "LightMode"="ForwardBase" }
		//标签为正向
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"
			//用于辅助光照计算
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 diffuseLightingColor : COLOR0;
				//
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//传送地砖大小数据
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				//TRANSFORM_TEX() 函数不怎么明白    10/12/2018


				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float nDotL = dot(worldNormal, _WorldSpaceLightPos0.xyz);
				o.diffuseLightingColor = nDotL * _LightColor0;
				//顶点函数中，通过UnityObjectToWorldNormal获取网格对象在世界坐标中的法线值。接着，
				//通过dot方法得到法线值与世界空间光照坐标的点积值，作为漫反射参考值。然后，
				//将这个漫反射参考值与光照颜色相乘获得光照的漫反射颜色

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 col2 =fixed4 (col.rgb * i.diffuseLightingColor.rgb, 1);
				//fixed3 转换成fixed4     
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col2);
				return col2;
			}
			ENDCG
		}
	}
}
