using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode, ImageEffectAllowedInSceneView]

public class ProgressiveDownsample: MonoBehaviour
{
    [Range(1, 16)]
    public int iterations = 1;

    RenderTexture[] textures = new RenderTexture[16];

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int width = source.width / 2;
        int height = source.height / 2;
        RenderTextureFormat format = source.format;

        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, format);
        Graphics.Blit(source, currentDestination);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        for (;i < iterations; i++)
        {
            width /= 2;
            height /= 2;

            if (height < 2)
            {
                break;
            }

            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
            Graphics.Blit(currentSource, currentDestination);
            currentSource = currentDestination;
        }

        for (i -= 2; i >= 0; i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        Graphics.Blit(currentSource, destination);
    }
}
