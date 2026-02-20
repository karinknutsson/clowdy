#version 300 es

precision mediump float;

uniform sampler2D uTexture0;

in vec2 vUv;
in vec2 vRotatingUv;

out vec4 outColor;

void main() {
    // Ash texture
    float ash = texture(uTexture0, vRotatingUv).r;
    ash = smoothstep(0.2, 1.0, ash);

    // Opacity for center view
    float opacity = distance(vUv, vec2(0.5));
    opacity = smoothstep(0.0, 0.5, opacity);
    ash *= opacity;

    // Set color
    vec3 color = vec3(0.0902, 0.1137, 0.1294);
    outColor = vec4(color, ash);
}