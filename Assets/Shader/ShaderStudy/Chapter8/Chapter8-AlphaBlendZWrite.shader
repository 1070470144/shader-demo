Shader "ShaderDemo/Chapter 8/AlphaBlendZWrite"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha" , Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite On
            ColorMask 0            
        }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal :NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal :TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Alpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normalDirection = normalize(i.normal);

                fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 diffuse = _LightColor0.rgb * col.rgb * (dot(lightDirection,normalDirection)*0.5+0.5);

                return fixed4(diffuse,col.a * _Alpha);
            }
            ENDCG
        }
    }
}
