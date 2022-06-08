#version 460 core

out vec4 LFragment;

in vec3 color;

void main() {
    // LFragment = vec4(1.0, 1.0, 1.0, 1.0);
    LFragment = vec4(color.xyz, 1.0);
}
