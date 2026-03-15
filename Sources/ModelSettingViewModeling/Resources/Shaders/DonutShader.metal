//===----------------------------------------------------------------------===//
//
// This source file is part of the ModelSettingViewModeling open source project
//
// Copyright (c) 2026 David C. Vasquez and the ModelSettingViewModeling project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See the project's LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#include <metal_stdlib>
using namespace metal;

#include <SwiftUI/SwiftUI_Metal.h>
using namespace SwiftUI;

[[stitchable]] half4 donutShader(
    float2 position,        // Position in pixels
    SwiftUI::Layer layer,
    float2 size,            // Size of target layer in pixels
    float2 center,          // Center of target layer in UV (0-1)
    float radius,           // Radius in UV space (0-0.5)
    float refraction,       // Refraction strength (0.5-2.0)
    float thickness,        // Refraction thickness
    float shadowOpacity,    // Shadow opacity (0.0-1.0)
    float shadowOffset,     // Shadow offset distance (0.00-0.10)
    float shadowBlur,       // Shadow blur amount (0.00-0.10)
    float edgeThickness,    // Rim light thickness (0.01-0.9)
    float chromaticAmount   // Chromatic aberration intensity (0.0-1.0)
) {
    // Convert position to normalized uv coordinates.
    float2 uv = position / size;

    // Distance from center.
    float2 uvOffset = uv - center;
    float distance = length(uvOffset);

    // Sample the layer color.
    half4 layerColor = layer.sample(position);

    // Use refraction effect inside the radius.
    if (distance <= radius) {
        // Normalized distance within radius.
        float normalizedDistance = distance / radius;

        // Donut-shaped refraction, heavy in donut, light in center.
        float t = normalizedDistance;
        float profile = t * t; // edge-heavy
        float smoothFade = 1.0 - smoothstep(max(0.2, 0.9 - thickness), 1.0, t);
        float pull = profile * smoothFade;
        float2 refractedOffset = uvOffset * pull * refraction;

        // Sample the layer from the refracted position.
        float2 refractedPosition = position - refractedOffset * size;
        half4 refractedColor = layer.sample(refractedPosition);

        // Generate chromatic aberration by splitting the RGB channels.
        float chromaticStrength = normalizedDistance * chromaticAmount;

        // Sample the layer's red and blue channels from the split positions.
        float2 redPosition = position - refractedOffset * size * (1.0 + chromaticStrength);
        half4 redSample = layer.sample(redPosition);
        refractedColor.r = redSample.r;

        float2 bluePosition = position - refractedOffset * size * (1.0 - chromaticStrength);
        half4 blueSample = layer.sample(bluePosition);
        refractedColor.b = blueSample.b;

        // Overlay a directional light from the upper-left.
        // (Uses corrected vector for circular highlight)
        float2 lightDir = normalize(float2(-0.5, -0.8));
        float rimBias = dot(normalize(uvOffset), lightDir);
        rimBias = clamp(rimBias, 0.0, 1.0);

        // Apply a barely perceptible bluish highlight.
        half3 highlightColor = half3(1.1, 1.15, 1.25);

        // Use Fresnel for the edges.
        float fresnel = pow(normalizedDistance, 2.0);
        float highlight = smoothstep(max(0.01, 0.94 - edgeThickness), 0.95, fresnel) * 0.2;
        refractedColor.rgb += half3(highlight) * rimBias * highlightColor * 0.8;

        // A barely perceptible bluish tint.
        half3 bluishTint = half3(0.96, 0.98, 1.02);
        refractedColor.rgb *= bluishTint;

        // Use smoothing at the edges.
        float smoothEdge = smoothstep(radius - 0.01, radius, distance);
        return mix(refractedColor, layerColor, smoothEdge);
    }
    else {  // Use shadow effect outside of the radius.
        float2 shadowCenter = center + float2(shadowOffset, shadowOffset);
        float2 uvShadowOffset = uv - shadowCenter;
        float shadowDistance = length(uvShadowOffset);
        float shadowRadius = radius + shadowBlur;
        if (shadowDistance < shadowRadius) {
            float normalizedShadowDistance = (shadowDistance - radius) / shadowBlur;
            float shadow = smoothstep(1.0, 0.0, normalizedShadowDistance) * shadowOpacity;
            return mix(layerColor, half4(0.0, 0.0, 0.0, 1.0), shadow);
        }
        else {
            return layerColor;
        }
    }
}
