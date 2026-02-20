#version 300 es

in vec2 aPosition;

uniform float uTime;
uniform float uWind;

out vec2 vUv;
out vec2 vRotatingUv;

vec2 rotateUv(vec2 uv, float angle, vec2 center) {
    uv -= center;
    float s = sin(angle);
    float c = cos(angle);
    uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );
    uv += center;
    return uv;
}

void main() {
    // Set uv from position
    vec2 uv = aPosition * 0.5 + 0.5;

    // Set speed and rotation based on time and wind
    vec2 speed = vec2(-0.002, -0.001);
    speed *= uWind * 0.25;
    float rotation = uTime * 0.003;
    rotation *= uWind * 0.25;

    // Create moving uvs
    vec2 movingUv = uv + speed * uTime;
    vec2 movingUvFlipped = uv + speed * uTime;
    movingUv = rotateUv(movingUv, rotation, vec2(0.5));

    // Position
    gl_Position = vec4(aPosition, 0.0, 1.0);

    // Varying
    vUv = uv;
    vRotatingUv = movingUv;
}