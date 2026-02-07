#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    float ash = texture(uTexture, uv).r;
    ash = smoothstep(0.2, 1.0, ash);

    float opacity = distance(uv, vec2(0.5));
    opacity = smoothstep(0.0, 0.5, opacity);
    ash *= opacity;

    vec3 color = vec3(0.0902, 0.1137, 0.1294);

    outColor = vec4(color, ash);
}