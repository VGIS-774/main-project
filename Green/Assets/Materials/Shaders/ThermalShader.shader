Shader "Custom/Thermal shader" {
	Properties{
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}

		[Header(Blur properties)][Space(10)] _Strenght("Amount of Blur", Range(0.0, 0.1)) = 0.0
		[KeywordEnum(Low, Medium, High)] _Samples("Sample amount", Float) = 0
		_StandardDev("Standard deviation", Range(0.0, 0.1)) = 0.02

		[Header(Thermal Properties)][Space(10)] _MaterialEmissivity("Emissivity", Range(0.0, 1.0)) = 0.95
		_EmissivityBlendFactor("Blend factor", Range(0.0, 1.0)) = 0.75
		_MaterialTemperature("Material temperature in K", Float) = 300.0

		[Header(Gain Control)][Space(5)] _Level("Level", Float) = 0.0
		_Gain("Gain", Float) = 0.0

	}

	SubShader{
		// First pass for vertical blurring
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
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

			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;

			float _Strenght;
			float _StandardDev;

			vertexOutput vert(vertexInput input) {
				vertexOutput output;

				output.tex = input.texcoord;

				output.pos = UnityObjectToClipPos(input.vertex);
				return output;
			}

			float4 frag(vertexOutput input) : COLOR {
				float4 col = 0;
				float sum = 0;

				if (_StandardDev == 0) {
					return tex2D(_MainTex, input.tex);
				}

				float squaredSTD = _StandardDev * _StandardDev;

				for (float i = 0; i < SAMPLES; i++) {

					float offset = (i / (SAMPLES - 1) - 0.5) * _Strenght;

					float2 uv = input.tex + float2(offset, 0);

					float gaussian = (1 / sqrt(2 * PI * squaredSTD) * pow(E, -(offset * offset) / (2 * squaredSTD)));

					sum += gaussian;
					col += tex2D(_MainTex, uv) * gaussian;
				}

				col = col / sum;
				return col;
			}
			ENDCG
		}

		GrabPass{ "_GrabTexture" }

		Pass {
			CGPROGRAM

			#pragma vertex vert  
			#pragma fragment frag 
			#pragma shader_feature BLACK

			#include "UnityCG.cginc"

			#define StefanBolztmannConstant 0.000000056704

			// Thermal properties
			float _MaterialEmissivity;
			float _EmissivityBlendFactor;
			float _MaterialTemperature;

			// Gain control properties
			float _Level;
			float _Gain;

			sampler2D _GrabTexture;

			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD1;
			};

			vertexOutput vert(vertexInput input) {
				vertexOutput output;

				output.tex = input.texcoord;

				output.pos = UnityObjectToClipPos(input.vertex);
				output.tex = ComputeGrabScreenPos(output.pos);

				return output;
			}

			float4 frag(vertexOutput input) : COLOR{

				// Looking up the pixel values for a vertex based on the UV map
				float4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(input.tex));

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
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}

	Fallback "Unlit/Texture"
}