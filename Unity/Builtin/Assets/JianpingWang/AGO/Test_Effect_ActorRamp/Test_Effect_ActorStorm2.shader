Shader "JianpingWang/Test_Effect_ActorStorm"       //JianpingWang //角色溶解 //20200407  20200413
{
    Properties
    {    
        [Header(BaseTex)]    
        [NoScaleOffset]
        _MainTex("MainTex(RGB)", 2D) = "white" {}       
        [NoScaleOffset]        
        _NoiseTex("NoiseTex(RGB)", 2D) = "white" {}    //后续优化可使用GB通道来控制Y轴渐变消失方向
        _NoiseScale("NoiseScale", Range( 0.1 , 50)) = 10
        
        [Space(20)][Header(BaseControl)]
        _GLOW ("GLOW", Range(2, 8)) = 2
        _L1Color ("L1-Color(RGB)", Color) = (1,1,1,0)
		// _L2Color ("L2-Color(RGB)", Color) = (0,0,0,0)   
        _Speed ("Time", Range( -2 , 2)) = -0.5

        [Space(10)]
        _YClip ("YClip", Range( 0 , 8)) = 0.8		
		_L1Offset ("L1-Offset", Range( 0 , 1)) = 0.45
		_L2Offset ("L2-Offset", Range( 0 , 0.5)) = 0.4        
		// _OffsetY ("OffsetY", Range( -10 , 30)) = -0.05   //向Y轴拖拉 偏移强度

        [Space(20)][Header(Control)]
		_TranProgress("Tran-Progress", Range( 0 , 1.5)) = 0.7				
    }

    SubShader
    {
        Tags {"RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IgnoreProjector"="True"}
        
		Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 pos : SV_POSITION;
                half worldPosY : TEXCOORD2;
                half4 noiseUV : TEXCOORD3;
                half OffsetPosY : TEXCOORD4;
                half ndl : TEXCOORD5;
            };

            sampler2D _MainTex, _NoiseTex;
            half4 _MainTex_ST,  _NoiseTex_ST;
            fixed4 _L1Color;
            half _TranProgress, _L1Offset, _OffsetY, _L2Offset, _Speed, _YClip, _GLOW, _NoiseScale;

            v2f vert (appdata v)
            {
                v2f o;

                half3 worldPos = mul( unity_ObjectToWorld, v.vertex );
                half3 normal = UnityObjectToWorldNormal(v.normal);
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.ndl = dot(lightDir, normal)* 0.5 + 0.5;

                o.worldPosY = worldPos.y + (-5.0 + _TranProgress * 5.0 );
                // half3 worldOffset = half3(_OffsetY , 0.0 , 0.0);   //向Y轴拖拉 偏移强度
                o.OffsetPosY = saturate( o.worldPosY  + _L1Offset );
                v.vertex.xyz += (o.OffsetPosY * half3(0, 0, 0));                
                o.pos = UnityObjectToClipPos(v.vertex);                
                
                half2 timeSpeed = half2(1.0 , _Time.y * _Speed);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.noiseUV.xy = v.texcoord * _NoiseScale + timeSpeed;                
                half2 worldUV = half2(worldPos.x , worldPos.y);
                o.noiseUV.zw = v.texcoord * _NoiseScale + (worldUV + timeSpeed);

                return o;
            }
           

            fixed4 frag (v2f i) : SV_Target
            {
                half4 noiseTex = 1.0 - ( tex2D(_NoiseTex, i.noiseUV.xy) * _YClip ) * tex2D( _NoiseTex, i.noiseUV.zw );

                half Offset2 = saturate( i.OffsetPosY + _L2Offset );
                half4 alphaClip = (1.0 - ( noiseTex * Offset2 )) * ( 1.0 - saturate( i.worldPosY ) ) ;
                clip(alphaClip.r - 0.5 ); 
                
                // half4 L2Color = _L2Color * Offset2;  //第二层颜色计算方法还有点小问题  待优化
                half4 L1Color = _L1Color * i.OffsetPosY * _GLOW;
                half4 Emission = tex2D( _MainTex, i.uv ) * _LightColor0 * i.ndl + L1Color;

                return Emission;
            }
            ENDCG
        }
    }
}
