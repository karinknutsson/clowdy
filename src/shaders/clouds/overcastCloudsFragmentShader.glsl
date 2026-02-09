#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
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

    vec2 speed = vec2(-0.002, -0.001);
    vec2 movingUv = uv + speed * uTime;

    movingUv = rotateUv(movingUv, uTime * 0.003, vec2(0.5));

    // Cloud texture
    float cloud = texture(uTexture0, movingUv).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;

    // Combine original and inverted textures
    float combinedCloud = 1.0 - (cloud * invertedCloud);

    // Opacity for center view
    float opacity = distance(uv, vec2(0.5)) * 1.5;
    opacity = smoothstep(0.0, 0.7, opacity);

    vec3 color = vec3(0.85, 0.86, 0.87);

    outColor = vec4(color * combinedCloud, opacity);
}