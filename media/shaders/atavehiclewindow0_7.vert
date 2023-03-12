#version 110

varying vec3 vertColour;
varying vec3 vertNormal;
varying vec2 texCoords;

attribute vec4 boneIndices;
attribute vec4 boneWeights;

uniform mat4 MatrixPalette[60];
uniform float DepthBias;

void main()
{
	vec4 position = vec4(gl_Vertex.xyz, 1.0);
	vec4 normal = vec4(gl_Normal.xyz, 0.0);

	texCoords = gl_MultiTexCoord0.st;

	mat4 boneEffect = mat4(0.0);
	if(boneWeights.x > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.x)] * boneWeights.x;
	if(boneWeights.y > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.y)] * boneWeights.y;
	if(boneWeights.z > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.z)] * boneWeights.z;
	if(boneWeights.w > 0.0)
		boneEffect += MatrixPalette[int(boneIndices.w)] * boneWeights.w;

	normal = boneEffect * normal;
	vertNormal = normal.xyz;
	vertColour = vec3(1.0,1.0,1.0);

	vec4 o = gl_ModelViewProjectionMatrix * boneEffect * position;
	o.z -= DepthBias;
	gl_Position = o;
}