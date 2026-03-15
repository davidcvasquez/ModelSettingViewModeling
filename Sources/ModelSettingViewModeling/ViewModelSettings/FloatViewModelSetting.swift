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
import Foundation
import NDGeometry

@MainActor
public struct FloatViewModelSetting<Value: BinaryFloatingPoint>: ViewModelSetting
    where Value: Codable, Value.Stride: Codable {

    public init(action: ActionType, committedValue: Binding<Value?>, trackingValue: Binding<Value?>) {
        self.action = action
        self.committedValue = committedValue
        self.trackingValue = trackingValue
    }

    public typealias ActionType = FloatModelSettingAction<Value>
    public var action: ActionType

    public var committedValue: Binding<Value?>
    public var trackingValue: Binding<Value?>
}

nonisolated public struct FloatModelSettingAction<Value: BinaryFloatingPoint>: ModelSettingAction
    where Value: Codable & Sendable, Value.Stride: Codable & Sendable {

    public init(
        actionName: LocalizedKey,
        range: ClosedRange<Value>,
        step: Value.Stride,
        precision: RoundingPrecision
    ) {
        self.actionName = actionName
        self.range = range
        self.step = step
        self.precision = precision
    }

    public var actionName: LocalizedKey
    public var range: ClosedRange<Value>
    public var step: Value.Stride

    public var precision: RoundingPrecision
}
