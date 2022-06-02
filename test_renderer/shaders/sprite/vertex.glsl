#version 460 core

#extension GL_ARB_explicit_uniform_location : enable

layout (location=1) in vec4 position;
layout (location=2) in vec2 uv;
layout (location=3) in float rotation;
layout (location=4) in vec2 pivot;

layout (location=1) uniform mat4 projection;
layout (location=2) uniform mat4 view;

out vec2 texUv;

mat4 generateZRotationMatrix(float theta) {
    return mat4(
        cos(theta), sin(theta), 0.0, 0.0,
        -sin(theta), cos(theta), 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    );
}

mat4 generateTranslationMatrix(vec3 t) {
    return mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        t.x, t.y, t.z, 1.0
    );
}

void main() {
    texUv = uv;
    vec3 pivotR3 = vec3(pivot.xy, 0.0);

    mat4 rotationMatrix = generateZRotationMatrix(rotation);
    mat4 moveToOriginMatrix = generateTranslationMatrix(-pivotR3.xyz);
    mat4 moveBackMatrix = generateTranslationMatrix(pivotR3.xyz);

    vec4 rotatedPosition = moveToOriginMatrix * vec4(position.xyz, 1.0);
    rotatedPosition = rotationMatrix * rotatedPosition;
    rotatedPosition = moveBackMatrix * rotatedPosition;

    gl_Position = projection * view * vec4(rotatedPosition.xyz, 1.0);
}
