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

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    // Set snow speed and create uv
    vec2 speedFirstLayer = vec2(sin(uTime * 3.0) * 0.008, uTime * 0.1);
    vec2 speedSecondLayer = vec2(- uTime * 0.1, uTime * 0.2);
    vec2 speedThirdLayer = vec2(sin(uTime * 3.0) * 0.008, uTime * 0.05);

    // Create moving uvs
    vec2 movingUvFirstLayer = uv * 1.2 + speedFirstLayer;
    vec2 movingUvSecondLayer = uv * 1.5 + speedSecondLayer;
    vec2 movingUvThirdLayer = rotateUv(uv * 2.0, 3.14159265, vec2(0.5)) - speedThirdLayer;

    // Snow texture
    float snowFirstLayer = texture(uTexture1, movingUvFirstLayer).r;
    float snowSecondLayer = texture(uTexture1, movingUvSecondLayer).r;
    float snowThirdLayer = texture(uTexture1, movingUvThirdLayer).r;

    // Increase contrast
    snowFirstLayer = pow(snowFirstLayer, 6.0); 
    snowSecondLayer = pow(snowSecondLayer, 6.0); 
    snowThirdLayer = pow(snowThirdLayer, 6.0); 

    // Cloud texture
    float cloud = texture(uTexture0, uv).r;

    // V curve cloud texture
    float vCloud = abs((cloud - 0.5) * 2.0);
    vCloud = mix(1.0, vCloud, 0.1);

    // Opacity for center view
    float opacity = distance(uv, vec2(0.5)) * 1.5;
    opacity = smoothstep(0.0, 0.7, opacity);

    vec3 color = vec3(1.0, 0.0, 0.0);
    float combinedOpacity = clamp(opacity + snowFirstLayer + snowSecondLayer + snowThirdLayer, 0.0, 1.0);

    outColor = vec4(color * vCloud, combinedOpacity);
    // outColor = vec4(color, snow * snowThirdLayer);
    outColor = vec4(color, snowFirstLayer + snowSecondLayer + snowThirdLayer);
}