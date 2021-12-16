Shader "Thermal shader" {
	Properties{
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		[Toggle(BLACK)] _isHotBlack("Hot black", Float) = 0

		[Header(Thermal Properties)] _MaterialEmissivity("Emissivity", Range(0.0, 1.0)) = 0.95
		_EmissivityBlendFactor("Blend factor", Range(0.0, 1.0)) = 0.31
		_MaterialTemperature("Material temperature in K", Float) = 300.5

		[Header(Gain Control)] _Level("Level", Float) = -20.0
		_Gain("Gain", Float) = 0.05
	
	}

	SubShader{
		Pass {
			Name "Thermal Pass"
			CGPROGRAM

			#pragma vertex vert  
			#pragma fragment frag 

			#pragma shader_feature BLACK

			#define StefanBolztmannConstant 0.000000056704

			// Thermal properties
			float _MaterialEmissivity;
			float _EmissivityBlendFactor;
			float _MaterialTemperature;

			// Gain control properties
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

			float4 frag(vertexOutput input) : COLOR {

				// Looking up the pixel values for a vertex based on the UV map
				float4 col = tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);

				// Converting the RGB to Luminance (amount of percieved light)
				float luminance = dot(float3(0.2126, 0.7152, 0.0722), col.rgb); //(0.2126 * col.x) + (0.7152 * col.y) + (0.0722 * col.z);

				// Getting the amount of emissivity based on color
				float percievedEmissivity = (luminance) * 0.15 + 0.84;

				// Blending material emissivity with color emissivity
				float finalEmissivity = _MaterialEmissivity * _EmissivityBlendFactor + (1.0 - _EmissivityBlendFactor) * percievedEmissivity;// lerp(_MaterialEmissivity, percievedEmissivity, _EmissivityBlendFactor);

				// Calculating amount of energy radiated with the Stefan Bolztmann constant
				float radiation = finalEmissivity * StefanBolztmannConstant * pow(_MaterialTemperature, 4);

				// Manual gain control
				float mappedRadiation = (radiation * _Gain) + _Level;

				#if !BLACK
					return mappedRadiation;
				#else
					mappedRadiation = 1 - mappedRadiation;
					return mappedRadiation;
				#endif
			}

		ENDCG
		}
	}

	Fallback "Unlit/Texture"
}