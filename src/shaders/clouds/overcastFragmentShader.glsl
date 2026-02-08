#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture;

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

    vec2 speed = vec2(0.02, 0.01);
    vec2 movingUv = uv + speed * uTime;

    movingUv = rotateUv(movingUv, uTime * 0.03, vec2(0.5));
    movingUv = fract(movingUv);

    // float cloud = texture(uTexture, movingUv).r;
    float cloud = texture(uTexture, uv).r;
    // cloud = abs((cloud - 0.5) * 2.0);

    // Invert
    float invertedCloud = 1.0 - cloud;

    float combinedCloud = 1.0 - (cloud * invertedCloud);
    // cloud = clamp(cloud, 0.4, 1.0);

    // cloud = smoothstep(0.2, 1.0, cloud);

    // float opacity = distance(uv, vec2(0.5));
    // opacity = smoothstep(0.0, 0.5, opacity);
    // cloud *= opacity;

    vec3 color = vec3(0.85, 0.86, 0.87);

    outColor = vec4(color * combinedCloud, 1.0);
}