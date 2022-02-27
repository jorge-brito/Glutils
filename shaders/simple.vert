#version 450 core

layout(location = 0) in vec2 aPosition;
layout(location = 1) in vec3 aColor;

uniform mat4 uView;
uniform mat4 uModel;
uniform mat4 uProj;

out vec3 a_color;

void main()
{
   a_color = aColor;
   gl_Position = uProj * uView * uModel * vec4(aPosition, 5.0, 1.0);
}