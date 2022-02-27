#version 450 core

out vec4 FragColor;
in vec3 a_color;

uniform float uTime;

void main() 
{
   float r = cos(uTime) * 2 + 1;
   float g = sin(uTime) * 2 + 1;
   float b = sin(uTime) * 2 + 1;
   vec3 color = vec3(r, g, b);
   FragColor = vec4(a_color * color, 1.0);
}