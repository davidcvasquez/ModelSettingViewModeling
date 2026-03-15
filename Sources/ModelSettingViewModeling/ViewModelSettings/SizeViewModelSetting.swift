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

public struct SizeViewModelSetting<Value: BinaryFloatingPoint>: ViewModelSetting
    where Value: Codable, Value.Stride: Codable {
    public init(
        action: SizeModelSettingAction<Value>,
        widthSetting: FloatViewModelSetting<Value>,
        heightSetting: FloatViewModelSetting<Value>,
        maintainSizeRatioSetting: BoolViewModelSetting,
        sizeRatioSetting: FloatViewModelSetting<Value>
    ) {
        self.action = action
        self.widthSetting = widthSetting
        self.heightSetting = heightSetting
        self.maintainSizeRatioSetting = maintainSizeRatioSetting
        self.sizeRatioSetting = sizeRatioSetting
    }

    public var action: SizeModelSettingAction<Value>

    public var widthSetting: FloatViewModelSetting<Value>
    public var heightSetting: FloatViewModelSetting<Value>
    public var maintainSizeRatioSetting: BoolViewModelSetting
    public var sizeRatioSetting: FloatViewModelSetting<Value>
}

nonisolated public struct SizeModelSettingAction<Value: BinaryFloatingPoint>: ModelSettingAction
    where Value: Codable & Sendable, Value.Stride: Codable & Sendable {

    public init(
        actionName: LocalizedKey,
        widthSettingID: ModelSetting.ID,
        widthActionName: LocalizedKey,
        heightSettingID: ModelSetting.ID,
        heightActionName: LocalizedKey,
        maintainSizeRatioSettingID: ModelSetting.ID,
        maintainSizeRatioActionName: LocalizedKey,
        sizeRatioSettingID: ModelSetting.ID,
        sizeRatioActionName: LocalizedKey,
        range: ClosedRange<Value>,
        step: Value.Stride,
        precision: RoundingPrecision
    ) {
        self.actionName = actionName
        self.widthSettingID = widthSettingID
        self.widthActionName = widthActionName
        self.heightSettingID = heightSettingID
        self.heightActionName = heightActionName
        self.maintainSizeRatioSettingID = maintainSizeRatioSettingID
        self.maintainSizeRatioActionName = maintainSizeRatioActionName
        self.sizeRatioSettingID = sizeRatioSettingID
        self.sizeRatioActionName = sizeRatioActionName
        self.range = range
        self.step = step
        self.precision = precision
    }

    public var actionName: LocalizedKey

    public var widthSettingID: ModelSetting.ID
    public var widthActionName: LocalizedKey

    public var heightSettingID: ModelSetting.ID
    public var heightActionName: LocalizedKey

    public var maintainSizeRatioSettingID: ModelSetting.ID
    public var maintainSizeRatioActionName: LocalizedKey

    public var sizeRatioSettingID: ModelSetting.ID
    public var sizeRatioActionName: LocalizedKey

    public var range: ClosedRange<Value>
    public var step: Value.Stride
    public var precision: RoundingPrecision
}
