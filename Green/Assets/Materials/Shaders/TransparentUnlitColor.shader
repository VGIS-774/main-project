Shader "Custom/Transparent Unlit Color" {
    Properties
    {
        _ShadowColor("Shadow color", Color) = (0, 0, 0, 0)
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.6
    }

    SubShader
    {
        Tags {"Queue" = "AlphaTest" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase" }

            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            uniform float _ShadowIntensity;
            uniform float4 _ShadowColor;

            struct vertexOutput
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };

            vertexOutput vert(appdata_base v)
            {
                vertexOutput output;
                output.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(output);

                return output;
            }

            float4 frag(vertexOutput input) : COLOR
            {
                float attenuation = LIGHT_ATTENUATION(input);
                return float4(_ShadowColor.x, _ShadowColor.y, _ShadowColor.z, (1 - attenuation) * _ShadowIntensity);
            }
            ENDCG
        }

    }
    Fallback "VertexLit"
}