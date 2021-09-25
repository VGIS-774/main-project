Shader "Custom/VectorDisplacement"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _DisplacementTex("Displacement Texture", 2D) = "white" {}
        _MaxDisplacement("Max Displacement", Float) = 1.0
        [Toggle] _isMoving("is Moving", Float) = 0
        _WaveSpeed("Speed of water waves", Range(0.0, 1.0)) = 0.5
    }

    SubShader
    {
        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            uniform sampler2D _MainTex;
            uniform sampler2D _DisplacementTex;
            uniform float4 _DisplacementTex_ST;
            uniform float _MaxDisplacement;

            float _WaveSpeed;
            float _isMoving;
            float4 col;

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

                float4 col = tex2Dlod(_DisplacementTex, float4(_DisplacementTex_ST * i.texcoord.xy + (_DisplacementTex_ST.zw * (_WaveSpeed * time)), 0.0, 0.0));
                
                float4 newVertexPos = i.vertex + float4(i.normal + col, 0.0);

                output.position = UnityObjectToClipPos(newVertexPos);
                output.texcoord = i.texcoord;

                return output;
            }

            float4 frag(vertexOutput i) : COLOR{
                return tex2D(_MainTex, i.texcoord.xy);
            }

            ENDCG
        }
    }
}
