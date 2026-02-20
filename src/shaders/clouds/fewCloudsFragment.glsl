#version 300 es

precision mediump float;

uniform sampler2D uTexture0;

in vec2 vRotatingUv;

out vec4 outColor;

void main() {
    // Cloud texture
    float cloud = texture(uTexture0, vRotatingUv).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    invertedCloud = smoothstep(0.3, 1.0, invertedCloud);
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;
    invertedCloud = clamp(invertedCloud, 0.0, 0.8);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, invertedCloud);
}