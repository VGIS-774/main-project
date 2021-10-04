using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode, ImageEffectAllowedInSceneView]

public class CameraGaussian: MonoBehaviour
{
    public Material guassianEffect;

    void Start()
    {
        // Check if everything is okay with the material and shader
        if (null == guassianEffect || null == guassianEffect.shader || !guassianEffect.shader.isSupported)
        {
            enabled = false;
            return;
        }

    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Create a temperorary render texture in order to use both shader passes
        var temporaryTextureForBlurring = RenderTexture.GetTemporary(source.width, source.height);

        // Apply first guassian pass
        Graphics.Blit(source, temporaryTextureForBlurring, guassianEffect, 0);

        // Apply second guassian pass
        Graphics.Blit(temporaryTextureForBlurring, destination, guassianEffect, 1);

        // Release temporary render texture
        RenderTexture.ReleaseTemporary(temporaryTextureForBlurring);
    }
}
