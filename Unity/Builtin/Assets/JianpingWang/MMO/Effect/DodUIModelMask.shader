Shader "Dodjoy/Effect/DodUIModelMask"
{
	Properties
	{
		_Radius("Radius", Range(0, 0.5)) = 0.1
		_AlphaScale("AlphaScale", Range(0, 1)) = 1		
	}

	SubShader
	{
			Tags
			{
				"Queue" = "Transparent"			 
				"RenderType" = "Transparent"
			}

		  Pass
		  {
				Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				float _AlphaScale;
				float _Radius;				

				struct a2v {
					float4 pos : POSITION;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
				};

				v2f vert(a2v input)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(input.pos);
					o.uv = input.uv;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					//float value = i.uv.y;
					//float ratio = lerp(0, 1, i.uv.y / (1 - _Radius));
					//todo:根据比重来平滑剔除
					return fixed4(1, 1, 1, _AlphaScale);
				}
				ENDCG
	      }		
	}
}