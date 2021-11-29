
#include "Lighting.cginc"


struct a2f
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};


struct v2g
{
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
};


struct g2f
{
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float threshold : COLOR0;
};

g2f VertexOutput(float3 pos,float3 normal, float p)
{
	g2f o;
	o.pos = UnityObjectToClipPos(pos);
	o.normal = normalize(UnityObjectToWorldNormal(normal));
	o.threshold = p;
	return o;
}

g2f VoxelizerOutput(float3 pos, float3 centre, float p)
{
	g2f o;
	o.pos = UnityObjectToClipPos(pos);
	o.normal = pos - float4(centre, 0);
	o.threshold = p;
	return o;
}

// vertex shader 
v2g vert(a2f v)
{
	v2g o;
	o.pos = v.vertex;
	o.normal = v.normal;
	return o;
}

//
float _Threshold;
[maxvertexcount(12)]
void geom(triangle v2g inputs[3], inout TriangleStream<g2f> outstream)
{
	if (_Threshold <= 0)
	{

		outstream.Append(VertexOutput(inputs[0].pos, inputs[0].normal, 0));
		outstream.Append(VertexOutput(inputs[1].pos, inputs[1].normal, 0));
		outstream.Append(VertexOutput(inputs[2].pos, inputs[2].normal, 0));
		outstream.RestartStrip();
		return;
	}

	if (_Threshold > 1)
		return;

	// Volizer Transform
	float3 v0 = inputs[0].pos.xyz;
	float3 v1 = inputs[1].pos.xyz;
	float3 v2 = inputs[2].pos.xyz;

	float3 tria_centre = (v0 + v1 + v2) / 3;
	// tangent
	float3 t = normalize(v1 - v0);
	// normal
	float3 n = cross(t, normalize(v2 - tria_centre));
	// sub tangent
	float3 s = cross(t, n);

	float size = 0.1;
	n *= size;
	t *= size;
	s *= size;
	float3 cube_centre = tria_centre - n;

	float param = min(1,_Threshold * 2);

	float3 p0 = lerp(v0, cube_centre + n + s - t, param);
	float3 p1 = lerp(v1, cube_centre + n + s + t, param);
	float3 p2 = lerp(v2, cube_centre + n - s + t, param);
	float3 p3 = lerp(p2, cube_centre + n - s - t, param);

	float3 p4 = lerp(p3, cube_centre - n + s - t, param);
	float3 p5 = lerp(p4, cube_centre - n + s + t, param);
	float3 p6 = lerp(p5, cube_centre - n - s + t, param);
	float3 p7 = lerp(p6, cube_centre - n - s - t, param);

	outstream.Append(VoxelizerOutput(p0, cube_centre, param));
	outstream.Append(VoxelizerOutput(p1, cube_centre, param));
	outstream.Append(VoxelizerOutput(p3, cube_centre, param));
	outstream.Append(VoxelizerOutput(p2, cube_centre, param));
	outstream.Append(VoxelizerOutput(p6, cube_centre, param));
	outstream.Append(VoxelizerOutput(p1, cube_centre, param));
	outstream.Append(VoxelizerOutput(p5, cube_centre, param));
	outstream.Append(VoxelizerOutput(p0, cube_centre, param));
	outstream.Append(VoxelizerOutput(p4, cube_centre, param));
	outstream.Append(VoxelizerOutput(p3, cube_centre, param));
	outstream.Append(VoxelizerOutput(p7, cube_centre, param));
	outstream.Append(VoxelizerOutput(p6, cube_centre, param));
	outstream.Append(VoxelizerOutput(p4, cube_centre, param));
	outstream.Append(VoxelizerOutput(p5, cube_centre, param));


	//outstream.Append(VertexOutput(, inputs[2].normal, param));
	//outstream.Append(VertexOutput(, inputs[2].normal, param));
	//outstream.Append(VertexOutput(, inputs[2].normal, param));
	//outstream.Append(VertexOutput(, inputs[2].normal, param));

	outstream.RestartStrip();

}


// fragment
float4 _Diffuse;

float4 frag(g2f i) :SV_TARGET
{
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.normal, worldLight));

	fixed4 color = fixed4(ambient + diffuse,1.0); 
	
	return lerp(color, float4(0.3, 0.7, 0.5, 1), 0);
}



