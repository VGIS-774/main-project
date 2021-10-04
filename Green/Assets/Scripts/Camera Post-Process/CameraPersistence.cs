using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ImageEffectAllowedInSceneView]

public class CameraPersistence: MonoBehaviour
{
    [Header ("Effect material:")]
    public Material persistenceEffect;
    
    // Texture for storing background
    private Texture2D background;

    void Start()
    {
        // Check if everything is okay with the material and shader
        if (null == persistenceEffect || null == persistenceEffect.shader || !persistenceEffect.shader.isSupported)
        {
            enabled = false;
            return;
        }

        background = new Texture2D(0, 0);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        var temporaryTexture = RenderTexture.GetTemporary(source.width, source.height);

        // Pass the previous frame as a texture to the shader
        persistenceEffect.SetTexture("_SecondTex", background);

        // Apply the persistence effect
        Graphics.Blit(source, temporaryTexture, persistenceEffect);

        background = toTexture2D(temporaryTexture);

        Graphics.Blit(temporaryTexture, destination);

        RenderTexture.ReleaseTemporary(temporaryTexture);
    }


    Texture2D toTexture2D(RenderTexture rTex)
    {
        Texture2D tex = new Texture2D(384, 288, TextureFormat.RGB24, false);

        // ReadPixels looks at the active RenderTexture.
        RenderTexture.active = rTex;
        tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
        tex.Apply();
        return tex;
    }
}
