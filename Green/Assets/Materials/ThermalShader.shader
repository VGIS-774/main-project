Shader "Thermal shader" {
	Properties{
		_MainTex("Texture Image", 2D) = "white" {}
		_MaterialEmissivity("Emissivity", Range(0.0, 1.0)) = 0.95
		_EmissivityBlendFactor("Blend factor", Range(0.0, 1.0)) = 0.75
		_StefanBolztmannConstant("Stefan-Bolztmann's Constant", Float) = 0.000000056704//5.6704E-08
		_MaterialTemperature("Material temperature in K", Float) = 300.0
		_Level("Level", Float) = 0.0
		_Gain("Gain", Float) = 0.0
	}

	SubShader {
		Pass {

			CGPROGRAM

			#pragma vertex vert  
			#pragma fragment frag 

			float _MaterialEmissivity;
			float _EmissivityBlendFactor;
			float _StefanBolztmannConstant;
			float _MaterialTemperature;
			float _Level;
			float _Gain;

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};

			vertexOutput vert(vertexInput input) {
				vertexOutput output;

				output.tex = input.texcoord;

				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR{

				// Looking up the pixel values for a vertex based on the UV map
				float4 col = tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);

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

	Fallback "Unlit/Texture"
}