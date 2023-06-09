Shader "ShaderDemo/Chapter 3/Chapter3-ShaderLabProperties"
{
    Properties
    {
        _Int ("Int" , Int) = 1
        _Float ("Float" , Float) = 1.5
        _Range ("Range" , Range(1.0,5.0)) = 3.0
        _Color ("Color" , Color) = (1,1,1,0)
        _Vector ("Vector" , Vector) = (2,3,6,1)
        _2D ("2D" , 2D) = ""{}
        _Cube ("Cube" , Cube) = "White"{}
        _3D ("3D",3D) = ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
