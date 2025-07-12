#version 150

layout(std140) uniform LightmapInfo {
    float AmbientLightFactor;
    float SkyFactor;
    float BlockFactor;
    int UseBrightLightmap;
    float NightVisionFactor;
    float DarknessScale;
    float DarkenWorldFactor;
    float BrightnessFactor;
    vec3 SkyLightColor;
} lightmapInfo;

in vec2 texCoord;

out vec4 fragColor;

float get_brightness(float level) {
    float curved_level = level / (4.0 - 3.0 * level);
    return mix(curved_level, 1.0, lightmapInfo.AmbientLightFactor);
}

vec3 notGamma(vec3 x) {
    vec3 nx = 1.0 - x;
    return 1.0 - nx * nx * nx * nx;
}

void main() {
    float block_brightness = get_brightness(floor(texCoord.x * 16) / 15) * lightmapInfo.BlockFactor;
    float sky_brightness = get_brightness(floor(texCoord.y * 16) / 15) * lightmapInfo.SkyFactor;

    vec3 color = vec3(
        block_brightness + sky_brightness,
        block_brightness + sky_brightness,
        block_brightness + sky_brightness
    );

    if (lightmapInfo.UseBrightLightmap != 0) {
        color = mix(clamp(color, 0.0, 1.0), vec3(0.9), 0.5);
    } else {
        color = mix(color, vec3(0.75), 0.04);
        vec3 darkened_color = color * vec3(0.6, 0.6, 0.6);
        color = mix(color, darkened_color, lightmapInfo.DarkenWorldFactor);
    }

    if (lightmapInfo.NightVisionFactor > 0.0) {
        color = mix(color, vec3(4.0,4.0,4.0), lightmapInfo.NightVisionFactor);
    }
	
    if (lightmapInfo.UseBrightLightmap == 0) {
        color = clamp(color - vec3(lightmapInfo.DarknessScale), 0.0, 1.0);
    }

    vec3 notGamma = notGamma(color);
    color = mix(color, notGamma, lightmapInfo.BrightnessFactor);
    color = mix(color, vec3(0.75), 0.04);
    color = clamp(color, 0.0, 1.0);

    fragColor = vec4(color, 1.0);
}

