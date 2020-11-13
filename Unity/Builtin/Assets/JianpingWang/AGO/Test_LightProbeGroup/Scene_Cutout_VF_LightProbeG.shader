Shader "Dodjoy/Scene/Scene_Cutout_VF_LightProbeG"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}	
		[Toggle(SWING_ON)]_SwingOn("Leaf Swing", float) = 0		
		_Pos("Position",Vector) = (0,0,0,0)
		_Direction("Swing Direction", Vector) = (0,0,0,0)
		_TimeScale("Time Scale", float) = 1
		_TimeDelay("TimeDelay",float) = 1
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5	

    }
    SubShader
    {
        Tags { "RenderType"="TransparetnCutout" 	"Queue" = "AlphaTest"	"IgnoreProjector" = "true"}
		
		Cull Off

        Pass
        {
			Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag   

			#pragma multi_compile_fwdbase
			#pragma multi_compile __ SWING_ON
			#pragma multi_compile SHADOWS_SHADOWMASK;

			#pragma multi_compile DOD_FOG_NONE DOD_FOG_LINEAR DOD_FOG_EXP DOD_FOG_EXP2
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			// #include "CustomFog.cginc"
			#include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord2 : TEXCOORD1;
				fixed4 color : COLOR;  
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
				// CUSTOM_FOG_COORDS(3)
				fixed4 diff : COLOR0;                
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

			fixed3 _FrontColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _Cutoff;
			fixed4 _BackColor;
			fixed _LightScale;
			half4 _Pos;
			half4 _Direction;
			half _TimeScale;
			half _TimeDelay;

            float _xx;


            v2f vert (a2v v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
#ifdef SWING_ON
				half dis = distance(v.vertex, _Pos) * v.color.b;
				half time = (_Time.y + _TimeDelay) * _TimeScale;
				v.vertex.xyz += dis * (sin(time) * cos(time * 2 / 3) + 1) * _Direction.xyz;

#endif
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;                
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                o.diff = max(0, dot(o.worldNormal, _WorldSpaceLightPos0.xyz)) * _LightColor0;              
                o.diff.rgb += ShadeSH9(half4(o.worldNormal,1));

				// CUSTOM_TRANSFER_FOG(o.fogCoord, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldPos = normalize(i.worldPos);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);
				clip(texColor.a - _Cutoff);   
                texColor.rgb *= i.diff;

				// CUSTOM_APPLY_FOG(i.fogCoord, i.worldPos, texColor.rgb); 

                return texColor;
            }
            ENDCG
        }
    }

}
