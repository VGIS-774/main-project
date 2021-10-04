Shader "Custom/Simple unlit color"
{   
    Properties{
         _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass {
            // The value of the LightMode Pass tag must match the ShaderTagId in ScriptableRenderContext.DrawRenderers
            Tags { "LightMode" = "ExampleLightModeTag" "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull back
            LOD 100

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4x4 unity_MatrixVP;
            float4x4 unity_ObjectToWorld;
            float4 _Color;

            struct Attributes
            {
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float4 worldPos = mul(unity_ObjectToWorld, IN.positionOS);
                OUT.positionCS = mul(unity_MatrixVP, worldPos);
                return OUT;
            }

            float4 frag(Varyings IN) : SV_TARGET
            {
                return _Color;
            }

            ENDHLSL
        }
    }
}
