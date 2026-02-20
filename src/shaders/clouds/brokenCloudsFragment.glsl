#version 300 es

precision mediump float;

uniform sampler2D uTexture0;

in vec2 vRotatingUv;

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
    // Create flipped uv
    vec2 vRotatingUvFlipped = rotateUv(vRotatingUv, 3.14159265, vec2(0.5));

    // Cloud textures
    float cloud = texture(uTexture0, vRotatingUv).r;
    float cloudFlipped = texture(uTexture0, vRotatingUvFlipped).r;
    float cloudCombined = cloud * cloudFlipped;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloudCombined;
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;
    invertedCloud = clamp(invertedCloud, 0.0, 0.8);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, invertedCloud);
}