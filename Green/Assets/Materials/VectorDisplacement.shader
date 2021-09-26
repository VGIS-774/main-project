Shader "Custom/VectorDisplacement"
{
    Properties
    {
        _DisplacementTex1("First Displacement Texture", 2D) = "white" {}
        _DisplacementTex2("Second Displacement Texture", 2D) = "white" {}
        [Toggle] _isMoving("is Moving", Float) = 0
        _WaveSpeed("Speed of water waves", Range(0.0, 1.0)) = 0.5
        _Displacement("Displacement", Float) = 1.0
        _DisplacementBlend("Displacement Blending", Range(0.0, 1.0)) = 0.5

        _MaterialEmissivity("Emissivity", Range(0.0, 1.0)) = 0.95
        _EmissivityBlendFactor("Blend factor", Range(0.0, 1.0)) = 0.75
        _StefanBolztmannConstant("Stefan-Bolztmann's Constant", Float) = 0.000000056704//5.6704E-08
        _MaterialTemperature("Material temperature in K", Float) = 300.0
        _Level("Level", Float) = 0.0
        _Gain("Gain", Float) = 0.0
    }

    SubShader
    {
        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            uniform sampler2D _DisplacementTex1;
            uniform float4 _DisplacementTex1_ST;

            uniform sampler2D _DisplacementTex2;
            uniform float4 _DisplacementTex2_ST;

            float _WaveSpeed;
            float _isMoving;
            float _Displacement;
            float _DisplacementBlend;

            float _MaterialEmissivity;
            float _EmissivityBlendFactor;
            float _StefanBolztmannConstant;
            float _MaterialTemperature;
            float _Level;
            float _Gain;

            struct vertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct vertexOutput {
                float4 position : SV_POSITION;
                float4 texcoord : TEXCOORD0;
            };

            vertexOutput vert(vertexInput i) {
                vertexOutput output;
                float time;

                if (_isMoving) {
                    time = _Time.y;
                }
                else {
                    time = 0.0;
                }

                float4 col1 = tex2Dlod(_DisplacementTex1, float4(_DisplacementTex1_ST * i.texcoord.xy + (_DisplacementTex1_ST.zw * (_WaveSpeed * time)), 0.0, 0.0));
                float displacement1 = dot(float3(0.21, 0.72, 0.07), col1.rgb) * _Displacement;

                float4 col2 = tex2Dlod(_DisplacementTex2, float4(_DisplacementTex2_ST * i.texcoord.xy + (_DisplacementTex2_ST.zw * (_WaveSpeed * time)), 0.0, 0.0));
                float displacement2 = dot(float3(0.21, 0.72, 0.07), col2.rgb) * _Displacement;

                float finalDisplacement = displacement1 * _DisplacementBlend + (1.0 - _DisplacementBlend) * displacement2;
                
                float4 newVertexPos = i.vertex + float4(i.normal * finalDisplacement, 0.0);

                output.position = UnityObjectToClipPos(newVertexPos);
                output.texcoord = i.texcoord;

                return output;
            }

            float4 frag(vertexOutput i) : COLOR{
                // Looking up the pixel values for a vertex based on the UV map
                float4 col = tex2D(_DisplacementTex1, _DisplacementTex1_ST * i.texcoord.xy + _DisplacementTex1_ST.zw);

                // Converting the RGB to Luminance (amount of percieved light)
                float luminance = (0.2126 * col.x) + (0.7152 * col.y) + (0.0722 * col.z);

                // Getting the amount of emissivity based on color
                float percievedEmissivity = (luminance) * 0.15 + 0.84;

                // Blending material emissivity with color emissivity
                float finalEmissivity = _MaterialEmissivity * _EmissivityBlendFactor + (1.0 - _EmissivityBlendFactor) * percievedEmissivity;

                // Calculating amount of energy radiated with the Stefan Bolztmann constant
                float radiation = finalEmissivity * _StefanBolztmannConstant * (_MaterialTemperature * _MaterialTemperature * _MaterialTemperature * _MaterialTemperature);

                // Capping the values to a 0 - 1 range
                float mappedRadiation = (radiation * _Gain) + _Level;

                return mappedRadiation;
            }

            ENDCG
        }
    }
}
