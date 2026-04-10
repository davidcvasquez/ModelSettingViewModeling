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

import Foundation
import LocalizableStringBundle
import LoggerCategories
import OSLog

/// Shared UI layout options that are not specialized by ViewModel types.
@Observable
public class ModelSettingViewLayoutOptions {
    public init(
        prefs: (any LayoutOptionPrefs.Type),
        reorderSettings: Bool = false,
        enableRenaming: Bool = true
    ) {
        self.prefs = prefs
        self.reorderSettings = reorderSettings
        self.enableRenaming = enableRenaming
    }

    // Workaround for XCTest crash during deallocation.
    // Reproduces when module is built with default isolation set to MainActor.
    // https://github.com/swiftlang/swift/issues/87316
    nonisolated deinit {}

    /// Whether settings are displayed for reordering, to enable drag-n-drop and visibility changes.
    public var reorderSettings: Bool
    public var enableRenaming: Bool

    /// Usage:
    /// ```
    /// var body: some View {
    ///     GeometryReader { proxy in
    ///        let size = proxy.size
    ///        ...
    ///     }
    ///     .onChange(of: size) { _, value in
    ///         self.layoutOptions.configureForViewSizeChangeIfAdaptive(size: size)
    ///     }
    /// ```
    /// - Parameters:
    /// - size: The size in pixels for which the layout options should be configured.
    public func configureForViewSizeChangeIfAdaptive(size: CGSize) {
        guard self.layoutSize == .adaptive else {
            return
        }

        let maxStackWidth = self.maxStackWidth
        Logger.debug("maxStackWidth: \(maxStackWidth)", LogCategory.general)

        let idealStackWidth = self.idealStackWidth

        let paddedWidth = size.width + 20

        if paddedWidth >= self.maxStackWidth {
            Logger.debug("size \(paddedWidth) > maxStackWidth: (\(maxStackWidth))", LogCategory.general)
            self.adoptStackWidthProposal(Self.expandedStackWidthProposal)
        }
        else if paddedWidth >= idealStackWidth {
            Logger.debug("size \(paddedWidth) > idealStackWidth: \(idealStackWidth)", LogCategory.general)
            self.adoptStackWidthProposal(Self.idealStackWidthProposal)
        }
        else {
            Logger.debug("size \(paddedWidth) < idealStackWidth: \(idealStackWidth)", LogCategory.general)
            self.adoptStackWidthProposal(Self.compactStackWidthProposal)
        }
    }

    private struct StackWidthProposal {
        let reorderSettings: Bool
        let label: LabelOptions
        let control: ControlOptions
        let stepper: StepperOptions
    }

    private func adoptStackWidthProposal(_ proposal: StackWidthProposal) {
        self.labelOptions = proposal.label
        self.controlOptions = proposal.control
        self.stepperOptions = proposal.stepper
    }

    static private var compactStackWidthProposal: StackWidthProposal {
        StackWidthProposal(
            reorderSettings: false,
            label: .showTextOnly,
            control: .showTextFieldOnly,
            stepper: .noStepper
        )
    }

    static private var idealStackWidthProposal: StackWidthProposal {
        StackWidthProposal(
            reorderSettings: false,
            label: .showTextOnly,
            control: .showTextFieldWithControl,
            stepper: .smallStepper
        )
    }

    static private var expandedStackWidthProposal: StackWidthProposal {
        StackWidthProposal(
            reorderSettings: false,
            label: .showIconAndText,
            control: .showTextFieldWithControl,
            stepper: .smallStepper
        )
    }

    /// - Returns: The minimum width in pixels for a stack of settings with these layout options.
    public var minStackWidth: CGFloat {
        stackWidthForProposal(Self.compactStackWidthProposal)
    }

    public var idealStackWidth: CGFloat {
        if self.layoutSize == .adaptive {
            return stackWidthForProposal(Self.idealStackWidthProposal)
        }
        else {
            return stackWidthForProposal(StackWidthProposal(
                reorderSettings: self.reorderSettings,
                label: self.labelOptions,
                control: self.controlOptions,
                stepper: self.stepperOptions
            ))
        }
    }

    public var maxStackWidth: CGFloat {
        stackWidthForProposal(Self.expandedStackWidthProposal)
    }

