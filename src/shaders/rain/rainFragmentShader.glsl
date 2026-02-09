#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture0;
uniform sampler2D uTexture1;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    vec2 speed = vec2(0.02, 0.01);
    vec2 movingUv = uv + speed * uTime;

    float rain = texture(uTexture0, uv).r;
    rain = smoothstep(0.2, 1.0, rain);

    float opacity = distance(uv, vec2(0.5));
    opacity = smoothstep(0.0, 0.5, opacity);
    rain *= opacity;

    vec3 color = vec3(0.0902, 0.1137, 0.1294);

    outColor = vec4(1.0, 0.0, 0.0, rain);
}