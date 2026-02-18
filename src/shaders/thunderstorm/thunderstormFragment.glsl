#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;
uniform sampler2D uTexture1;

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

float createRainLayer(float speedFactor, float timeFactor, vec2 uv, float textureSize) {
    vec2 speed = vec2(speedFactor, timeFactor);
    vec2 movingUv = uv * textureSize + speed;
    vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    float rainTexture = texture(uTexture1, stretchedUv).r;
    rainTexture = pow(rainTexture, 6.0);
    return rainTexture;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Create rain layers
    float rainFirstLayer = createRainLayer(- 0.007 * uTime, 0.4 * uTime, uv, 1.2);
    float rainSecondLayer = createRainLayer(- 0.006 * uTime, 0.3 * uTime, uv, 1.6);
    float rainThirdLayer = createRainLayer(- 0.005 * uTime, 0.2 * uTime, uv, 2.0);
    float rain = rainFirstLayer + rainSecondLayer + rainThirdLayer;

    // Set speed and rotation based on time and wind
    vec2 speed = vec2(0.002, 0.001);
    speed *= uWind * 0.5;
    float rotation = uTime * 0.003;
    rotation *= uWind * 0.5;

    // Create moving uv
    vec2 movingUv = uv + speed * uTime;
    movingUv = rotateUv(movingUv, rotation, vec2(0.5));

    // Cloud texture
    float cloud = 1.0 - texture(uTexture0, movingUv).r;

    // Opacity for center view
    float opacity = pow(distance(uv, vec2(0.5)), 2.8)  * 2.6;
    opacity = smoothstep(0.0, 0.5, opacity);
    float combinedOpacity = clamp(opacity + rainFirstLayer + rainSecondLayer + rainThirdLayer, 0.0, 1.0);

    // Set color
    vec3 darkColor = vec3(0.11, 0.09, 0.15);
    vec3 lightColor = vec3(0.9, 0.85, 0.95);
    // vec3 color = vec3(1.0, 1.0, 1.0);
    vec3 blendedColor = mix(darkColor, lightColor, cloud);
    outColor = vec4(blendedColor, combinedOpacity);
}