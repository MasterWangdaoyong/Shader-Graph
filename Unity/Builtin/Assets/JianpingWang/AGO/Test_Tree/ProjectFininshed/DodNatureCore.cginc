//20200613 分析  JianpingWang 于深圳 台风混暑午的太阳    //mian = JianpingWang   //NatureTree 最早是我自己写的，但他们有修改。重整理思路看看

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"
#include "DodFog.cginc"

struct a2v
{
    float4 vertex    : POSITION;  
	float3 normal    : NORMAL;
    float2 texcoord  : TEXCOORD0;
	float2 texcoord2 : TEXCOORD1;
	fixed4 color     : COLOR;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float4 pos         : SV_POSITION;
	float3 worldNormal : TEXCOORD0;
	float3 worldPos    : TEXCOORD1;
    float2 uv          : TEXCOORD2;
	DOD_FOG_COORDS(3)
#ifdef LIGHTMAP_ON
	float2 uvLM : TEXCOORD4;
#endif			
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

sampler2D _MainTex;
float4 _MainTex_ST;
half  _Cutoff, _LightmapScale;
half4 _MainColor;
half4 _Direction;
half _TimeScale, _TimeDelay;

v2f Naturevert (a2v v)
{
    v2f o;
	UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

#ifdef SWING_ON
	half dis      = distance(v.vertex, half4(0, 0, 0, 0)) * v.color.b;  
	half time     = (_Time.y + _TimeDelay) * _TimeScale;
	v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;  //main 顶点动画，并且已有优化。缺点：效果太单一。顶点动画效果好的参考官方Boat项目
#endif
	o.pos		  = UnityObjectToClipPos(v.vertex);
	o.worldNormal = UnityObjectToWorldNormal(v.normal);
	o.worldPos	  = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv       	  = TRANSFORM_TEX(v.texcoord, _MainTex);

#ifdef LIGHTMAP_ON
	o.uvLM = v.texcoord2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif	
	DOD_TRANSFER_FOG(o.fogCoord, v.vertex);
    return o;
}

fixed4 Naturefrag (v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	clip(col.a - _Cutoff);
	fixed3 worldNormal   = normalize(i.worldNormal);
	fixed3 worldPos      = normalize(i.worldPos);
	fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
	half Ndl = max(0, dot(worldNormal, worldLightDir) * 0.6 + 0.4);     //main //hack 官方的小优技巧
	half4 indirectColor;				
#ifdef LIGHTMAP_ON
	indirectColor = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM);   //官方解压lightmap， 为什么要乘4倍呢？？？？？？？？？？？？？？？？？？
	half4 lm = indirectColor*4.0;  
#if defined(LINEARCOLOR)
	col.rgb *= col.rgb;    //得到一个近似的pow(x, 2)线性颜色
	lm.rgb *=lm.rgb;	//？？？？？？？？？？？？？？？？？？
#endif
	fixed backatten = UnitySampleBakedOcclusion(i.uvLM,i.worldPos);	//shadowmask属性时的lightmap阴影采样
	col.rgb = (clamp(backatten ,0.2,1.0)) * col.rgb * lm.rgb + _LightColor0.rgb*col.rgb*Ndl;   //取巧性，包含性能优化。但缺少阴影，当物件在阴影交接处理表现欠缺，欠佳。
	//把阴影钳取到0.2到1，去掉太黑的地方；非正常设计处理，解决阴影处死黑，从个人角度来看也并不是很好的解决方法，并且在不同的环境灯光下材质球不能通用。
	//正常一般处理应该是这样 c = c * lm + _LightColor0 * c * ndl * backatten;
	col.rgb *= _MainColor;
#else
	col.rgb = _LightColor0.rgb * col.rgb * Ndl;
#endif
	fixed4 finalColor = col;
	finalColor.a      = col.a;
	DOD_APPLY_FOG(i.fogCoord, i.worldPos, finalColor.rgb);
#if defined(LINEARCOLOR)
	finalColor = pow(finalColor,0.5);    //Gamma
#endif
    return finalColor;
}