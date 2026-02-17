#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;
uniform sampler2D uTexture1;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    vec2 speed = vec2(-0.005, 0.2);
    vec2 movingUv = uv + speed * uTime;

    // Cloud texture
    float cloud = texture(uTexture0, uv).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    invertedCloud = pow(invertedCloud, 2.0) * 1.5;

    // Combine original and inverted textures
    float combinedCloud = 1.0 - (cloud * invertedCloud);

    // Rain texture: move and stretch vertically
    vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    float rain = texture(uTexture1, stretchedUv).r;

    // Increase contrast
    rain = pow(rain, 3.0) * 1.5; 

    // Threshold to create sharper streaks
    rain = smoothstep(0.3, 1.0, rain);

    // Less opacity
    rain *= 0.5; 

    // Opacity for center view
    float opacity = distance(uv, vec2(0.5)) * 1.5;
    opacity = smoothstep(0.0, 0.7, opacity);

    vec3 color = vec3(0.85, 0.86, 0.87);
    float combinedOpacity = clamp(opacity + rain, 0.0, 1.0);

    outColor = vec4(color * combinedCloud, combinedOpacity);
}