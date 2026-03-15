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

nonisolated public struct PointModelSettingAction<Value: BinaryFloatingPoint>: ModelSettingAction
    where Value: Codable & Sendable, Value.Stride: Codable & Sendable {
    public init(
        actionName: LocalizedKey,
        xSettingID: ModelSetting.ID,
        xActionName: LocalizedKey,
        ySettingID: ModelSetting.ID,
        yActionName: LocalizedKey,
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

    public var actionName: LocalizedKey

    public var xSettingID: ModelSetting.ID
    public var xActionName: LocalizedKey

    public var ySettingID: ModelSetting.ID
    public var yActionName: LocalizedKey

    public var range: ClosedRange<Value>
    public var step: Value.Stride
    public var precision: RoundingPrecision
}
