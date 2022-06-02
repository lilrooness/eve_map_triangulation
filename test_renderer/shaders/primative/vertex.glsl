#version 460 core

#extension GL_ARB_explicit_uniform_location : enable

layout (location=1) in vec4 position;

layout (location=1) uniform mat4 projection;
layout (location=2) uniform mat4 view;

void main() {
    gl_Position = projection * view * vec4(position.xyz, 1.0);
}
