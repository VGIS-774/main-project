Shader "Hidden/Persistence" {
    Properties{
        [HideInInspector] _MainTex("Current frame", 2D) = "white" {}
        [HideInInspector] _SecondTex("Previous frame", 2D) = "white" {}
        [Space(10)] [Toggle(PERS)] _Pers("Persistence effect", float) = 0
        [Space(10)] _t("t", Range(0.0, 1.0)) = 0.0
        _T("T", Range(0.0, 1.0)) = 0.0
    }
        SubShader{
            Cull Off
            ZWrite Off
            ZTest Always

            Pass {
                CGPROGRAM
                #pragma vertex vertexShader
                #pragma fragment fragmentShader
                #pragma shader_feature PERS

                #include "UnityCG.cginc"

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

                vertexOutput vertexShader(vertexInput i)
                {
                    vertexOutput o;
                    o.position = UnityObjectToClipPos(i.vertex);
                    o.texcoord = i.texcoord;
                    return o;
                }

                sampler2D _MainTex;
                float4 _MainTex_ST;
                
                sampler2D _SecondTex;
                float4 _SecondTex_ST;

                float _t;
                float _T;

                float4 fragmentShader(vertexOutput i) : COLOR
                {
                    float4 col1 = tex2D(_MainTex, UnityStereoScreenSpaceUVAdjust(i.texcoord, _MainTex_ST));
                    float4 col2 = tex2D(_SecondTex, UnityStereoScreenSpaceUVAdjust(i.texcoord, _SecondTex_ST));
                    
                    #if !PERS
                        // Running average effect
                        float newValue = lerp(col2.x, col1.x, _t);
                    #else
                        // Persistance effect
                        float newValue = col1.x + pow(E, -1.0 * (_t / _T)) * col2.x;
                    #endif

                    return newValue;
                }
                ENDCG
            }
        }
}