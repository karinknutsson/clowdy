#version 300 es

precision mediump float;

uniform float uIntensity;
uniform vec2 uResolution;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    // float opacity = distance(uv, vec2(0.5)) * 1.5;
    float opacity = mod(uv.x * 10.0, 1.0);
    opacity = step(0.8, opacity);
    outColor = vec4(0.0, 0.0, 0.0, opacity);
}