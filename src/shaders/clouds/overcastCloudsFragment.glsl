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

    // Set speed and rotation based on time and wind
    vec2 speed = vec2(-0.002, -0.001);
    speed *= uWind * 0.25;
    float rotation = uTime * 0.003;
    rotation *= uWind * 0.25;

    // Create moving uv
    vec2 movingUv = uv + speed * uTime;
    movingUv = rotateUv(movingUv, rotation, vec2(0.5));

    // Cloud texture
    // float stillCloud = texture(uTexture0, vec2(uv.x + 0.6, uv.y - 0.6) * 0.9).r;
    float stillCloud = texture(uTexture0, vec2(uv.x + 2.05, uv.y + 0.45) * 0.3).r;
    stillCloud = smoothstep(0.3, 1.0, stillCloud);
    float movingCloud = texture(uTexture0, movingUv).r;

    // V curve cloud texture
    float vCurveCloud = abs((movingCloud - 0.5) * 2.0);
    vCurveCloud = mix(1.0, vCurveCloud, 0.1);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color * vCurveCloud, stillCloud);
}