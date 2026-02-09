#version 300 es

precision mediump float;

uniform vec2 uResolution;
uniform float uTime;
uniform sampler2D uTexture;

out vec4 outColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;

    float cloud = texture(uTexture, uv).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    
    float invertedCloudHighContrast = pow(invertedCloud, 2.0);
    invertedCloudHighContrast = smoothstep(0.0, 1.0, invertedCloudHighContrast);

    vec3 color = vec3(0.95, 0.96, 0.97);

    outColor = vec4(color * invertedCloudHighContrast, invertedCloud);
}