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

/// A live runtime setting that manages angle bindings for committing and tracking actions with the model.
public struct AngleViewModelSetting<MoA: AnyAngle>: ViewModelSetting
    where MoA: Strideable & Comparable & Codable, MoA.Stride: Codable & Sendable
{
    public init(
        action: AngleModelSettingAction<MoA>,
        committedValue: Binding<MoA?>,
        trackingValue: Binding<MoA?>
    ) {
        self.action = action
        self.committedValue = committedValue
        self.trackingValue = trackingValue
    }

    public var action: AngleModelSettingAction<MoA>

    public var committedValue: Binding<MoA?>
    public var trackingValue: Binding<MoA?>
}

@MainActor
public struct AngleModelSettingAction<MoA: AnyAngle>: @MainActor ModelSettingAction
    where MoA: Strideable & Comparable & Codable,
          MoA.Stride: Codable
{
    public init(
        actionName: LocalizationKey,
        range: ClosedRange<MoA>,
        step: MoA.Stride,
        precision: RoundingPrecision
    ) {
        self.actionName = actionName
        self.range = range
        self.step = step
        self.precision = precision
    }

    public var actionName: LocalizationKey
    public var range: ClosedRange<MoA>
    public var step: MoA.Stride
    public var precision: RoundingPrecision
}
