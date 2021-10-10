using System;
using UnityEngine;
using System.Linq;
using UnityEngine.Perception.Randomization.Parameters;
using UnityEngine.Perception.Randomization.Randomizers.Utilities;
using UnityEngine.Perception.Randomization.Randomizers;
using UnityEngine.Perception.Randomization.Samplers;

[AddComponentMenu("Perception/RandomizerTags/ThermalRandomizerTag")]
public class ThermalRandomizerTag : RandomizerTag
{

    private Renderer rend;

    public void SetValues(float emissivity, float blendFactor, float materialTemperatureInK, float level, float gain)
    {
        rend = GetComponent<Renderer>();
        rend.material.SetFloat("_MaterialEmissivity", emissivity);
        rend.material.SetFloat("_EmissivityBlendFactor", blendFactor);
        rend.material.SetFloat("_MaterialTemperature", materialTemperatureInK);
        rend.material.SetFloat("_Level", level);
        rend.material.SetFloat("_Gain", gain);
    }

}