    private func stackWidthForProposal(
        _ proposal: StackWidthProposal
    ) -> CGFloat {
        let maxStackWidth: CGFloat = 450.0
        let reorderSettingsWidth: CGFloat = 64.0

        var width: CGFloat = maxStackWidth

        if proposal.reorderSettings {
            width += reorderSettingsWidth
        }

        if proposal.label == .showIconOnly {
            width -= 100
        }

        if proposal.label == .showTextOnly {
            width -= 25
        }

        if proposal.control == .showTextFieldOnly {
            width -= 50
        }

        if proposal.control == .showControlOnly {
            width -= 70
        }

        if proposal.stepper == .noStepper {
            width -= 30
        }

        return width
    }

    /// Options for the size of the settings layout.
    public enum LayoutSizeOptions: String, Codable, CaseIterable {
        case adaptive
        case compact
        case expanded
        case custom

        public var displayName: LocalizationKey {
            switch self {
            case .adaptive:
                .adaptiveLabel

            case .compact:
                .compactLabel

            case .expanded:
                .expandedLabel

            case .custom:
                .customLabel
            }
        }

        public var accessibilityIdentifier: String {
            switch self {
            case .adaptive:
                "layoutSize.adaptive"

            case .compact:
                "layoutSize.compact"

            case .expanded:
                "layoutSize.expanded"

            case .custom:
                "layoutSize.custom"
            }
        }
    }

    public var layoutSize: LayoutSizeOptions {
        get {
            // Loading from prefs, so manually register that this property was read.
            access(keyPath: \.layoutSize)

            return prefs.layoutSize
        }
        set {
            withMutation(keyPath: \.layoutSize) {
                prefs.layoutSize = newValue
            }
        }
    }

    public var isFixedSizeLayout: Bool {
        layoutSize == .compact || layoutSize == .expanded
    }

    /// Options for the visibility of label icons and text.
    public enum LabelOptions: String, Codable, CaseIterable {
        case showIconOnly
        case showTextOnly
        case showIconAndText

        public var displayName: LocalizationKey {
            switch self {
            case .showIconOnly:
                .showIconOnlyLabel

            case .showTextOnly:
                .showTextOnlyLabel

            case .showIconAndText:
                .showIconAndTextLabel
            }
        }

        public var accessibilityIdentifier: String {
            switch self {
            case .showIconOnly:
                "label.showIconOnly"

            case .showTextOnly:
                "label.showTextOnly"

            case .showIconAndText:
                "label.showIconAndText"
            }
        }
    }

    private var _labelOptions: LabelOptions {
        get { prefs.labels }
        set { prefs.labels = newValue }
    }

    public var labelOptions: LabelOptions {
        get {
            // In case we load from prefs, manually register that this property was read
            access(keyPath: \.labelOptions)

            switch layoutSize {
            case .compact:
                return .showTextOnly

            case .expanded:
                return .showIconAndText

            case .adaptive, .custom:
                return self._labelOptions
            }
        }
        set {
            if !isFixedSizeLayout {
                withMutation(keyPath: \.labelOptions) {
                    _labelOptions = newValue
                }
            }
        }
    }

    public var showIcons: Bool {
        labelOptions == .showIconOnly || labelOptions == .showIconAndText
    }

    public var showLabelText: Bool {
        labelOptions == .showTextOnly || labelOptions == .showIconAndText
    }

    /// Options for the visibility of the main control and its text field.
    public enum ControlOptions: String, Codable, CaseIterable {
        case showControlOnly
        case showTextFieldOnly
        case showTextFieldWithPopupControl
        case showTextFieldWithControl

        public var displayName: LocalizationKey {
            switch self {
            case .showControlOnly:
                .showControlOnlyLabel

            case .showTextFieldOnly:
                .showTextFieldOnlyLabel

            case .showTextFieldWithPopupControl:
                .showTextFieldWithPopupControlLabel

            case .showTextFieldWithControl:
                .showTextFieldWithControlLabel
            }
        }

