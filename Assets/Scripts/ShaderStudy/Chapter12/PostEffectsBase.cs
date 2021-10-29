using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (isSupported == false)
        {
            NotSupportedException();
        }
    }

    private void NotSupportedException()
    {
        enabled = false;
    }

    private bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            return false;
        }
        return true;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
        {
            return null;
        }
        if (shader.isSupported && material && material.shader ==shader)
        {
            return material;
        }
        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
        }
    }
}
