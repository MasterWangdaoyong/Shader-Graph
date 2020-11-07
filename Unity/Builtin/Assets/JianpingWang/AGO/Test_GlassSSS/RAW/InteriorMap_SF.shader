// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:3,spmd:0,trmd:0,grmd:1,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:1,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:True,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:6508,x:41123,y:31236,varname:node_6508,prsc:2|emission-4886-RGB;n:type:ShaderForge.SFN_Noise,id:2890,x:31162,y:31721,varname:AtlasNoise,prsc:2|XY-3331-OUT;n:type:ShaderForge.SFN_Vector4Property,id:6029,x:29401,y:31001,ptovrint:True,ptlb:Rows Cols CountX CountY,ptin:_Rooms,varname:_Rooms,prsc:1,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,v1:4,v2:2,v3:5,v4:5;n:type:ShaderForge.SFN_Append,id:3983,x:30693,y:31534,varname:AtlasAppend,prsc:2|A-2815-OUT,B-2592-OUT;n:type:ShaderForge.SFN_TexCoord,id:9079,x:30034,y:31416,varname:node_9079,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Posterize,id:2815,x:30481,y:31472,varname:node_2815,prsc:2|IN-9079-U,STPS-959-B;n:type:ShaderForge.SFN_Posterize,id:2592,x:30481,y:31608,varname:node_2592,prsc:2|IN-9079-V,STPS-959-A;n:type:ShaderForge.SFN_Tex2dAsset,id:3,x:32929,y:31260,ptovrint:True,ptlb:Room Atlas RGB (A - back wall fraction),ptin:_RoomTex,varname:_RoomTex,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:True,tagnrm:False,tex:5c5e7135757e86d48be9b317d8c68cf3,ntxv:1,isnm:False;n:type:ShaderForge.SFN_Append,id:799,x:30486,y:31224,cmnt:Texture Tiling,varname:node_799,prsc:2|A-959-B,B-959-A;n:type:ShaderForge.SFN_Append,id:9863,x:30486,y:31047,cmnt:Room Atlas,varname:node_9863,prsc:2|A-959-R,B-959-G;n:type:ShaderForge.SFN_Append,id:7078,x:29677,y:31118,varname:node_7078,prsc:2|A-6029-X,B-6029-Y,C-6029-Z,D-6029-W;n:type:ShaderForge.SFN_Round,id:8855,x:29850,y:31118,varname:node_8855,prsc:2|IN-7078-OUT;n:type:ShaderForge.SFN_ComponentMask,id:959,x:30016,y:31118,varname:node_959,prsc:2,cc1:0,cc2:1,cc3:2,cc4:3|IN-8855-OUT;n:type:ShaderForge.SFN_Add,id:3331,x:30994,y:31721,varname:node_3331,prsc:2|A-3983-OUT,B-9639-OUT;n:type:ShaderForge.SFN_Add,id:2904,x:30994,y:31865,varname:node_2904,prsc:2|A-3983-OUT,B-8212-OUT;n:type:ShaderForge.SFN_Noise,id:9457,x:31162,y:31865,varname:node_9457,prsc:2|XY-2904-OUT;n:type:ShaderForge.SFN_Append,id:4720,x:31354,y:31788,varname:node_4720,prsc:2|A-2890-OUT,B-9457-OUT;n:type:ShaderForge.SFN_Vector1,id:4557,x:31736,y:31436,varname:node_4557,prsc:2,v1:1;n:type:ShaderForge.SFN_Divide,id:4004,x:31736,y:31503,varname:node_4004,prsc:2|A-4557-OUT,B-9863-OUT;n:type:ShaderForge.SFN_Multiply,id:5498,x:31976,y:31584,varname:node_5498,prsc:2|A-4004-OUT,B-4889-OUT;n:type:ShaderForge.SFN_Multiply,id:9775,x:31570,y:31694,varname:node_9775,prsc:2|A-799-OUT,B-4720-OUT;n:type:ShaderForge.SFN_Round,id:4889,x:31736,y:31694,varname:node_4889,prsc:2|IN-9775-OUT;n:type:ShaderForge.SFN_ObjectPosition,id:79,x:30278,y:31807,varname:node_79,prsc:2;n:type:ShaderForge.SFN_Round,id:8212,x:30481,y:31908,varname:node_8212,prsc:2|IN-79-Y;n:type:ShaderForge.SFN_Add,id:6651,x:30481,y:31787,varname:node_6651,prsc:2|A-79-X,B-79-Z;n:type:ShaderForge.SFN_Round,id:9639,x:30693,y:31787,varname:node_9639,prsc:2|IN-6651-OUT;n:type:ShaderForge.SFN_Vector1,id:6990,x:33656,y:30971,varname:node_6990,prsc:2,v1:1;n:type:ShaderForge.SFN_Divide,id:9427,x:33847,y:30971,varname:node_9427,prsc:2|A-6990-OUT,B-5574-OUT;n:type:ShaderForge.SFN_Vector1,id:6079,x:33481,y:31041,varname:node_6079,prsc:2,v1:1;n:type:ShaderForge.SFN_Subtract,id:5574,x:33656,y:31041,varname:node_5574,prsc:2|A-6079-OUT,B-4446-A;n:type:ShaderForge.SFN_Subtract,id:364,x:34021,y:31005,cmnt:Depth Scale,varname:node_364,prsc:2|A-9427-OUT,B-9933-OUT;n:type:ShaderForge.SFN_Vector1,id:2791,x:35160,y:30476,varname:node_2791,prsc:2,v1:1;n:type:ShaderForge.SFN_Divide,id:2383,x:35367,y:30506,cmnt:id,varname:node_2383,prsc:2|A-2791-OUT,B-2286-OUT;n:type:ShaderForge.SFN_Abs,id:2546,x:35588,y:30505,varname:node_2546,prsc:2|IN-2383-OUT;n:type:ShaderForge.SFN_Subtract,id:8571,x:35773,y:30573,cmnt:k,varname:node_8571,prsc:2|A-2546-OUT,B-748-OUT;n:type:ShaderForge.SFN_Multiply,id:748,x:35588,y:30652,varname:node_748,prsc:2|A-2383-OUT,B-3949-OUT;n:type:ShaderForge.SFN_Min,id:67,x:36301,y:30573,cmnt:kMin,varname:node_67,prsc:2|A-2556-OUT,B-9201-B;n:type:ShaderForge.SFN_Add,id:7653,x:36931,y:30579,cmnt:pos ,varname:node_7653,prsc:2|A-5314-OUT,B-8109-OUT;n:type:ShaderForge.SFN_Min,id:2556,x:36125,y:30573,varname:node_2556,prsc:2|A-9201-R,B-9201-G;n:type:ShaderForge.SFN_ComponentMask,id:9201,x:35950,y:30573,varname:node_9201,prsc:2,cc1:0,cc2:1,cc3:2,cc4:-1|IN-8571-OUT;n:type:ShaderForge.SFN_Multiply,id:7836,x:37320,y:30649,varname:node_7836,prsc:2|A-6380-OUT,B-6999-OUT;n:type:ShaderForge.SFN_Add,id:9545,x:37509,y:30755,cmnt:interp,varname:node_9545,prsc:2|A-7836-OUT,B-6999-OUT;n:type:ShaderForge.SFN_ComponentMask,id:6380,x:37130,y:30579,cmnt:pos.z,varname:node_6380,prsc:2,cc1:2,cc2:-1,cc3:-1,cc4:-1|IN-7653-OUT;n:type:ShaderForge.SFN_Vector1,id:6999,x:37130,y:30775,varname:node_6999,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Clamp01,id:2456,x:37787,y:30686,varname:node_2456,prsc:2|IN-9545-OUT;n:type:ShaderForge.SFN_Divide,id:4069,x:37994,y:30686,cmnt:realZ,varname:node_4069,prsc:2|A-2456-OUT,B-8282-OUT;n:type:ShaderForge.SFN_Add,id:5889,x:38199,y:30711,varname:node_5889,prsc:2|A-4069-OUT,B-7236-OUT;n:type:ShaderForge.SFN_Vector1,id:7236,x:37994,y:30820,varname:node_7236,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:8103,x:38195,y:30645,varname:node_8103,prsc:2,v1:1;n:type:ShaderForge.SFN_Subtract,id:9440,x:38623,y:30645,cmnt:interp,varname:node_9440,prsc:2|A-8103-OUT,B-1983-OUT;n:type:ShaderForge.SFN_Divide,id:1983,x:38419,y:30691,varname:node_1983,prsc:2|A-8103-OUT,B-5889-OUT;n:type:ShaderForge.SFN_Multiply,id:2504,x:39035,y:30829,cmnt:interp,varname:node_2504,prsc:2|A-9440-OUT,B-6747-OUT;n:type:ShaderForge.SFN_ComponentMask,id:8520,x:39333,y:30566,cmnt:posXY,varname:node_8520,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-4609-OUT;n:type:ShaderForge.SFN_Lerp,id:861,x:39333,y:30730,varname:node_861,prsc:2|A-6941-OUT,B-2055-OUT,T-2504-OUT;n:type:ShaderForge.SFN_Multiply,id:5532,x:39546,y:30639,cmnt:interiorUV,varname:node_5532,prsc:2|A-8520-OUT,B-861-OUT;n:type:ShaderForge.SFN_Vector1,id:6941,x:39035,y:30731,varname:node_6941,prsc:2,v1:1;n:type:ShaderForge.SFN_Set,id:1360,x:33515,y:31203,varname:__farFrac,prsc:2|IN-4446-A;n:type:ShaderForge.SFN_Multiply,id:7665,x:39756,y:30706,varname:node_7665,prsc:2|A-5532-OUT,B-7587-OUT;n:type:ShaderForge.SFN_Vector1,id:7587,x:39546,y:30819,varname:node_7587,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Add,id:9334,x:39950,y:30799,cmnt:interiorUV,varname:node_9334,prsc:2|A-7665-OUT,B-7587-OUT;n:type:ShaderForge.SFN_Floor,id:7750,x:32214,y:31349,varname:node_7750,prsc:2|IN-5491-OUT;n:type:ShaderForge.SFN_Frac,id:3169,x:32233,y:30868,cmnt:Room Uvs,varname:node_3169,prsc:2|IN-5491-OUT;n:type:ShaderForge.SFN_Floor,id:9073,x:32214,y:31496,varname:node_9073,prsc:2|IN-5498-OUT;n:type:ShaderForge.SFN_Add,id:1069,x:32403,y:31428,cmnt:Room Index,varname:node_1069,prsc:2|A-7750-OUT,B-9073-OUT;n:type:ShaderForge.SFN_Multiply,id:5481,x:34982,y:30755,varname:node_5481,prsc:2|A-4842-OUT,B-3416-OUT;n:type:ShaderForge.SFN_Vector1,id:4842,x:34795,y:30755,varname:node_4842,prsc:2,v1:2;n:type:ShaderForge.SFN_Subtract,id:31,x:35166,y:30755,varname:node_31,prsc:2|A-5481-OUT,B-4559-OUT;n:type:ShaderForge.SFN_Vector1,id:4559,x:34982,y:30886,varname:node_4559,prsc:2,v1:1;n:type:ShaderForge.SFN_Append,id:3949,x:35365,y:30799,cmnt:pos,varname:node_3949,prsc:2|A-31-OUT,B-9951-OUT;n:type:ShaderForge.SFN_Vector1,id:9951,x:35166,y:30886,varname:node_9951,prsc:2,v1:-1;n:type:ShaderForge.SFN_Tex2d,id:4446,x:33309,y:31041,cmnt:Far wall fraction compared to Room,varname:node_4446,prsc:2,tex:5c5e7135757e86d48be9b317d8c68cf3,ntxv:0,isnm:False|UVIN-4371-OUT,TEX-3-TEX;n:type:ShaderForge.SFN_Add,id:1398,x:32858,y:30910,varname:node_1398,prsc:2|A-3848-OUT,B-1069-OUT;n:type:ShaderForge.SFN_Vector1,id:3848,x:32680,y:30910,varname:node_3848,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Divide,id:4371,x:33084,y:30967,varname:node_4371,prsc:2|A-1398-OUT,B-5256-OUT;n:type:ShaderForge.SFN_Vector1,id:9933,x:33848,y:31102,varname:node_9933,prsc:2,v1:1;n:type:ShaderForge.SFN_Append,id:2286,x:34590,y:30527,cmnt:Tangent View Direction,varname:node_2286,prsc:2|A-5749-R,B-5749-G,C-2838-OUT;n:type:ShaderForge.SFN_ComponentMask,id:5749,x:34210,y:30503,varname:node_5749,prsc:2,cc1:0,cc2:1,cc3:2,cc4:-1|IN-5672-OUT;n:type:ShaderForge.SFN_Multiply,id:2838,x:34396,y:30626,varname:node_2838,prsc:2|A-5749-B,B-9529-OUT;n:type:ShaderForge.SFN_Multiply,id:9529,x:34210,y:30690,varname:node_9529,prsc:2|A-5118-OUT,B-364-OUT;n:type:ShaderForge.SFN_Vector1,id:5118,x:34022,y:30690,varname:node_5118,prsc:2,v1:-1;n:type:ShaderForge.SFN_Dot,id:3250,x:33598,y:30300,varname:node_3250,prsc:2,dt:0|A-2068-OUT,B-8084-OUT;n:type:ShaderForge.SFN_Tangent,id:8084,x:33395,y:30385,varname:node_8084,prsc:2;n:type:ShaderForge.SFN_NormalVector,id:9875,x:33395,y:30630,prsc:2,pt:False;n:type:ShaderForge.SFN_Bitangent,id:2895,x:33395,y:30506,varname:node_2895,prsc:2;n:type:ShaderForge.SFN_Dot,id:3112,x:33598,y:30451,varname:node_3112,prsc:2,dt:0|A-2068-OUT,B-2895-OUT;n:type:ShaderForge.SFN_Dot,id:9464,x:33598,y:30593,varname:node_9464,prsc:2,dt:0|A-2068-OUT,B-9875-OUT;n:type:ShaderForge.SFN_Append,id:7033,x:33820,y:30432,varname:node_7033,prsc:2|A-3250-OUT,B-3112-OUT,C-9464-OUT;n:type:ShaderForge.SFN_Multiply,id:5314,x:36605,y:30349,varname:node_5314,prsc:2|A-8916-OUT,B-67-OUT;n:type:ShaderForge.SFN_Vector1,id:3316,x:38627,y:30957,varname:node_3316,prsc:2,v1:1;n:type:ShaderForge.SFN_Add,id:6747,x:38821,y:30997,varname:node_6747,prsc:2|A-3316-OUT,B-8282-OUT;n:type:ShaderForge.SFN_Tex2d,id:4886,x:40827,y:31238,varname:node_4886,prsc:2,tex:5c5e7135757e86d48be9b317d8c68cf3,ntxv:0,isnm:False|UVIN-1128-OUT,TEX-3-TEX;n:type:ShaderForge.SFN_Add,id:4594,x:40381,y:31075,varname:node_4594,prsc:2|A-9334-OUT,B-4305-OUT;n:type:ShaderForge.SFN_Divide,id:1128,x:40612,y:31162,varname:node_1128,prsc:2|A-4594-OUT,B-7458-OUT;n:type:ShaderForge.SFN_Multiply,id:5491,x:31976,y:31229,varname:node_5491,prsc:2|A-799-OUT,B-1742-OUT;n:type:ShaderForge.SFN_FragmentPosition,id:8774,x:33195,y:30182,varname:node_8774,prsc:2;n:type:ShaderForge.SFN_ViewPosition,id:1654,x:33195,y:30352,varname:node_1654,prsc:2;n:type:ShaderForge.SFN_Subtract,id:2068,x:33395,y:30258,varname:node_2068,prsc:2|A-8774-XYZ,B-1654-XYZ;n:type:ShaderForge.SFN_Multiply,id:5672,x:34022,y:30505,varname:node_5672,prsc:2|A-7033-OUT,B-1797-OUT;n:type:ShaderForge.SFN_Append,id:3265,x:29676,y:30939,varname:node_3265,prsc:2|A-6029-Z,B-6029-W,C-6029-Z;n:type:ShaderForge.SFN_Relay,id:1742,x:31596,y:31400,cmnt:UVs,varname:node_1742,prsc:2|IN-9079-UVOUT;n:type:ShaderForge.SFN_Relay,id:998,x:30544,y:30813,varname:node_998,prsc:2|IN-3908-OUT;n:type:ShaderForge.SFN_Relay,id:1797,x:33657,y:30808,cmnt:Texture Tiling XYX,varname:node_1797,prsc:2|IN-998-OUT;n:type:ShaderForge.SFN_Relay,id:8916,x:35219,y:30346,varname:node_8916,prsc:2|IN-2286-OUT;n:type:ShaderForge.SFN_Relay,id:8109,x:36653,y:30800,varname:node_8109,prsc:2|IN-3949-OUT;n:type:ShaderForge.SFN_Relay,id:8282,x:37845,y:31018,cmnt:Depth Scale,varname:node_8282,prsc:2|IN-364-OUT;n:type:ShaderForge.SFN_Relay,id:2518,x:37187,y:30434,varname:node_2518,prsc:2|IN-7653-OUT;n:type:ShaderForge.SFN_Relay,id:4609,x:39085,y:30435,cmnt:POS,varname:node_4609,prsc:2|IN-2518-OUT;n:type:ShaderForge.SFN_Relay,id:2673,x:33656,y:31304,varname:node_2673,prsc:2|IN-4446-A;n:type:ShaderForge.SFN_Relay,id:2055,x:39101,y:31312,cmnt:Far Wall Fraction,varname:node_2055,prsc:2|IN-2673-OUT;n:type:ShaderForge.SFN_Relay,id:2173,x:33656,y:31397,varname:node_2173,prsc:2|IN-1069-OUT;n:type:ShaderForge.SFN_Relay,id:4305,x:39985,y:31400,cmnt:Room Index,varname:node_4305,prsc:2|IN-2173-OUT;n:type:ShaderForge.SFN_Relay,id:5256,x:32917,y:31046,cmnt:Room Atlas,varname:node_5256,prsc:2|IN-9863-OUT;n:type:ShaderForge.SFN_Relay,id:458,x:33656,y:31487,varname:node_458,prsc:2|IN-5256-OUT;n:type:ShaderForge.SFN_Relay,id:7458,x:40425,y:31480,cmnt:Room Atlas,varname:node_7458,prsc:2|IN-458-OUT;n:type:ShaderForge.SFN_Relay,id:3416,x:34854,y:30864,cmnt:Room UVs,varname:node_3416,prsc:2|IN-3169-OUT;n:type:ShaderForge.SFN_Round,id:3908,x:29850,y:30939,varname:node_3908,prsc:2|IN-3265-OUT;proporder:3-6029;pass:END;sub:END;*/

