using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class composite : MonoBehaviour
{
    public RenderTexture rtex;

    public Material mat;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetTexture("_SecondTex", rtex);

        Graphics.Blit(source, destination, mat);
    }
}
