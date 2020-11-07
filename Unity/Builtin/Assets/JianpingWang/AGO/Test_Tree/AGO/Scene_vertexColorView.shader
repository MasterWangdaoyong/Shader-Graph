
Shader "JianpingWang/Test/Scene_vertexColorView"    //JianpingWang   //20200202  0528
{
	Properties
	{
		[Toggle]_AO("AO", Float) = 0
		[Toggle]_G("G", Float) = 0
		[Toggle]_B("B", Float) = 0
		[Toggle]_RGB("RGB", Float) = 0
	}
	
	SubShader
	{				
		Tags { "RenderType"="Opaque" }

		Pass
		{			
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM		
			#pragma vertex vert
			#pragma fragment frag	
			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
			};

			float _AO;
			half _G;
			half _B, _RGB;
			
			v2f vert ( appdata v )
			{
				v2f o;
				o.color = v.color;				
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				
				float4 A = float4(i.color.r ,  i.color.r ,  i.color.r , 1.0);
				float4 B = float4(i.color.a ,  i.color.a ,  i.color.a , 1.0);
				float4 lerpA = lerp( A , B , lerp(0.0,1.0,_AO));
				float4 C = float4(i.color.g ,  i.color.g ,  i.color.g , 1.0);
				float4 lerpB = lerp( lerpA , C , lerp(0.0,1.0,_G));
				float4 D = float4(i.color.b ,  i.color.b ,  i.color.b , 1.0);
				float4 finalColor = lerp( lerpB , D , lerp(0.0,1.0,_B));
				finalColor = lerp( finalColor , i.color , _RGB);

				return finalColor;
			}
			ENDCG
		}
	}	
}