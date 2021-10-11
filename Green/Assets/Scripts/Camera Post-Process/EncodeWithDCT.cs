// Saves screenshot as JPG file.
using System.Collections;
using System.IO;
using UnityEngine;

public class EncodeWithDCT : MonoBehaviour
{
    [SerializeField, Range(1, 100)]
    public int quality = 75;
    
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Texture2D tex = compressDCT(source);

        Graphics.Blit(tex, destination);

        Object.Destroy(tex);
    }

    Texture2D compressDCT(RenderTexture input)
    {
        // Get the rendertexture dimensions
        int width = input.width;
        int height = input.height;

        // Create a new texture to read the pixels into
        Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, false);

        // Read the pixels from the rendertexture to the texture
        tex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
        tex.Apply();

        // Encode the texture in jpg format using DCT function
        byte[] bytes = tex.EncodeToJPG(quality);

        // Load the compressed data into a texture
        tex.LoadImage(bytes);
        tex.Apply();

        return tex;
    }
}