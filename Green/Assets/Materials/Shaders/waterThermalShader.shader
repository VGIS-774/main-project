Shader "Custom/Water Thermal"
{
    Properties
    {
        _DisplacementTex1("First Displacement Texture", 2D) = "white" {}
        _DisplacementTex2("Second Displacement Texture", 2D) = "white" {}

        [Space(10)] [Toggle] _isMoving("Moving", Float) = 0

        [Header(Wave Properties)][Space(10)] _WaveSpeed("Speed of water waves", Range(0.0, 1.0)) = 0.5
        _Displacement("Displacement", Float) = 1.0
        _DisplacementBlend("Displacement Blending", Range(0.0, 1.0)) = 0.5

        [Header(Thermal Properties)][Space(10)] _MaterialEmissivity("Emissivity", Range(0.0, 1.0)) = 0.95
        _EmissivityBlendFactor("Blend factor", Range(0.0, 1.0)) = 0.75
        _StefanBolztmannConstant("Stefan-Bolztmann's Constant", Float) = 0.000000056704
        _MaterialTemperature("Material temperature in K", Float) = 300.0

        [Header(Gain control properties)][Space(10)] _Level("Level", Float) = 0.0
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
                float time;

                if (_isMoving) {
                    time = _Time.y;
                }
                else {
                    time = 0.0;
                }

                // Looking up the pixel values for a vertex based on the UV map
                float4 col1 = tex2D(_DisplacementTex1, _DisplacementTex1_ST * i.texcoord.xy + (_DisplacementTex1_ST.zw * (_WaveSpeed * time)));
                float4 col2 = tex2D(_DisplacementTex2, _DisplacementTex2_ST * i.texcoord.xy + (_DisplacementTex2_ST.zw * (_WaveSpeed * time)));

                // Converting the RGB to Luminance (amount of percieved light)
                float luminance1 = (0.2126 * col1.x) + (0.7152 * col1.y) + (0.0722 * col1.z);
                float luminance2 = (0.2126 * col2.x) + (0.7152 * col2.y) + (0.0722 * col2.z);

                // Getting the amount of emissivity based on color
                float percievedEmissivity1 = (luminance1) * 0.15 + 0.84;
                float percievedEmissivity2 = (luminance2) * 0.15 + 0.84;

                // Blending material emissivity with color emissivity
                float finalEmissivity1 = _MaterialEmissivity * _EmissivityBlendFactor + (1.0 - _EmissivityBlendFactor) * percievedEmissivity1;
                float finalEmissivity2 = _MaterialEmissivity * _EmissivityBlendFactor + (1.0 - _EmissivityBlendFactor) * percievedEmissivity2;

                // Calculating amount of energy radiated with the Stefan Bolztmann constant
                float radiation1 = finalEmissivity1 * _StefanBolztmannConstant * (_MaterialTemperature * _MaterialTemperature * _MaterialTemperature * _MaterialTemperature);
                float radiation2 = finalEmissivity2 * _StefanBolztmannConstant * (_MaterialTemperature * _MaterialTemperature * _MaterialTemperature * _MaterialTemperature);

                // Capping the values to a 0 - 1 range
                float mappedRadiation1 = (radiation1 * _Gain) + _Level;
                float mappedRadiation2 = (radiation2 * _Gain) + _Level;

                float finalMappedRadiation = mappedRadiation1 * _DisplacementBlend + (1.0 - _DisplacementBlend) * mappedRadiation2;

                return finalMappedRadiation;
            }

            ENDCG
        }
    }
}
