#version 460 core

out vec4 LFragment;

in vec2 texUv;

uniform sampler2D sampler;

void main() {
    LFragment = texture(sampler, texUv);
}
