using System;
using UnityEngine;
using System.Linq;
using UnityEngine.Perception.Randomization.Parameters;
using UnityEngine.Perception.Randomization.Randomizers.Utilities;
using UnityEngine.Perception.Randomization.Randomizers;
using UnityEngine.Perception.Randomization.Samplers;

[Serializable]
[AddRandomizerMenu("Perception/Mixamo Randomizer")]
public class MixamoRandomizer : Randomizer
{
    public FloatParameter xPos;
    public FloatParameter zPos;
    public float yPos;

    public FloatParameter xScale;
    public FloatParameter yScale;
    public FloatParameter zScale;

    public IntegerParameter mixamoCount;

    public Vector3Parameter rotation = new Vector3Parameter
    {
        x = new UniformSampler(-5, 5),
        y = new UniformSampler(0, 360),
        z = new UniformSampler(-5, 5)
    };

    public GameObjectParameter prefabs;

    GameObject m_Container;
    GameObjectOneWayCache m_GameObjectOneWayCache;

    protected override void OnAwake()
    {
        m_Container = new GameObject("Foreground Objects");
        m_Container.transform.parent = scenario.transform;
        m_GameObjectOneWayCache = new GameObjectOneWayCache(
            m_Container.transform, prefabs.categories.Select(element => element.Item1).ToArray());
    }

    protected override void OnIterationStart()
    {
        for (int i = 0; i <= mixamoCount.Sample(); i++)
        {
            var instance = m_GameObjectOneWayCache.GetOrInstantiate(prefabs.Sample());
            instance.transform.position = new Vector3(xPos.Sample(), yPos, zPos.Sample());
            instance.transform.localScale = new Vector3(xScale.Sample(), yScale.Sample(), zScale.Sample());
            instance.transform.rotation = Quaternion.Euler(rotation.Sample());
        }
    }

    protected override void OnIterationEnd()
    {
        m_GameObjectOneWayCache.ResetAllObjects();
    }

}
