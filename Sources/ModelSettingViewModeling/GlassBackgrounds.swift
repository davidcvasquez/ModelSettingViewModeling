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

import SwiftUI

/// Liquid Glass backgrounds for tool palettes and panels, with fallbacks to ultra thin material.
extension View {
    @ViewBuilder
    public func toolPaletteGlassBackground(gray: Double = 0.0) -> some View {
        if #available(iOS 26.0, macOS 15.0, *) {
            self.glassEffect(.regular.interactive(), in: .capsule)
            .glassGrayOverlay(Capsule(), amount: gray)
            .shadow(radius: 3)
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
            .glassGrayOverlay(Capsule(), amount: gray)
            .shadow(radius: 3)
        }
    }

    @ViewBuilder
    public func oneButtonGlassBackground(gray: Double = 0.0) -> some View {
        if #available(iOS 26.0, macOS 15.0, *) {
            self.glassEffect(.regular.interactive(), in: .circle)
            .glassGrayOverlay(Circle(), amount: gray)
            .shadow(radius: 3)
        } else {
            self.background(.ultraThinMaterial, in: Circle())
            .glassGrayOverlay(Circle(), amount: gray)
            .shadow(radius: 3)
        }
    }

    @ViewBuilder
    public func panelGlassBackground(
        useGlass: Bool = true,
        gray: Double = 0.0,
        shadowColor: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: 20)
        if #available(iOS 26.0, macOS 15.0, *), useGlass {
            self.glassEffect(.regular, in: shape)
            .glassGrayOverlay(shape, amount: gray)
            .shadow(color: shadowColor, radius: 3, x: 1, y: 1)
        } else {
            self.background(.ultraThickMaterial, in: shape)
            .glassGrayOverlay(shape, amount: gray)
            .shadow(color: shadowColor, radius: 3, x: 1, y: 1)
        }
    }
}

private extension View {
    func glassGrayOverlay<S: Shape>(
        _ shape: S,
        amount: Double
    ) -> some View {
        overlay {
            shape
                .fill(Color.gray.opacity(amount))
                .blendMode(.multiply)
                .allowsHitTesting(false)
        }
    }
}
