#version 110

varying vec3 vertColour;
varying vec3 vertNormal;
varying vec2 texCoords;

uniform mat4 transform;

void main()
{
	vec4 position = vec4(gl_Vertex.xyz, 1);
	vec4 normal = vec4(gl_Normal.xyz, 0);

	texCoords = gl_MultiTexCoord0.st;

	vertNormal = (transform * normal).xyz;
	vertColour = vec3(1,1,1);

	gl_Position = gl_ModelViewProjectionMatrix * transform * position;
}