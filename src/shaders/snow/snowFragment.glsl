#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;

out vec4 outColor;

float createSnowLayer(float speedFactor, float timeFactor, vec2 uv, float textureSize) {
    vec2 speed = vec2(speedFactor, timeFactor);
    vec2 movingUv = uv * textureSize + speed;
    float snowTexture = texture(uTexture0, movingUv).r;
    snowTexture = pow(snowTexture, 6.0);
    return snowTexture;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Create snow layers
    float snowFirstLayer = createSnowLayer(sin(uTime * 3.0) * 0.008 - uTime * 0.02, uTime * 0.2, uv, 1.8);
    float snowSecondLayer = createSnowLayer(- uTime * 0.1,  uTime * 0.2, uv, 2.0);
    float snowThirdLayer = createSnowLayer(sin(uTime * 5.0) * 0.008 - uTime * 0.01, uTime * 0.1, uv, 3.0);

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, snowFirstLayer + snowSecondLayer + snowThirdLayer);
}