Shader "Custom/InteriorMapping - 2D Atlas SF" {
    Properties {
        [NoScaleOffset]_RoomTex ("Room Atlas RGB (A - back wall fraction)", 2D) = "gray" {}
        _Rooms ("Rows Cols CountX CountY", Vector) = (4,2,5,5)
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 100
        Pass {
            Name "DEFERRED"
            Tags {
                "LightMode"="Deferred"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #define UNITY_PASS_DEFERRED
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma multi_compile ___ UNITY_HDR_ON
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform half4 _Rooms;
            uniform sampler2D _RoomTex;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            void frag(
                VertexOutput i,
                out half4 outDiffuse : SV_Target0,
                out half4 outSpecSmoothness : SV_Target1,
                out half4 outNormal : SV_Target2,
                out half4 outEmission : SV_Target3 )
            {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float3 node_2068 = (i.posWorld.rgb-_WorldSpaceCameraPos);
                float3 node_5749 = (float3(dot(node_2068,i.tangentDir),dot(node_2068,i.bitangentDir),dot(node_2068,i.normalDir))*round(float3(_Rooms.b,_Rooms.a,_Rooms.b))).rgb;
                float4 node_959 = round(float4(_Rooms.r,_Rooms.g,_Rooms.b,_Rooms.a)).rgba;
                float2 node_799 = float2(node_959.b,node_959.a); // Texture Tiling
                float2 node_5491 = (node_799*i.uv0);
                float2 node_9863 = float2(node_959.r,node_959.g); // Room Atlas
                float2 AtlasAppend = float2(floor(i.uv0.r * node_959.b) / (node_959.b - 1),floor(i.uv0.g * node_959.a) / (node_959.a - 1));
                float2 node_3331 = (AtlasAppend+round((objPos.r+objPos.b)));
                float2 AtlasNoise_skew = node_3331 + 0.2127+node_3331.x*0.3713*node_3331.y;
                float2 AtlasNoise_rnd = 4.789*sin(489.123*(AtlasNoise_skew));
                float AtlasNoise = frac(AtlasNoise_rnd.x*AtlasNoise_rnd.y*(1+AtlasNoise_skew.x));
                float2 node_2904 = (AtlasAppend+round(objPos.g));
                float2 node_9457_skew = node_2904 + 0.2127+node_2904.x*0.3713*node_2904.y;
                float2 node_9457_rnd = 4.789*sin(489.123*(node_9457_skew));
                float node_9457 = frac(node_9457_rnd.x*node_9457_rnd.y*(1+node_9457_skew.x));
                float2 node_1069 = (floor(node_5491)+floor(((1.0/node_9863)*round((node_799*float2(AtlasNoise,node_9457)))))); // Room Index
                float2 node_5256 = node_9863; // Room Atlas
                float2 node_4371 = ((0.5+node_1069)/node_5256);
                float4 node_4446 = tex2D(_RoomTex,node_4371); // Far wall fraction compared to Room
                float node_364 = ((1.0/(1.0-node_4446.a))-1.0); // Depth Scale
                float3 node_2286 = float3(node_5749.r,node_5749.g,(node_5749.b*((-1.0)*node_364))); // Tangent View Direction
                float3 node_2383 = (1.0/node_2286); // id
                float3 node_3949 = float3(((2.0*frac(node_5491))-1.0),(-1.0)); // pos
                float3 node_9201 = (abs(node_2383)-(node_2383*node_3949)).rgb;
                float3 node_7653 = ((node_2286*min(min(node_9201.r,node_9201.g),node_9201.b))+node_3949); // pos 
                float3 node_2518 = node_7653;
                float node_8103 = 1.0;
                float node_6999 = 0.5;
                float node_8282 = node_364; // Depth Scale
                float node_7587 = 0.5;
                float2 node_1128 = (((((node_2518.rg*lerp(1.0,node_4446.a,((node_8103-(node_8103/((saturate(((node_7653.b*node_6999)+node_6999))/node_8282)+1.0)))*(1.0+node_8282))))*node_7587)+node_7587)+node_1069)/node_5256);
                float4 node_4886 = tex2D(_RoomTex,node_1128);
                float3 emissive = node_4886.rgb;
                float3 finalColor = emissive;
                outDiffuse = half4( 0, 0, 0, 1 );
                outSpecSmoothness = half4(0,0,0,0);
                outNormal = half4( normalDirection * 0.5 + 0.5, 1 );
                outEmission = half4( node_4886.rgb, 1 );
                #ifndef UNITY_HDR_ON
                    outEmission.rgb = exp2(-outEmission.rgb);
                #endif
            }
            ENDCG
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile_fog
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform half4 _Rooms;
            uniform sampler2D _RoomTex;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
                float3 tangentDir : TEXCOORD3;
                float3 bitangentDir : TEXCOORD4;
                UNITY_FOG_COORDS(5)
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                i.normalDir = normalize(i.normalDir);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                float3 viewReflectDirection = reflect( -viewDirection, normalDirection );
////// Lighting:
////// Emissive:
                float3 node_2068 = (i.posWorld.rgb-_WorldSpaceCameraPos);
                float3 node_5749 = (float3(dot(node_2068,i.tangentDir),dot(node_2068,i.bitangentDir),dot(node_2068,i.normalDir))*round(float3(_Rooms.b,_Rooms.a,_Rooms.b))).rgb;
                float4 node_959 = round(float4(_Rooms.r,_Rooms.g,_Rooms.b,_Rooms.a)).rgba;
                float2 node_799 = float2(node_959.b,node_959.a); // Texture Tiling
                float2 node_5491 = (node_799*i.uv0);
                float2 node_9863 = float2(node_959.r,node_959.g); // Room Atlas
                float2 AtlasAppend = float2(floor(i.uv0.r * node_959.b) / (node_959.b - 1),floor(i.uv0.g * node_959.a) / (node_959.a - 1));
                float2 node_3331 = (AtlasAppend+round((objPos.r+objPos.b)));
                float2 AtlasNoise_skew = node_3331 + 0.2127+node_3331.x*0.3713*node_3331.y;
                float2 AtlasNoise_rnd = 4.789*sin(489.123*(AtlasNoise_skew));
                float AtlasNoise = frac(AtlasNoise_rnd.x*AtlasNoise_rnd.y*(1+AtlasNoise_skew.x));
                float2 node_2904 = (AtlasAppend+round(objPos.g));
                float2 node_9457_skew = node_2904 + 0.2127+node_2904.x*0.3713*node_2904.y;
                float2 node_9457_rnd = 4.789*sin(489.123*(node_9457_skew));
                float node_9457 = frac(node_9457_rnd.x*node_9457_rnd.y*(1+node_9457_skew.x));
                float2 node_1069 = (floor(node_5491)+floor(((1.0/node_9863)*round((node_799*float2(AtlasNoise,node_9457)))))); // Room Index
                float2 node_5256 = node_9863; // Room Atlas
                float2 node_4371 = ((0.5+node_1069)/node_5256);
                float4 node_4446 = tex2D(_RoomTex,node_4371); // Far wall fraction compared to Room
                float node_364 = ((1.0/(1.0-node_4446.a))-1.0); // Depth Scale
                float3 node_2286 = float3(node_5749.r,node_5749.g,(node_5749.b*((-1.0)*node_364))); // Tangent View Direction
                float3 node_2383 = (1.0/node_2286); // id
                float3 node_3949 = float3(((2.0*frac(node_5491))-1.0),(-1.0)); // pos
                float3 node_9201 = (abs(node_2383)-(node_2383*node_3949)).rgb;
                float3 node_7653 = ((node_2286*min(min(node_9201.r,node_9201.g),node_9201.b))+node_3949); // pos 
                float3 node_2518 = node_7653;
                float node_8103 = 1.0;
                float node_6999 = 0.5;
                float node_8282 = node_364; // Depth Scale
                float node_7587 = 0.5;
                float2 node_1128 = (((((node_2518.rg*lerp(1.0,node_4446.a,((node_8103-(node_8103/((saturate(((node_7653.b*node_6999)+node_6999))/node_8282)+1.0)))*(1.0+node_8282))))*node_7587)+node_7587)+node_1069)/node_5256);
                float4 node_4886 = tex2D(_RoomTex,node_1128);
                float3 emissive = node_4886.rgb;
                float3 finalColor = emissive;
                fixed4 finalRGBA = fixed4(finalColor,1);
                UNITY_APPLY_FOG(i.fogCoord, finalRGBA);
                return finalRGBA;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
