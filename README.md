# Thermal imaging synthetic data

## Table of contents

- [Thermal Shader](#Thermal-shader)
- [Splitting rendering into background and foreground](#Background-layer-and-foreground-layer)
- [Post-Processing effects](#Post-Processing-effects)
- [Example video](#Example-video)

## Thermal shader
Example below showcases the fragment shader of the Thermal shader. The rest of the shader is just a simple texture shader, that does not recieve any light, however the shader does cast shadows.

```SHADERLAB
float4 frag(vertexOutput input) : COLOR{
  // Looking up the pixel values for a vertex based on the UV map
  float4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(input.tex));

  // Converting the RGB to Luminance (amount of percieved light)
  float luminance = dot(float3(0.2126, 0.7152, 0.0722), col.rgb); //(0.2126 * col.x) + (0.7152 * col.y) + (0.0722 * col.z);

  // Getting the amount of emissivity based on color
  float percievedEmissivity = (luminance) * 0.15 + 0.84;

  // Blending material emissivity with color emissivity
  float finalEmissivity = _MaterialEmissivity * _EmissivityBlendFactor + (1.0 - _EmissivityBlendFactor) * percievedEmissivity;
  
  // Calculating amount of energy radiated with the Stefan Bolztmann constant
  float radiation = finalEmissivity * StefanBolztmannConstant * pow(_MaterialTemperature, 4);

  // Manual gain control
  float mappedRadiation = (radiation * _Gain) + _Level;

  // Choose between polarities
  #if !BLACK
    // White-hot
    return mappedRadiation;
  #else
    // Black-hot
    mappedRadiation = 1 - mappedRadiation;
    return mappedRadiation;
  #endif
}
```
## Background layer and foreground layer

## Post-Processing effects

Screen compositing is achieved by blending two textures using the following formula:
>`R = 1 - ((1 - Foreground) * (1 - Background))`

## Example video

Example video:

https://user-images.githubusercontent.com/50104866/136936155-7b429270-fe4d-44f1-9ca1-2247be8acd31.mov


