using System;
using UnityEngine;
using UnityEngine.Perception.Randomization.Parameters;
using UnityEngine.Perception.Randomization.Randomizers;
using UnityEngine.Perception.Randomization.Samplers;

[Serializable]
[AddRandomizerMenu("Perception/Thermal Randomizer Video")]
public class ThermalRandomizerVideo : Randomizer
{
    public FloatParameter emissivity;
    public FloatParameter blendFactor;
    public FloatParameter materialTemperatureInK;
    public FloatParameter level;
    public FloatParameter gain;

    public int frameCount = 1;
    private int frameNumber = 0;

    protected override void OnIterationStart()
    {
        if (frameNumber % frameCount == 0)
        {
            var tags = tagManager.Query<ThermalRandomizerTag>();
            foreach (var tag in tags)
            {
                tag.SetValues(emissivity.Sample(), blendFactor.Sample(), materialTemperatureInK.Sample(), level.Sample(), gain.Sample());
            }
        }
        frameNumber++;
    }
}
