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
import LocalizableStringBundle

public enum Strings {
    @MainActor
    public static func install() throws {
        try LocalizedStringBundleInstaller.install(from: .module)
    }
}

@MainActor
fileprivate func settingName(_ key: String) -> LocalizationKey {
    LocalizationKey(key, bundle: .module, tableName: "ModelSettings")
}

public extension LocalizationKey {
    static let missing = settingName("missing")
    static let allSettingsLabel = settingName("allSettings")

    static let reorderLabel = settingName("reorder")
    static let customizeLabel = settingName("customize")
    static let resetSettingsLabel = settingName("resetSettings")
    static let layoutLabel = settingName("layout")
    static let adaptiveLabel = settingName("adaptive")
    static let compactLabel = settingName("compact")
    static let expandedLabel = settingName("expanded")
    static let customLabel = settingName("custom")

    static var labelsLabel = settingName("labels")
    static let showIconOnlyLabel = settingName("showIconOnly")
    static let showTextOnlyLabel = settingName("showTextOnly")
    static let showIconAndTextLabel = settingName("showIconAndText")

    static var controlsLabel = settingName("controls")
    static var showControlOnlyLabel = settingName("showControlOnly")
    static var showTextFieldOnlyLabel = settingName("showTextFieldOnly")
    static var showTextFieldWithPopupControlLabel = settingName("showTextFieldWithPopupControl")
    static var showTextFieldWithControlLabel = settingName("showTextFieldWithControl")

    static var steppersLabel = settingName("steppers")
    static var noStepperLabel = settingName("noStepper")
    static var smallStepperLabel = settingName("smallStepper")
    static var largeStepperLabel = settingName("largeStepper")

    static var allSettingsKey = settingName("allSettings")
}
