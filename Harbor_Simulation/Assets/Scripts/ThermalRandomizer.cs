using System;
using UnityEngine;
using UnityEngine.Perception.Randomization.Parameters;
using UnityEngine.Perception.Randomization.Randomizers;
using UnityEngine.Perception.Randomization.Samplers;

[Serializable]
[AddRandomizerMenu("Perception/Thermal Randomizer")]
public class ThermalRandomizer : Randomizer
{
    public FloatParameter emissivity;
    public FloatParameter blendFactor;
    public FloatParameter materialTemperatureInK;
    public FloatParameter level;
    public FloatParameter gain;

    protected override void OnIterationStart()
    {
        var tags = tagManager.Query<ThermalRandomizerTag>();
        foreach (var tag in tags)
        {
            tag.SetValues(emissivity.Sample(), blendFactor.Sample(), materialTemperatureInK.Sample(), level.Sample(), gain.Sample());
        }
    }
}
