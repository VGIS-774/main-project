using System;
using UnityEngine;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]

public class tintComputeScript : MonoBehaviour
{

    public ComputeShader shader;
    public Color color = new Color(1.0f, 1.0f, 1.0f, 1.0f);

    private RenderTexture tempSource = null;
    // we need this intermediate render texture to access the data   
    private RenderTexture tempDestination = null;
    // we need this intermediate render texture for two reasons:
    // 1. destination of OnRenderImage might be null 
    // 2. we cannot set enableRandomWrite on destination
    private int handleTintMain;

    void Start()
    {
        if (null == shader)
        {
            Debug.Log("Shader missing.");
            enabled = false;
            return;
        }

        handleTintMain = shader.FindKernel("TintMain");

        if (handleTintMain < 0)
        {
            Debug.Log("Initialization failed.");
            enabled = false;
            return;
        }
    }

    void OnDestroy()
    {
        if (null != tempSource)
        {
            tempSource.Release();
            tempSource = null;
        }

        if (null != tempDestination)
        {
            tempDestination.Release();
            tempDestination = null;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (null == shader || handleTintMain < 0 || null == source)
        {
            Graphics.Blit(source, destination); // just copy
            return;
        }

        // do we need to create a new temporary source texture?
        if (null == tempSource || source.width != tempSource.width || source.height != tempSource.height)
        {
            if (null != tempSource)
            {
                tempSource.Release();
            }

            tempSource = new RenderTexture(source.width, source.height, source.depth);
            tempSource.Create();
        }

        // copy source pixels
        Graphics.Blit(source, tempSource);

        // do we need to create a new temporary destination render texture?
        if (null == tempDestination || source.width != tempDestination.width || source.height != tempDestination.height)
        {
            if (null != tempDestination)
            {
                tempDestination.Release();
            }

            tempDestination = new RenderTexture(source.width, source.height, source.depth);
            tempDestination.enableRandomWrite = true;
            tempDestination.Create();
        }

        // call the compute shader
        shader.SetTexture(handleTintMain, "Source", tempSource);
        shader.SetTexture(handleTintMain, "Destination", tempDestination);
        shader.SetVector("Color", (Vector4)color);
        shader.Dispatch(handleTintMain, (tempDestination.width + 7) / 8, (tempDestination.height + 7) / 8, 1);

        // copy the result
        Graphics.Blit(tempDestination, destination);
    }
}