using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ImageEffectAllowedInSceneView]

public class CameraRandomNoise: MonoBehaviour
{
    public Material randomNoiseEffect;

    void Start()
    {
        // Check if everything is okay with the material and shader
        if (null == randomNoiseEffect || null == randomNoiseEffect.shader || !randomNoiseEffect.shader.isSupported)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Apply random noise by taking source render texture and applying the effect on it
        Graphics.Blit(source, destination, randomNoiseEffect);
    }
}
