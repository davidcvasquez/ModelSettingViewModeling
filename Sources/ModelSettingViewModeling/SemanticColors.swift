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
import NDGeometry

extension ShapeStyle where Self == Color {
    public static var labelColor: Color {
#if canImport(UIKit)
        Color(uiColor: .label)
#elseif canImport(AppKit)
        Color(nsColor: .labelColor)
#endif
    }

    public static var secondaryLabelColor: Color {
#if canImport(UIKit)
        Color(uiColor: .secondaryLabel)
#elseif canImport(AppKit)
        Color(nsColor: .secondaryLabelColor)
#endif
    }

    public static var tertiaryLabelColor: Color {
#if canImport(UIKit)
        Color(uiColor: .tertiaryLabel)
#elseif canImport(AppKit)
        Color(nsColor: .tertiaryLabelColor)
#endif
    }

    public static var quaternaryLabelColor: Color {
#if canImport(UIKit)
        Color(uiColor: .quaternaryLabel)
#elseif canImport(AppKit)
        Color(nsColor: .quaternaryLabelColor)
#endif
    }

    public static var linkColor: Color {
#if canImport(UIKit)
        Color(uiColor: .link)
#elseif canImport(AppKit)
        Color(nsColor: .linkColor)
#endif
    }
}

/// The complementary color of the tint color.
public extension ShapeStyle where Self == TintComplement {
    /// Usage: `.fill(.tintComplement)`
    static var tintComplement: TintComplement { TintComplement() }
}

public struct TintComplement: ShapeStyle {
    public init() {}

    public func resolve(in _: EnvironmentValues) -> Color {
        let base = PlatformTint.current
        return base.complementByHueRotation180() ?? base
    }
}

/// The tint color for the platform.
public enum PlatformTint {
    static var current: Color {
        #if os(macOS)
        // macOS: this is the user's System Settings accent color.
        return Color(nsColor: NSColor.controlAccentColor)

        #elseif os(iOS)
        // iOS: no true system accent color like macOS.
        // Best approximation: the key window's tintColor if available.
        if let ui = UIApplication.shared.keyWindow?.tintColor {
            return Color(uiColor: ui)
        }
        // Fallback if no window is available yet.
        return Color(uiColor: .systemBlue)

        #else
        return .blue
        #endif
    }
}

#if os(iOS)
private extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
#endif

/// Color extensions to generate shades, tints, tones, and various harmonious colors.
public extension Color {
    /// - Returns: A shade of the base color mixed with black by the given percentage.
    public func shadeColor(percent: Double) -> Color {
        self.mix(with: Color.black, by: percent)
    }

    /// - Returns: A tint of the base color mixed with white by the given percentage.
    public func tintColor(percent: Double) -> Color {
        self.mix(with: Color.white, by: percent)
    }

    /// - Returns: A tone of the base color mixed with gray by the given percentage, optionally with a secondary tint or shade.
    public func toneColor(
        percent: Double,
        tintOrShade: Color? = nil,
        tintOrShadePercent: Double? = nil
    ) -> Color {
        var blendColor = self.mix(with: Color.gray, by: percent)
        if let tintOrShade, let tintOrShadePercent {
            blendColor = blendColor.mix(with: tintOrShade, by: tintOrShadePercent)
        }
        return blendColor
    }

    /// Various types of harmonious colors.
    nonisolated public enum Harmony: CaseIterable {
        case complementary
        case splitComplementary
        case analogous
        case accentedAnalogic
        case triadic
        case tetradic
        case square

        /// Localized display names for each set of harmony colors.
        public var displayName: LocalizedStringKey {
            switch self {
            case .complementary:
                "Complementary"

            case .splitComplementary:
                "Split Complementary"

            case .analogous:
                "Analogous"

            case .accentedAnalogic:
                "Accented Analogic"

            case .triadic:
                "Triadic"

            case .tetradic:
                "Tetradic"

            case .square:
                "Square"
            }
        }

        /// Hue offsets for harmony colors, including the base hue placed in sequence/
        public var hueOffsets: [Double] {
            switch self {
            case .complementary:
                [0, 180]

            case .splitComplementary:
                [-150, 0, 150]

            case .analogous:
                [-30, 0, 30]

            case .accentedAnalogic:
                [-150, 0, 150, 180]

            case .triadic:
                [-120, 0, 120]

            case .tetradic:
                [-150, 0, 30, 180]

            case .square:
                [-90, 0, 90, 180]
            }
        }
    }

