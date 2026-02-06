#version 300 es

precision mediump float;

uniform float uIntensity;
uniform vec2 uResolution;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    float opacity = distance(uv, vec2(0.5));
    outColor = vec4(0.7, 0.7, 0.7, opacity);
}