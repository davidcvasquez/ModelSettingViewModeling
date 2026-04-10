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

import LoggerCategories
import OSLog
import CoreGraphics
import ModelSettingViewModelingCore
import SwiftUI

public extension ModelSettingViewLayoutOptions {
    var popupButtonSymbolName: String {
        "chevron.down"
    }

    var popupButtonCornerRadius: CGFloat {
        6.0
    }

    var popupButtonFont: Font {
        .system(size: 14, weight: .semibold)
    }

    /// - Returns: The frame size of the popup button in pixels.
    var popupButtonFrameSize: CGFloat {
#if os(iOS)
        30.0
#endif
#if os(macOS)
        24.0
#endif
    }

    /// - Returns: The symbol color of the popup button.
    func popupButtonSymbolColor(isPopupOpen: Bool) -> Color {
        isPopupOpen ? .white.opacity(0.85) : .primary
    }

    /// - Returns: The background color of the popup button.
    func popupButtonBackgroundColor(isPopupOpen: Bool, colorScheme: ColorScheme) -> Color {
#if os(iOS)
        isPopupOpen ? Color.accentColor.opacity(0.85) : Color.gray.opacity(0.33)
#endif
#if os(macOS)
        if colorScheme == .dark {
            return isPopupOpen ? Color.accentColor.opacity(0.85) : Color.black.opacity(0.20)
        }
        else {
            return isPopupOpen ? Color.accentColor.opacity(0.85) : Color.white.opacity(0.75)
        }
#endif
    }

    var popupSliderContentSize: CGSize {
#if os(macOS)
        CGSize(width: 280, height: 32)
#endif
#if os(iOS)
        CGSize(width: 280, height: 48)
#endif
    }

    var popupDialContentSize: CGSize {
#if os(macOS)
        CGSize(width: 64, height: 64)
#endif
#if os(iOS)
        CGSize(width: 72, height: 72)
#endif
    }

    var sliderEdgeInsets: EdgeInsets {
        EdgeInsets(top: self.showLabelText ? 19.0 : 0,
                   leading: 0, bottom: 0, trailing: 0)
    }
}

public struct ModelSettingViewLayoutOptionPrefs: LayoutOptionPrefs {
#if os(macOS)
    public static let defaultLayoutSize: ModelSettingViewLayoutOptions.LayoutSizeOptions = .custom
#else
    public static let defaultLayoutSize: ModelSettingViewLayoutOptions.LayoutSizeOptions = .compact
#endif
    public static let layoutSizePrefKey = "com.ModelSettingViewLayoutOptions.layoutSize"

    @AppStorage(layoutSizePrefKey)
    public static var layoutSize: ModelSettingViewLayoutOptions.LayoutSizeOptions = defaultLayoutSize

    public static let labelOptionsPrefKey = "com.ModelSettingViewLayoutOptions.labelOptions"
    public static let defaultLabelOptions: ModelSettingViewLayoutOptions.LabelOptions = .showIconAndText

    @AppStorage(labelOptionsPrefKey)
    public static var labels: ModelSettingViewLayoutOptions.LabelOptions = defaultLabelOptions

#if os(macOS)
    public static let defaultControl: ModelSettingViewLayoutOptions.ControlOptions = .showTextFieldWithControl
#else
    public static let defaultControl: ModelSettingViewLayoutOptions.ControlOptions = .showTextFieldWithPopupControl
#endif

    public static let controlOptionsPrefKey = "com.ModelSettingViewLayoutOptions.controlOptions"

    @AppStorage(controlOptionsPrefKey)
    public static var controls: ModelSettingViewLayoutOptions.ControlOptions = defaultControl

#if os(macOS)
    public static let defaultStepper: ModelSettingViewLayoutOptions.StepperOptions = .smallStepper
#else
    public static let defaultStepper: ModelSettingViewLayoutOptions.StepperOptions = .noStepper
#endif

    public static let stepperOptionsPrefKey = "com.ModelSettingViewLayoutOptions.stepperOptions"

    @AppStorage(stepperOptionsPrefKey)
    public static var steppers: ModelSettingViewLayoutOptions.StepperOptions = defaultStepper
}
