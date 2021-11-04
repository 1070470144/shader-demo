Shader "MFramework/Other/VolumeCloud"
{
    Properties
    {
        _Color("Color",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha",Range(0,1)) = 0.5
        _HeightOffset("HeightOffset",Range(0,1)) = 0.15
        _StepLayer("StepLayer",Range(2,64)) = 16
    }
    SubShader
    {
        Tags 
        {
            "IgnoreProjector" = "True"
            "Queue"="Transparent-50"
            "RenderType"="Transparent" 
        }

        Pass
        {
            Name "FORWARD"

            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #define UNITY_PASS_FORWARDBASE
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            #pragma multi_compile_fwdbse
            #pragma target 3.0

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _HeightOffset;
            half _HeightAmount;
            half4 _Color;
            half _Alpha;
            half _StepLayer;

            half4 _LightingColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR0;
                float2 texcoord : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float4 posWorld:TEXCOORD3;
                float2 uv2:TEXCOORD4;
                float4 color:TEXCOORD5;
                UNITY_FOG_COORDS(7)
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex)+float2(_Time.y*0.1,0);
                o.uv2 = v.texcoord;
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                TANGENT_SPACE_ROTATION;
                o.viewDir = mul(rotation ,ObjSpaceViewDir(v.vertex));
                o.color = v.color
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 根据视角算偏移，模拟出假3D的效果，SPN优化而来的POM
                float3 viewDir = normalize(i.viewDir);
                viewDir.xy *= _HeightOffset;
                //添加偏移值，减少狗牙感觉
                viewDir.z +=0.4;
                float3 uv = float3(i.uv,0);
                float3 uv2= float3(i.uv2,0);

                float4 MainTex = tex2D(_MainTex,uv2.xy);
                //使用viewDir.xy除以viewDir.z,可以得到uv的所需要的偏移方向，并平分为x层
                float3 minOffset = viewDir / (viewDir.z*_StepLayer);
                //两段noise叠加，产生新noise
                float finiNoise = tex2D(_MainTex,uv.xy).r * MainTex.r;
                float3 prev_uv = uv;
                while(finiNoise>uv.z)
                {
                    uv+=minOffset;
                    finiNoise = tex2Dlod(_MainTex,float4(uv.xy,0,0)).r*MainTex.r;
                }

                //选取每层选用的UV进行映射
                float d1 = finiNoise -uv.z;
                float d2 = finiNoise -prev_uv.z;
                float w = d1/(d1-d2+0.00000001);
                uv = lerp(uv,prev_uv,w);
                half4 resultColor = tex2D(_MainTex,uv.xy)*MainTex;

                half rangeClt = MainTex.a * resultColor.r+_Alpha*0.75;
                half Alpha = abs(smoothstep(rangeClt,_Alpha,1.0));
                Alpha = Alpha*Alpha*Alpha*Alpha*Alpha;
                return half4(resultColor.rgb*_Color.rgb*_LightColor0.rgb,Alpha);
                
            }
            ENDCG
        }
    }
}
