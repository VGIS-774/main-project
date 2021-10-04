using System;
using UnityEngine;
using UnityEngine.Perception.Randomization.Parameters;
using UnityEngine.Perception.Randomization.Randomizers;
using UnityEngine.Perception.Randomization.Samplers;

[Serializable]
[AddRandomizerMenu("Perception/Light Randomizer")]
public class LightRandomizer : Randomizer
{
    public FloatParameter lightIntensityParameter;

    protected override void OnIterationStart()
    {
        var tags = tagManager.Query<LightRandomizerTag>();
        foreach (var tag in tags)
        {
            var light = tag.GetComponent<Light>();
            light.intensity = lightIntensityParameter.Sample();
        }
    }
}
