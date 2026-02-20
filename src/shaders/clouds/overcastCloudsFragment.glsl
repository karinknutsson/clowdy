#version 300 es

precision mediump float;

uniform sampler2D uTexture0;

in vec2 vUv;
in vec2 vRotatingUv;

out vec4 outColor;

void main() {
    // Cloud texture
    float stillCloud = texture(uTexture0, vec2(vUv.x + 2.05, vUv.y + 0.45) * 0.3).r;
    stillCloud = smoothstep(0.3, 1.0, stillCloud);
    float movingCloud = texture(uTexture0, vRotatingUv).r;

    // V curve cloud texture
    float vCurveCloud = abs((movingCloud - 0.5) * 2.0);
    vCurveCloud = mix(1.0, vCurveCloud, 0.1);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color * vCurveCloud, stillCloud);
}