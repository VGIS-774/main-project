using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Unity.Simulation;
using UnityEngine;
using UnityEngine.AI;

namespace Unity.Simulation
{
    public class PerfStatsManager
{
    private PerfStatsManager()
    {
    }

    private static PerfStatsManager _instance;

    internal List<CollectorBase> collectors;
    internal List<IGlobalProfilerDataDispatcher> globalDispatchers;

    public double DEFAULT_ERROR_SAMPLE_VALUE = Double.NegativeInfinity;
    public float realTimeSinceStartUp;
    
    

    /// <summary>
    /// PerfStatsManager singleton instance to that can enable Start/Stop invoking the collectors. 
    /// </summary>
    public static PerfStatsManager Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new PerfStatsManager();
            }

            return _instance;
        }
    }

    public void SetGlobalDispatchers(List<IGlobalProfilerDataDispatcher> dispatchers)
    {
        globalDispatchers = dispatchers;
    }
    
    /// <summary>
    /// Invoke this method to start profiling by invoking/activating collectors.
    /// </summary>
    public void StartProfiling(List<CollectorBase> collectors)
    {
        this.collectors = collectors;
        foreach (var collector in this.collectors)
        {
            collector.Initialize();
            collector.PopulateEvents();
        }

        Manager.Instance.Tick += (float dt) =>
        {
            realTimeSinceStartUp = Time.realtimeSinceStartup;
            foreach (var c in collectors)
            {
                foreach (var e in c.GetEvents())
                {
                    e.Update(dt);
                }
            }
            InvokeCollectors(dt);
        };
        Manager.Instance.ShutdownNotification += () => DispatchCollectors(true);
    }

    /// <summary>
    /// Inovke this method to stop profiling.
    /// </summary>
    public void StopProfiling() => Manager.Instance.Tick -= InvokeCollectors;

    private void InvokeCollectors(float dt)
    {
        //Update all the count
        Debug.Assert(collectors!=null, "No collectors are assigned.");
        UpdateElapsedTimeOnCollectors(dt);
        DispatchCollectors();
    }

    private void UpdateElapsedTimeOnCollectors(float dt)
    {
        foreach (var collector in collectors)
        {
            collector.simulationElapsedTime += dt;
        }
    }

    /// <summary>
    /// Invoke this function to flush all the events on all the collectors. This will invoke dispatcher on all the collectors.
    /// This call can be slow depending upon the dispatcher implementation.
    /// </summary>
    /// <param name="shuttingDown"></param>
    public void DispatchCollectors(bool shuttingDown = false)
    {
        foreach (var collector in collectors)
        {
            if ((collector.m_Enabled && collector.simulationElapsedTime >= collector.period) || shuttingDown)
            {
                collector.simulationElapsedTime = 0;
                var events = collector.GetEvents();
                var report = ReportingUtils.GetProfilerReport(events, collector.name, collector.category);
                if (globalDispatchers != null && globalDispatchers.Count > 0)
                {
                    foreach(var dispatcher in globalDispatchers)
                        dispatcher.DispatchProfilerReport(report);
                }
                else
                {
                    collector.DispatchCollector(report);
                    collector.CollectorConsumer?.Invoke(report);   
                }
                foreach (var e in events)
                    if (e.resetOnEachSampleCollection)
                        e.Reset();
            }
        }
    }

    /// <summary>
    /// Track API usage for the provided function.
    /// </summary>
    /// <param name="functionName"></param>
    /// <param name="associatedColletorType"></param>
    public void TrackAPIUsage(string functionName, Type associatedColletorType)
    {
        if (collectors == null)
            return;
        var collector = collectors.FirstOrDefault(c => c.GetType() == associatedColletorType);
        if (collector != null)
        {
            var events = collector.GetEvents();
            var counterEvent = (CounterEvent)events.FirstOrDefault(e => e.GetType() == typeof(CounterEvent));
            if (counterEvent == null)
            {
                Log.E(
                    "[Simulation Profiler]: Counter Event is not registered with the collector. Please register the event by call AddEvent in your collector.",
                    true);
            }
            else
            {
                counterEvent.IncrementCount(functionName);
            }
        }
    }

    /// <summary>
    /// Begin sample for the provided event.
    /// </summary>
    /// <param name="functionName"></param>
    public void BeginSample(string functionName, Type associatedCollectorType)
    {
        if (collectors == null)
            return;
        var associatedCollector = collectors.FirstOrDefault(c => c.GetType() == associatedCollectorType);
        string key;
        key = associatedCollector != null
            ? associatedCollector.name + "_" + functionName
            : functionName;

        var samplingEvent = (ProfilerSamplingEvent)associatedCollector.GetEvents().FirstOrDefault(e => e.GetType() == typeof(ProfilerSamplingEvent));
        
        Debug.Assert(samplingEvent != null, "Event is not registered on the provided collectortype. Please go ahead and add in Populate Events");
        
        samplingEvent.BeginSample(key);
    }

    /// <summary>
    /// End Sample for the provided event.
    /// </summary>
    /// <param name="eventName"></param>
    public void EndSample(string eventName, Type associatedCollectorType)
    {
        if (collectors == null)
            return;
        var associatedCollector = collectors.FirstOrDefault(c => c.GetType() == associatedCollectorType);
        var key = associatedCollector != null ? associatedCollectorType.Name + "_" + eventName : eventName;
        var samplingEvent = (ProfilerSamplingEvent)associatedCollector.GetEvents().FirstOrDefault(e => e.GetType() == typeof(ProfilerSamplingEvent));
        
        Debug.Assert(samplingEvent !=null, "No ProfilerSamplingEvent is associated with the provided collector type");
        
        samplingEvent.EndSample(key);
    }

}   
}