    /// Generate an array of harmony colors:
    /// - Hue rotated in HSL space
    /// - Saturation and Lightness preserved
    /// - Alpha preserved
    /// - Returns: The harmony colors, including the base color placed in sequence.
    public func harmony(_ scheme: Harmony) -> [Color]? {
        guard let rgba = rgbaSRGBComponents() else { return nil }
        let (h, s, l) = rgbToHsl(r: rgba.r, g: rgba.g, b: rgba.b)

        return scheme.hueOffsets.map { deg in
            let h2 = wrap01(h + deg / 360.0)
            let rgb2 = hslToRgb(h: h2, s: s, l: l)
            return Color(.sRGB, red: rgb2.r, green: rgb2.g, blue: rgb2.b, opacity: rgba.a)
        }
    }

    /// - Returns: The rgba components of an sRGB or extended sRGB color, otherwise nil for other color spaces.
    public func rgbaSRGBComponents() -> (r: Double, g: Double, b: Double, a: Double)? {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (Double(r), Double(g), Double(b), Double(a))

        #elseif canImport(AppKit)
        let ns = NSColor(self)
        guard let rgb = ns.usingColorSpace(.sRGB) ?? ns.usingColorSpace(.extendedSRGB) else { return nil }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))

        #else
        return nil
        #endif
    }

    /// - Returns: A complementary color calculated by rotating the hue 180° in HSB/HSV space.
    /// Returns nil if the color can’t be converted to HSB.
    public func complementByHueRotation180() -> Color? {
        guard var hsba = toHSBA() else { return nil }
        hsba.hue = (hsba.hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        return Color(hue: hsba.hue,
                     saturation: hsba.saturation,
                     brightness: hsba.brightness,
                     opacity: hsba.alpha)
    }

    /// - Returns: The individual color channel components for this color.
    private func toHSBA() -> (hue: Double, saturation: Double, brightness: Double, alpha: Double)? {
        #if os(iOS)
        let ui = UIColor(self)

        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return (Double(h), Double(s), Double(b), Double(a))

        #elseif os(macOS)
        let ns = NSColor(self)
        guard let rgb = ns.usingColorSpace(.deviceRGB) else { return nil }

        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgb.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (Double(h), Double(s), Double(b), Double(a))

        #else
        return nil
        #endif
    }

    /// - Returns: The HSL color components for the given set of RGB color components.
    private func rgbToHsl(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let maxv = max(r, g, b)
        let minv = min(r, g, b)
        let delta = maxv - minv

        let l = (maxv + minv) / 2.0
        if delta == 0 { return (0, 0, l) } // gray

        let s = delta / (1.0 - abs(2.0 * l - 1.0))

        var h: Double
        if maxv == r {
            h = ((g - b) / delta).truncatingRemainder(dividingBy: 6.0)
        } else if maxv == g {
            h = ((b - r) / delta) + 2.0
        } else {
            h = ((r - g) / delta) + 4.0
        }

        h /= 6.0
        h = wrap01(h)
        return (h, s, l)
    }

    private func wrap01(_ x: Double) -> Double {
        let r = x.truncatingRemainder(dividingBy: 1.0)
        return r >= 0 ? r : (r + 1.0)
    }

    /// - Returns: The RGB color components for the given set of HSL color components.
    private func hslToRgb(h: Double, s: Double, l: Double) -> (r: Double, g: Double, b: Double) {
        func hueToRgb(_ p: Double, _ q: Double, _ tIn: Double) -> Double {
            var t = tIn
            if t < 0 { t += 1 }
            if t > 1 { t -= 1 }
            if t < 1.0/6.0 { return p + (q - p) * 6.0 * t }
            if t < 1.0/2.0 { return q }
            if t < 2.0/3.0 { return p + (q - p) * (2.0/3.0 - t) * 6.0 }
            return p
        }

        if s == 0 { return (l, l, l) } // gray

        let q = (l < 0.5) ? (l * (1 + s)) : (l + s - l * s)
        let p = 2 * l - q

        let r = hueToRgb(p, q, h + 1.0/3.0)
        let g = hueToRgb(p, q, h)
        let b = hueToRgb(p, q, h - 1.0/3.0)
        return (r, g, b)
    }
}
