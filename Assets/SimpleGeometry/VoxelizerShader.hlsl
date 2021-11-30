
#include "Lighting.cginc"

float Random(float x) {
	return frac(52.9829189f
		* frac(x * 0.06711056f
			+ sin(x*  x * 0.00583715f)));
}

float RandomN11(float x) {
	return 2 * Random(x) - 0.5;
}

struct a2f
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float2 texcoord : TEXCOORD0;
};


struct v2g
{
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float2 uv: TEXCOORD0;
};


struct g2f
{
	float4 pos : SV_POSITION;
	float threshold : COLOR0;
	float2 uv1: TEXCOORD1;

};

g2f VertexOutput(float3 pos)
{
	g2f o;
	o.pos = UnityObjectToClipPos(pos);
	o.uv1 = 0;
	o.threshold = 0;
	return o;
}

g2f VoxelizerOutput(float3 pos, float2 uv1, float p)
{
	g2f o;
	o.pos = UnityObjectToClipPos(pos);
	o.threshold = p;
	o.uv1 = uv1;
	return o;
}

// vertex shader 
v2g vert(a2f v)
{
	v2g o;
	o.pos = v.vertex;
	o.normal = v.normal;
	o.uv = v.texcoord;
	return o;
}

//
float _Move;
float _SizeTria;
float _SizeCube;
float _Transform;
[maxvertexcount(14)]
void geom(triangle v2g inputs[3],uint pid: SV_PrimitiveID, inout TriangleStream<g2f> outstream)
{
	float3 v0 = inputs[0].pos.xyz;
	float3 v1 = inputs[1].pos.xyz;
	float3 v2 = inputs[2].pos.xyz;

	float2 uv0 = inputs[0].uv;
	float2 uv1 = inputs[1].uv;
	float2 uv2 = inputs[2].uv;

	float3 n0 = inputs[0].normal;
	float3 n1 = inputs[1].normal;
	float3 n2 = inputs[2].normal;

	float3 tria_centre = (v0 + v1 + v2) / 3;

	float flag = Random(pid * 3);
	if (_Transform <= 0)
	{
		outstream.Append(VertexOutput(v0));
		outstream.Append(VertexOutput(v1));
		outstream.Append(VertexOutput(v2));
		outstream.RestartStrip();
		return;
	}

	// some surface just fly away and reduce size.
	if (flag < 0.5)
	{
		float reduce_p = clamp(0, 1, _SizeTria * (Random(pid) + 1));
		tria_centre += n2;
		outstream.Append(VertexOutput(lerp(v0, tria_centre, reduce_p)));
		outstream.Append(VertexOutput(lerp(v1, tria_centre, reduce_p)));
		outstream.Append(VertexOutput(lerp(v2, tria_centre, reduce_p)));
		outstream.RestartStrip();
		return;
	}


	if (_SizeCube < 0 | flag < 0.8)
		return;

	// cube transform
	float seed = Random(pid * 8);
	tria_centre += tria_centre + n1 * (2 *seed -0.3) * clamp(0, 1, sqrt(_Move)) * 0.3;
	// tangent , normal , subtangent
	float axis_p = clamp(0, 1, _Transform * 0.8 );
	float3 t = lerp(normalize(v1 - v0), float3(1, 0, 0), axis_p);
	float3 n = normalize(cross(t, v2 - tria_centre));
	float3 s = cross(t, n);
	n = cross(t, s);

	float size = seed * _SizeCube * 0.05;
	n *= size;
	t *= size;
	s *= size;
	float3 cube_centre = tria_centre - n;

	float cube_p = clamp(0, 1, _Transform);

	float3 p0 = lerp(v0, cube_centre + n + s - t, cube_p);
	float3 p1 = lerp(v1, cube_centre + n + s + t, cube_p);
	float3 p2 = lerp(v2, cube_centre + n - s + t, cube_p);
	float3 p3 = lerp(p2, cube_centre + n - s - t, cube_p);

	float3 p4 = lerp(p0, cube_centre - n + s - t, cube_p);
	float3 p5 = lerp(p1, cube_centre - n + s + t, cube_p);
	float3 p6 = lerp(p2, cube_centre - n - s + t, cube_p);
	float3 p7 = lerp(p3, cube_centre - n - s - t, cube_p);

	outstream.Append(VoxelizerOutput(p0, float2(0, 0), cube_p));
	outstream.Append(VoxelizerOutput(p1, float2(1, 0), cube_p));
	outstream.Append(VoxelizerOutput(p3, float2(0, 1), cube_p));
	outstream.Append(VoxelizerOutput(p2, float2(1, 1), cube_p));
	outstream.Append(VoxelizerOutput(p6, float2(1, 0), cube_p));
	outstream.Append(VoxelizerOutput(p1, float2(0, 1), cube_p));
	outstream.Append(VoxelizerOutput(p5, float2(0, 0), cube_p));
	outstream.Append(VoxelizerOutput(p0, float2(1, 1), cube_p));
	outstream.Append(VoxelizerOutput(p4, float2(1, 0), cube_p));
	outstream.Append(VoxelizerOutput(p3, float2(0, 1), cube_p));
	outstream.Append(VoxelizerOutput(p7, float2(0, 0), cube_p));
	outstream.Append(VoxelizerOutput(p6, float2(1, 0), cube_p));
	outstream.Append(VoxelizerOutput(p4, float2(0, 1), cube_p));
	outstream.Append(VoxelizerOutput(p5, float2(1, 1), cube_p));

	outstream.RestartStrip();

}


// fragment
sampler2D _TEX1;
float4 _Color;
float4 frag(g2f i) :SV_TARGET
{
	fixed4 color0 = _Color;
	fixed4 color1 = tex2D(_TEX1, i.uv1);

	return lerp(color0, color1, clamp(0, 1, i.threshold * 2));
}



