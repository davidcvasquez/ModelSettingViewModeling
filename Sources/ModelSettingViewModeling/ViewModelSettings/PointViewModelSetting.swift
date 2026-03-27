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

/// A live runtime setting that manages point bindings for committing and tracking actions with the model.
public struct PointViewModelSetting<Value: BinaryFloatingPoint>: ViewModelSetting
where Value: Codable, Value.Stride: Codable {
    public init(
        action: PointModelSettingAction<Value>,
        xSetting: FloatViewModelSetting<Value>,
        ySetting: FloatViewModelSetting<Value>
    ) {
        self.action = action
        self.xSetting = xSetting
        self.ySetting = ySetting
    }
    public var action: PointModelSettingAction<Value>

    public var xSetting: FloatViewModelSetting<Value>
    public var ySetting: FloatViewModelSetting<Value>
}

@MainActor
public struct PointModelSettingAction<Value: BinaryFloatingPoint>: @MainActor ModelSettingAction
    where Value: Codable, Value.Stride: Codable {
    public init(
        actionName: LocalizationKey,
        xSettingID: ModelSetting.ID,
        xActionName: LocalizationKey,
        ySettingID: ModelSetting.ID,
        yActionName: LocalizationKey,
        range: ClosedRange<Value>,
        step: Value.Stride,
        precision: RoundingPrecision
    ) {
        self.actionName = actionName
        self.xSettingID = xSettingID
        self.xActionName = xActionName
        self.ySettingID = ySettingID
        self.yActionName = yActionName
        self.range = range
        self.step = step
        self.precision = precision
    }

    public var actionName: LocalizationKey

    public var xSettingID: ModelSetting.ID
    public var xActionName: LocalizationKey

    public var ySettingID: ModelSetting.ID
    public var yActionName: LocalizationKey

    public var range: ClosedRange<Value>
    public var step: Value.Stride
    public var precision: RoundingPrecision
}
