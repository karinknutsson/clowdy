#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform vec2 uColor;
uniform sampler2D uCloudTexture;
uniform sampler2D uAshTexture;
uniform sampler2D uSmokeTexture;
uniform sampler2D uRainTexture;

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

    vec2 speed = vec2(-0.002, -0.001);
    vec2 movingUv = uv + speed * uTime;

    movingUv = rotateUv(movingUv, uTime * 0.003, vec2(0.5));

    // Cloud texture
    float cloud = texture(uTexture0, movingUv).r;

    // V curve cloud texture
    float vCloud = abs((cloud - 0.5) * 2.0);
    vCloud = mix(1.0, vCloud, 0.1);

    // Opacity for center view
    float opacity = pow(distance(uv, vec2(0.5)), 1.2)  * 1.6;
    opacity = smoothstep(0.0, 0.5, opacity);

    vec3 color = vec3(1.0, 1.0, 1.0);

    outColor = vec4(color * vCloud, opacity);
    
}