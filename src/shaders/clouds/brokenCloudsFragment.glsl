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

    float cloud = texture(uTexture0, uv).r;
    float cloudFlipped = texture(uTexture0, rotateUv(uv, 180.0, vec2(0.5))).r;

    // Invert cloud texture
    float invertedCloud = 1.0 - cloud;
    float invertedCloudFlipped = 1.0 - cloudFlipped;
    float invertedCloudCombined = invertedCloud + invertedCloudFlipped;
    invertedCloudCombined = smoothstep(0.0, 1.0, invertedCloudCombined);
    
    // float invertedCloudHighContrast = pow(invertedCloudFlipped, 2.0);
    // invertedCloudHighContrast = smoothstep(0.0, 1.0, invertedCloudHighContrast);

    // vec3 color = vec3(0.95, 0.96, 0.97);
    vec3 color = vec3(1.0, 1.0, 1.0);

    outColor = vec4(color, invertedCloudCombined);
}