#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform float uWind;
uniform sampler2D uTexture0;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Set snow speed and create uv
    vec2 speedFirstLayer = vec2(sin(uTime * 3.0) * 0.008 - uTime * 0.02, uTime * 0.2);
    vec2 speedSecondLayer = vec2(- uTime * 0.1, uTime * 0.2);
    vec2 speedThirdLayer = vec2(sin(uTime * 5.0) * 0.008 - uTime * 0.01, uTime * 0.1);

    // Create moving uvs
    vec2 movingUvFirstLayer = uv * 1.8 + speedFirstLayer;
    vec2 movingUvSecondLayer = uv * 2.0 + speedSecondLayer;
    vec2 movingUvThirdLayer = uv * 3.0 + speedThirdLayer;

    // Snow texture
    float snowFirstLayer = texture(uTexture0, movingUvFirstLayer).r;
    float snowSecondLayer = texture(uTexture0, movingUvSecondLayer).r;
    float snowThirdLayer = texture(uTexture0, movingUvThirdLayer).r;

    // Increase contrast
    snowFirstLayer = pow(snowFirstLayer, 6.0); 
    snowSecondLayer = pow(snowSecondLayer, 6.0); 
    snowThirdLayer = pow(snowThirdLayer, 6.0); 

    // Set color
    vec3 color = vec3(1.0, 1.0, 1.0);
    outColor = vec4(color, snowFirstLayer + snowSecondLayer + snowThirdLayer);
}