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
import ModelSettingViewModeling
import OrderedCollections

@MainActor
struct TestModelSettingViewStyles {
    static var viewStyles = ModelSettingViewStyles(
        id: .testSettingsID,
        labelText: .testSettingsLabel,
        name: String(localized: LocalizationKey.allSettingsKey.resource),
        presentInDisclosureGroup: true,
        isVisiblePrefKey: .showModelSettingsPrefKey,
        viewStyles: allSettingsViewStyleMap
        )

    private static var allSettingsViewStyleMap: ModelSettingViewStyleMap = [
        .testSizeID: ModelSettingViewStyle(
            id: .testSizeID,
            labelIcon: .system(name: "arrow.left.and.line.vertical.and.arrow.right"),
            labelText: .testWidthLabel,
            accessibilityIdentifier: "testSize",
            specialPresentation: .linkedPercent(
                linkedLabelIcon: .system(name: "arrow.up.and.line.horizontal.and.arrow.down"),
                linkedLabelText: .testHeightLabel,
                maintainRatioToggleLabelIcon: .system(name: "link"),
                maintainRatioToggleLabelText: .testMaintainSizeRatioLabel
            )
        ),
        .testSizeFaderID: ModelSettingViewStyle(
            id: .testSizeFaderID,
            labelIcon: .system(name: "sunset"),
            labelText: .testSizeFaderLabel,
            accessibilityIdentifier: "testSizeFader",
            specialPresentation: .percent
        ),
        .testRotationID: ModelSettingViewStyle(
            id: .testRotationID,
            labelIcon: .system(name: "angle"),
            labelText: .testRotationLabel,
            accessibilityIdentifier: "testRotation",
            specialPresentation: .degrees
        ),
        .testShearXID: ModelSettingViewStyle(
            id: .testShearXID,
            labelIcon: .system(name: "angle"),
            labelText: .testShearXLabel,
            accessibilityIdentifier: "testShearX",
            specialPresentation: .degrees
        ),
        .testShearYID: ModelSettingViewStyle(
            id: .testShearYID,
            labelIcon: .system(name: "angle"),
            labelText: .testShearYLabel,
            accessibilityIdentifier: "testShearY",
            specialPresentation: .degrees
        ),
        .testCountID: ModelSettingViewStyle(
            id: .testCountID,
            labelIcon: .system(name: "globe"),
            labelText: .testCountLabel,
            accessibilityIdentifier: "testCount",
            specialPresentation: .native
        )
    ]
}
