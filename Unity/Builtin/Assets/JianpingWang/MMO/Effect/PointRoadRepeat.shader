Shader "Dodjoy/Effect/PointRoadRepeat"
{
   Properties 
   {
	  _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
      _MainTex ("Texture Image(RGBA)", 2D) = "black" {}
      _FlashTime ("Flash Speed", Range (0.05, 0.3)) = 0.15  
	  _Float ("repeat",float)=2
	  _Float2 ("Move Speed",float)=30
	  _Float3 ("Soft Clip Dis",float)=0.2
   }
   SubShader
   {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	LOD 100
	ZWrite Off
	//ZTest off
	//Blend SrcAlpha OneMinusSrcAlpha
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off
	Lighting Off

      Pass 
      {   
		 Fog { Mode Off }
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         // User-specified uniforms            
         uniform sampler2D _MainTex;   
		 uniform fixed4 _TintColor;
         uniform float _Float;     
         uniform float _Float2;     
         uniform float _Float3;     
		 uniform float _FlashTime;
         struct vertexInput 
         {
            float4 vertex : POSITION;
            float4 tex : TEXCOORD0;
         };
         struct vertexOutput 
         {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            output.pos = UnityObjectToClipPos(input.vertex);
 
            output.tex = input.tex;

 
            return output;
         }
		
		
         float4 frag ( vertexOutput input ):Color
         {
			//取出图片贴到Mesh UV上去,设置重复参数 图片在UV上的流动速度
            //float4 rtc =  tex2D(_MainTex,float2(input.tex.x,input.tex.y * _Float)); //float2(-(input.tex.y* ceil(_Float) + -_Time.x * _Float2),input.tex.x));
            float4 rtc =  tex2D(_MainTex,float2(-(input.tex.y* ceil(_Float) + -_Time.x * _Float2),input.tex.x));
			//实现隔一段时间闪一下的效果
			float num = (fmod(_Time.x,_FlashTime) / (_FlashTime / 2)); 
			rtc.a = abs(step(1,num)*2 - num) * rtc.a;
			//右边Alpha渐变
			rtc.a *= clamp((input.tex.y / _Float3),0,1);
			//左边Alpha渐变
			rtc.a *= clamp(((1 - input.tex.y) / _Float3),0,1);
            return rtc;
         }
 
         ENDCG
      }

   }
   FallBack "Diffuse"
}