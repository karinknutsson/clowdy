#version 300 es

precision mediump float;

uniform sampler2D uTexture0;
uniform vec3 uColor;

in vec2 vRotatingUv;

out vec4 outColor;

void main() {
    // Create flipped uv
    vec2 vRotatingUvFlipped = 1.0 - vRotatingUv;

    // Cloud textures
    float cloud = texture(uTexture0, vRotatingUv).r;
    float cloudFlipped = texture(uTexture0, vRotatingUvFlipped).r;
    float cloudCombined = cloud * cloudFlipped;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloudCombined;
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;
    invertedCloud = clamp(invertedCloud, 0.0, 1.0);

    // Set color
    // vec3 color = vec3(1.0, 1.0, 1.0);
    vec3 color = vec3(0.29, 0.28, 0.3);

    outColor = vec4(color, invertedCloud);
}