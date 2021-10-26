Shader "Unlit/BookTurningEffect"
{
   Properties
  {
    //正面纹理
    _MainTex ("Texture", 2D) = "white" {}
    //背面纹理
 _SecTex("SecTex",2D)="White"{}
 
    //旋转角度
    _Angle("Angle",Range(0,180))=0
    //波长
    _WaveLength("WaveLength",Range(-1,1))=0
 
  }
  SubShader
  {
 
    Pass
    {
      //剔除背面
  Cull Back
 
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
 
      #include "UnityCG.cginc"
 
      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };
 
      struct v2f
      {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
      };
 
      sampler2D _MainTex;
  float4 _MainTex_ST;
      //角度
      float _Angle;
      //波长
      float _WaveLength;
 
      v2f vert (appdata v)
      {
        v2f o;
        //旋转之前向右偏移5个单位
        v.vertex -= float4(5,0,0,0);
        float s;
        float c;
        //通过该方法可以计算出该角度的正余弦值
        sincos(radians(_Angle),s,c);
        //旋转矩阵
        float4x4 rotateMatrix={
          c ,s,0,0,
          -s,c,0,0,
          0 ,0,1,0,
          0 ,0,0,1
        };
        //根据x坐标，通过正弦函数计算出 y坐标的正弦值， _WaveLength 控制波长， 振幅就跟随角度正弦值动态变化
        v.vertex.y = sin(v.vertex.x*_WaveLength) * s ;
 
        //顶点左乘以旋转矩阵
        v.vertex = mul(rotateMatrix,v.vertex);
        //旋转之后偏移回来
        v.vertex += float4(5,0,0,0);
 
        //模型空间转换到裁剪空间
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
      }
 
 
      fixed4 frag (v2f i) : SV_Target
      {
        fixed4 col = tex2D(_MainTex, i.uv);
        return col;
      }
      ENDCG
    }
 
     Pass
    {
        
  Cull Front
 
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag
 
      #include "UnityCG.cginc"
 
      struct appdata
      {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };
 
      struct v2f
      {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
      };
 
      //角度
      float _Angle;
      //波长
      float _WaveLength;
 
      sampler2D _SecTex;
  float4 _SecTex_ST;
 
      v2f vert (appdata v)
      {
        v2f o;
        //旋转之前向右偏移5个单位
        v.vertex -= float4(5,0,0,0);
        float s;
        float c;
        //通过该方法可以计算出该角度的正余弦值
        sincos(radians(_Angle),s,c);
        //旋转矩阵
        float4x4 rotateMatrix={
          c ,s,0,0,
          -s,c,0,0,
          0 ,0,1,0,
          0 ,0,0,1
        };
        //根据x坐标，通过正弦函数计算出 y坐标的正弦值， _WaveLength 控制波长， 振幅就跟随角度正弦值动态变化
        v.vertex.y = sin(v.vertex.x*_WaveLength) * s ;
 
        //顶点左乘以旋转矩阵
        v.vertex = mul(rotateMatrix,v.vertex);
        //旋转之后偏移回来
        v.vertex += float4(5,0,0,0);
 
        //模型空间转换到裁剪空间
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = v.uv;
        return o;
      }
 
 
      fixed4 frag (v2f i) : SV_Target
      {
        fixed4 col = tex2D(_SecTex, i.uv);
        return col;
      }
      ENDCG
    }
  }
}
