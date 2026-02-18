#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;
// uniform sampler2D uTexture1;

out vec4 outColor;

float createRainLayer(float speedFactor, float timeFactor, vec2 uv, float textureSize) {
    vec2 speed = vec2(speedFactor, timeFactor);
    vec2 movingUv = uv * textureSize + speed;
    vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    float rainTexture = texture(uTexture0, stretchedUv).r;
    rainTexture = pow(rainTexture, 3.0) * 1.5;
    return rainTexture;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    float rainLayer = createRainLayer(- 0.005 * uTime, 0.2 * uTime, uv, 2.0);

    // Set rain speed and create uv
    // vec2 speed = vec2(-0.005, 0.2) * uTime;
    // vec2 movingUv = uv * 2.0 + speed;


    // // Rain texture: move and stretch vertically
    // vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    // float rain = texture(uTexture0, stretchedUv).r;

    // // Increase contrast
    // rain = pow(rain, 3.0) * 1.5; 

    // Threshold to create sharper streaks
    // rain = smoothstep(0.3, 1.0, rain);

    // Less opacity
    // rain *= 0.5; 


    // Set color
    // vec3 color = vec3(0.85, 0.86, 0.87);
    // outColor = vec4(color * vCloud, combinedOpacity);
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, rainLayer);
}