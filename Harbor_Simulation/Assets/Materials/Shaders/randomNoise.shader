Shader "Hidden/Random Noise" {
    Properties{
        [HideInInspector]  _MainTex("Base (RGB)", 2D) = "white" {}
        _Strenght("Amount of noise", Range(0.0, 1.0)) = 0.0
    }
        SubShader{
            Cull Off
            ZWrite Off
            ZTest Always

            Pass {
                CGPROGRAM
                #pragma vertex vertexShader
                #pragma fragment fragmentShader

                #include "UnityCG.cginc"

                struct vertexInput
                {
                    float4 vertex : POSITION;
                    float2 texcoord : TEXCOORD0;
                };

                struct vertexOutput
                {
                    float2 texcoord : TEXCOORD0;
                    float4 position : SV_POSITION;
                };

                float random(float2 uv)
                {
                    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453123);
                }

                vertexOutput vertexShader(vertexInput i)
                {
                    vertexOutput o;
                    o.position = UnityObjectToClipPos(i.vertex);
                    o.texcoord = i.texcoord;
                    return o;
                }

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float _Strenght;

                float4 fragmentShader(vertexOutput i) : COLOR
                {
                    float4 color = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST));
                    float randomValue = random(i.texcoord * _Time.y);
                    float finalNoise = lerp(color, randomValue, _Strenght);
                    return finalNoise;
                }
                ENDCG
            }
        }
}