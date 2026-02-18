#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;
uniform sampler2D uTexture1;
uniform sampler2D uTexture2;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Set snow speed and create uv
    vec2 speed = vec2(sin(uTime * 5.0) * 0.008, uTime * 0.1);
    vec2 movingUv = uv + speed;

    // Cloud texture
    float cloud = texture(uTexture0, uv).r;

    // V curve cloud texture
    float vCloud = abs((cloud - 0.5) * 2.0);
    vCloud = mix(1.0, vCloud, 0.1);

    // snow texture: move and stretch vertically
    // vec2 stretchedUv = vec2(movingUv.x * 2.0, movingUv.y * 0.03); 
    float snow = texture(uTexture1, movingUv).r;
    // snow = 1.0 - snow;

    // Increase contrast
    snow = pow(snow, 6.0) * 6.5; 

    // Threshold to create sharper streaks
    // snow = smoothstep(0.3, 1.0, snow);

    // Less opacity
    snow *= 0.5; 

    // Opacity for center view
    float opacity = distance(uv, vec2(0.5)) * 1.5;
    opacity = smoothstep(0.0, 0.7, opacity);

    vec3 color = vec3(1.0, 0.0, 0.0);
    float combinedOpacity = clamp(opacity + snow, 0.0, 1.0);

    // outColor = vec4(color * vCloud, combinedOpacity);
    outColor = vec4(color, snow);
}