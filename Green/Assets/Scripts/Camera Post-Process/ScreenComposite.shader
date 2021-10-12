Shader "Custom/Screen Composite"
{
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector] _SecondTex("Second texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off 
        ZWrite Off 
        ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            vertexOutput vert(vertexInput i)
            {
                vertexOutput o;
                o.position = UnityObjectToClipPos(i.vertex);
                o.texcoord = i.texcoord;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _SecondTex;

            float4 frag (vertexOutput i) : SV_Target
            {
                //Sample both of the textures
                float4 image = tex2D(_MainTex, i.texcoord);
                float4 mask = tex2D(_SecondTex, i.texcoord);

                float4 col = float4(0.0, 0.0, 0.0, 0.0);

                // Apply screen blending mode formula: 
                col.rgb = 1 - ((1 - mask.rgb) * (1 - image.rgb) / 1);
                return col;
            }
            ENDCG
        }
    }
}