        public var accessibilityIdentifier: String {
            switch self {
            case .showControlOnly:
                "controlOption.showControlOnly"

            case .showTextFieldOnly:
                "controlOption.showTextFieldOnly"

            case .showTextFieldWithPopupControl:
                "controlOption.showTextFieldWithPopupControl"

            case .showTextFieldWithControl:
                "controlOption.showTextFieldWithControl"
            }
        }
    }

    private var _controlOptions: ControlOptions {
        get { prefs.controls }
        set { prefs.controls = newValue }
    }
    public var controlOptions: ControlOptions {
        get {
            // In case we load from prefs, manually register that this property was read
            access(keyPath: \.controlOptions)

            switch layoutSize {
            case .compact:
                return .showTextFieldWithPopupControl

            case .expanded:
                return .showTextFieldWithControl

            case .adaptive, .custom:
                return self._controlOptions
            }
        }
        set {
            if !isFixedSizeLayout {
                withMutation(keyPath: \.controlOptions) {
                    _controlOptions = newValue
                }
            }
        }
    }

    public var showControls: Bool {
        self.controlOptions == .showControlOnly ||
        self.controlOptions == .showTextFieldWithControl
    }

    public var showTextFields: Bool {
        self.controlOptions != .showControlOnly
    }

    /// Options for whether a stepper is present, and its size.
    public enum StepperOptions: String, Codable, CaseIterable {
        case noStepper
        case smallStepper
        case largeStepper

        public var displayName: LocalizationKey {
            switch self {
            case .noStepper:
                .noStepperLabel

            case .smallStepper:
                .smallStepperLabel

            case .largeStepper:
                .largeStepperLabel
            }
        }

        public var accessibilityIdentifier: String {
            switch self {
            case .noStepper:
                "stepperOption.noStepper"

            case .smallStepper:
                "stepperOption.smallStepper"

            case .largeStepper:
                "stepperOption.largeStepper"
            }
        }
    }

    private var _stepperOptions: StepperOptions {
        get { prefs.steppers }
        set { prefs.steppers = newValue }
    }
    public var stepperOptions: StepperOptions {
        get {
            // In case we load from prefs, manually register that this property was read
            access(keyPath: \.stepperOptions)

            switch layoutSize {
            case .compact:
                return .noStepper

            case .expanded:
                return .smallStepper

            case .adaptive, .custom:
                return self._stepperOptions
            }
        }
        set {
            if !isFixedSizeLayout {
                withMutation(keyPath: \.stepperOptions) {
                    _stepperOptions = newValue
                }
            }
        }
    }

    public var showSteppers: Bool {
        get {
            stepperOptions != .noStepper
        } set {
            stepperOptions = newValue ? .smallStepper : .noStepper
        }
    }

    public var horizontalSettingGroupMargin: CGFloat { 16.0 }
    public var horizontalSettingGroupNoIconMargin: CGFloat { 0.0 }
    public var verticalNoIconMargin: CGFloat { 24.0 }
    public var verticalTitleMargin: CGFloat { -12.0 }
    public var centeredVerticalTitleMargin: CGFloat { 0.0 }

    public var settingGridSpacing: CGSize {
        if self.showControls {
            return CGSize(width: 16.0, height: self.stepperOptions == .largeStepper ? 12.0 : 6.0)
        }
        else {
            return CGSize(width: 16.0, height: self.stepperOptions == .largeStepper ? 20.0 : 6.0)
        }
    }

    public var prefs: (any LayoutOptionPrefs.Type)
}

public protocol LayoutOptionPrefs {
    static var layoutSize: ModelSettingViewLayoutOptions.LayoutSizeOptions { get set }
    static var labels: ModelSettingViewLayoutOptions.LabelOptions { get set }
    static var controls: ModelSettingViewLayoutOptions.ControlOptions { get set }
    static var steppers: ModelSettingViewLayoutOptions.StepperOptions { get set }
}

public struct LayoutOptionsViewAccessibilityIDs {
    public static var doneReorderingButtonAccessibilityIdentifier: String { "doneReorderingButton" }
    public static var reorderButtonAccessibilityIdentifier: String { "reorderButton" }
    public static var resetButtonAccessibilityIdentifier: String { "resetButton" }
    public static var customizeSettingsButtonAccessibilityIdentifier: String { "customizeButton" }
}
