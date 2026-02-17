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

    vec2 speed = vec2(0.02, 0.01);
    vec2 movingUv = uv + speed * uTime;

    movingUv = rotateUv(movingUv, uTime * 0.03, vec2(0.5));
    movingUv = fract(movingUv);

    float smoke = texture(uTexture0, movingUv).r;
    smoke = smoothstep(0.2, 1.0, smoke);

    float opacity = distance(uv, vec2(0.5));
    opacity = smoothstep(0.0, 0.5, opacity);
    smoke *= opacity;

    vec3 color = vec3(0.56, 0.56, 0.57);

    outColor = vec4(color, smoke);
}