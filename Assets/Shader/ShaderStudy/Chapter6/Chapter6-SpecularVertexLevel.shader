Shader "ShaderDemo/Chapter 6/Chapter6-Specular Vertex-level"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Speccular",Color) = (1,1,1,1)
        _Glass("Glass",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightModel"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                fixed3 color:COLOR;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Glass;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //世界空间下法线位置
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);

                //世界空间光方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

                //下面是高光反射
                //反射光线 
                fixed3 reflectDir = normalize(reflect(-worldLight,worldNormal));

                //视野方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-UnityObjectToWorldDir(v.vertex));

                fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Glass);

                o.color = ambient+diffuse+specular; 
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // apply fog
                return float4(i.color,1);
            }
            ENDCG
        }
    }
}
