Shader "MFramework/ShaderStudy/Chapter12/Chapter12-BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Base(RGB)", 2D) = "white" {}
        _Brightness("Brightness",Float) = 1
        _Saturation("Saturation",Float) = 1
        _Contrast("Contrast",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

            ZTest Always 
            Cull Off 
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

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

            half _Brightness;
            half _Saturation;
            half _Contrast;

            v2f vert (appdata_img v)
            {
             	v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.texcoord;
						 
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //调整亮度  乘一个亮度系数就行
                fixed4 renderTex = tex2D(_MainTex, i.uv);
                fixed3 finalColor = renderTex.rgb * _Brightness;

                //设定一个最低值 设定一个最高值  然后用数值在区间中取值    饱和度为零固定写法
                fixed luminance = 0.2125*renderTex.r+0.7154*renderTex.g+0.0721*renderTex.b;
                fixed3 luminanceColor = fixed3(luminance,luminance,luminance);
                finalColor = lerp(luminanceColor,finalColor,_Saturation);

                //对比度为零固定写法，与饱和度类似
                fixed3 avgColor = fixed3(0.5,0.5,0.5);
                finalColor = lerp(avgColor,finalColor,_Contrast);

                // apply fog
               //UNITY_APPLY_FOG(i.fogCoord, finalColor);
                return fixed4(finalColor,renderTex.a);
            }
            ENDCG
        }
    }
	Fallback Off
    
}
