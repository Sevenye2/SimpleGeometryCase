Shader "Sevenye2/SimpleVoxelizer"
{
    Properties
    {
        _Transform("Transform", float) = 0
        _Move("Move",float) = 0
        _SizeTria("Size Triangle", float) = 0
        _SizeCube("Size Cube",float) = 0

        _Color("VoxerLizer Color", COLOR) = (1,0,0,1)

        _TEX1("TEX1",2D) = "black"{}
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
