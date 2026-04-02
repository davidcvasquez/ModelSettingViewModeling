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

public enum SettingsStrings {
    @MainActor
    public static func install() throws {
        try LocalizedStringBundleInstaller.install(
            from: .main,
            installName: "ShapeSettings-Strings",
            overwriteExisting: true)
    }
}

@MainActor
fileprivate func testName(_ key: String) -> LocalizationKey {
    LocalizationKey(key, bundle: .main, tableName: "ShapeSettings")
}

public extension LocalizationKey {
    static let testSettingsLabel = testName("testSettings")
    static let testSizeLabel = testName("testSize")
    static let testWidthLabel = testName("testWidth")
    static let testHeightLabel = testName("testHeight")
    static let testMaintainSizeRatioLabel = testName("testMaintainSizeRatio")
    static let testSizeRatioLabel = testName("testSizeRatio")
    static let testSizeFaderLabel = testName("testSizeFader")
    static let testRotationLabel = testName("testRotation")
    static let testShearXLabel = testName("testShearX")
    static let testShearYLabel = testName("testShearY")
    static let testCountLabel = testName("testCount")

    static var testModelSettingAction = testName("testModelSettingAction")
    static var testSizeAction = testName("testSizeAction")
    static var testWidthAction = testName("testWidthAction")
    static var testHeightAction = testName("testHeightAction")
    static var maintainAspectRatioAction = testName("maintainAspectRatioAction")
    static var sizeRatioAction = testName("sizeRatioAction")

    static var testSizeFaderAction = testName("testSizeFaderAction")
    static var testRotationAction = testName("testRotationAction")
    static var testShearXAction = testName("testShearXAction")
    static var testShearYAction = testName("testShearYAction")
    static var testCountAction = testName("testCountAction")
}
