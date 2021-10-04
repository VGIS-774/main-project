Shader "Hidden/Gaussian Blur" {
    Properties{
        [HideInInspector] _MainTex("Base (RGB)", 2D) = "white" {}
        _Strenght("Amount of Blur", Range(0.0, 0.1)) = 0.0
        [KeywordEnum(Low, Medium, High)] _Samples("Sample amount", Float) = 0
        _StandardDev("Standard deviation", Range(0.0, 0.1)) = 0.02
    }
        SubShader{
            Cull Off
            ZWrite Off
            ZTest Always

            // First pass for blurring in vertical direction
            Pass {
                CGPROGRAM
                #pragma vertex vertexShader
                #pragma fragment fragmentShader
                #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH

                #include "UnityCG.cginc"

                #if _SAMPLES_LOW
                    #define SAMPLES 10
                #elif _SAMPLES_MEDIUM
                    #define SAMPLES 20
                #else
                    #define SAMPLES 30
                #endif

                #define PI 3.14159265359
                #define E 2.71828182846

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

                vertexOutput vertexShader(vertexInput input)
                {
                    vertexOutput o;
                    o.position = UnityObjectToClipPos(input.vertex);
                    o.texcoord = input.texcoord;
                    return o;
                }

                sampler2D _MainTex;
                float4 _MainTex_ST;

                float _Strenght;
                float _StandardDev;

                float4 fragmentShader(vertexOutput input) : COLOR
                {
                    float4 col = 0;
                    float sum = 0;

                    if (_StandardDev == 0) {
                        return tex2D(_MainTex, input.texcoord);
                    }

                    float squaredSTD = _StandardDev * _StandardDev;

                    for (float i = 0; i < SAMPLES; i++) {

                        float offset = (i/(SAMPLES - 1) - 0.5) * _Strenght;

                        float2 uv = input.texcoord + float2(0, offset);

                        float gaussian = (1 / sqrt(2 * PI * squaredSTD) * pow(E, -(offset * offset) / (2 * squaredSTD)));

                        sum += gaussian;
                        col += tex2D(_MainTex, uv) * gaussian;
                    }

                    col = col/sum;
                    return col;
                }
                ENDCG
            }

            // Second pass for blurring in horizontal direction
            Pass {
                CGPROGRAM
                #pragma vertex vertexShader
                #pragma fragment fragmentShader
                #pragma multi_compile _SAMPLES_LOW _SAMPLES_MEDIUM _SAMPLES_HIGH

                #include "UnityCG.cginc"

                #if _SAMPLES_LOW
                    #define SAMPLES 10
                #elif _SAMPLES_MEDIUM
                    #define SAMPLES 20
                #else
                    #define SAMPLES 30
                #endif

                #define PI 3.14159265359
                #define E 2.71828182846

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

                vertexOutput vertexShader(vertexInput input)
                {
                    vertexOutput o;
                    o.position = UnityObjectToClipPos(input.vertex);
                    o.texcoord = input.texcoord;
                    return o;
                }

                sampler2D _MainTex;
                float4 _MainTex_ST;

                float _Strenght;
                float _StandardDev;

                float4 fragmentShader(vertexOutput input) : COLOR
                {
                    float4 col = 0;
                    float sum = 0;

                    if (_StandardDev == 0) {
                        return tex2D(_MainTex, input.texcoord);
                    }

                    float squaredSTD = _StandardDev * _StandardDev;

                    for (float i = 0; i < SAMPLES; i++) {

                        float offset = (i / (SAMPLES - 1) - 0.5) * _Strenght;

                        float2 uv = input.texcoord + float2(offset, 0);

                        float gaussian = (1 / sqrt(2 * PI * squaredSTD) * pow(E, -(offset * offset) / (2 * squaredSTD)));

                        sum += gaussian;
                        col += tex2D(_MainTex, uv) * gaussian;
                    }

                    col = col / sum;
                    return col;
                }
                ENDCG
            }
        }
}