#version 300 es

precision mediump float;

uniform sampler2D uTexture0;

in vec2 vUv;
in vec2 vRotatingUv;

out vec4 outColor;

void main() {
        // Smoke texture
    float smoke = texture(uTexture0, vRotatingUv).r;
    smoke = smoothstep(0.2, 1.0, smoke);

    // Opacity for center view
    float opacity = distance(vUv, vec2(0.5));
    opacity = smoothstep(0.0, 0.5, opacity);
    smoke *= opacity;

    // Set color
    vec3 color = vec3(0.56, 0.56, 0.57);
    outColor = vec4(color, smoke);
}