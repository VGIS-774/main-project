Shader "Hidden/NewImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SecondTex("Second texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _SecondTex;

            float4 frag (v2f i) : SV_Target
            {
                float4 image = tex2D(_MainTex, i.uv);
                float4 mask = tex2D(_SecondTex, i.uv);

                float4 col = float4(0.0, 0.0, 0.0, 0.0);

                col.rgb = 1 - ((1 - mask.rgb) * (1 - image.rgb) / 1);
                return col;
            }
            ENDCG
        }
    }
}
