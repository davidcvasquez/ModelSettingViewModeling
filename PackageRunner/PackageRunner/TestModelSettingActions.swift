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
import LocalizableStringBundle
import ModelSettingViewModeling
import OrderedCollections

@MainActor
struct TestModelSettingActions {
    static var actions = ModelSettingActions(
        id: .testSettingsID,
        name: "Test Setting Actions",
        actions: modelSettingActionMap
    )

    private static var modelSettingActionMap: ModelSettingActionMap {
        [
            .testSizeID: .ndSize(SizeModelSettingAction<NDFloat>(
                actionName: .testSizeAction,
                widthSettingID: .testWidthID,
                widthActionName: .testWidthAction,
                heightSettingID: .testHeightID,
                heightActionName: .testHeightAction,
                maintainSizeRatioSettingID: .testMaintainSizeRatioID,
                maintainSizeRatioActionName: .maintainAspectRatioAction,
                sizeRatioSettingID: .testSizeRatioID,
                sizeRatioActionName: .sizeRatioAction,
                range: Self.testSizeRange,
                step: Self.testSizeStep,
                precision: .hundredths)),
            .testSizeFaderID: .ndFloat(FloatModelSettingAction<NDFloat>(
                actionName: .testSizeFaderAction,
                range: Self.testSizeFaderRange,
                step: Self.testSizeFaderStep,
                precision: .hundredths)),
            .testRotationID: .ndAngle(AngleModelSettingAction<NDAngle>(
                actionName: .testRotationAction,
                range: Self.angleRange,
                step: Self.angleStep,
                precision: .hundredths)),
            .testShearXID: .ndAngle(AngleModelSettingAction<NDAngle>(
                actionName: .testShearXAction,
                range: Self.testShearRange,
                step: Self.angleStep,
                precision: .hundredths)),
            .testShearYID: .ndAngle(AngleModelSettingAction<NDAngle>(
                actionName: .testShearYAction,
                range: Self.testShearRange,
                step: Self.angleStep,
                precision: .hundredths)),
            .testCountID: .integer(IntegerModelSettingAction(
                actionName: .testCountAction,
                range: Self.testCountRange))
       ]
    }

    private static var testSizeRange: ClosedRange<NDFloat> {
        0...2
    }

    private static var testSizeStep: CGFloat {
        0.01
    }

    private static var testSizeFaderRange: ClosedRange<NDFloat> {
        0...2
    }

    private static var testSizeFaderStep: NDFloat {
        0.01
    }

    private static var angleRange: ClosedRange<NDAngle> {
        NDAngle(degrees: -360.0)...NDAngle(degrees: 360.0)
    }

    private static var angleStep: NDAngle.Stride {
        .oneDegree
    }

    private static var testShearRange: ClosedRange<NDAngle> {
        NDAngle(degrees: -85.0)...NDAngle(degrees: 85.0)
    }

    private static var testCountRange: ClosedRange<Int> {
        0...10
    }
}
