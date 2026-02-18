#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;

out vec4 outColor;

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
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Set speed and rotation based on time and wind
    vec2 speed = vec2(0.002, 0.001);
    speed *= uWind * 0.5;
    float rotation = uTime * 0.003;
    rotation *= uWind * 0.5;

    // Create moving uv
    vec2 movingUv = uv + speed * uTime;
    movingUv = rotateUv(movingUv, rotation, vec2(0.5));
    movingUv = fract(movingUv);

    // Cloud texture
    float cloud = texture(uTexture0, movingUv).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, invertedCloud);
}