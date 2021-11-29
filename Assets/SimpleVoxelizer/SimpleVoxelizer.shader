Shader "Sevenye2/SimpleVoxelizer"
{
    Properties
    {
        _Diffuse("Diffuse", COLOR) = (1,1,1,1)

        _Threshold("Threshold", float) = 0

        _VoxelizerColor("_VoxerLizer Color", COLOR) = (1,0,0,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            CGPROGRAM

            #include "UnityCG.cginc"
            #include "VoxelizerShader.hlsl"
            
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            ENDCG
        }
    }
}
