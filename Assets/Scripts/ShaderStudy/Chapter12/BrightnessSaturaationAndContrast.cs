using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturaationAndContrast : PostEffectsBase
{
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    public Shader briSatConShader;
    private Material briStaConMaterial;
    public Material material
    {
        get 
        {
            briStaConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briStaConMaterial);
            return briStaConMaterial;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material!=null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
