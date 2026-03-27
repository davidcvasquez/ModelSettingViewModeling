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

/// A live runtime setting that manages integer bindings for committing and tracking actions with the model.
public struct IntegerViewModelSetting: ViewModelSetting {
    public init(
        action: IntegerModelSettingAction,
        committedValue: Binding<Int?>,
        trackingValue: Binding<Int?>
    ) {
        self.action = action
        self.committedValue = committedValue
        self.trackingValue = trackingValue
    }

    public var action: IntegerModelSettingAction

    public var committedValue: Binding<Int?>
    public var trackingValue: Binding<Int?>
}

@MainActor
public struct IntegerModelSettingAction: @MainActor ModelSettingAction {
    public init(
        actionName: LocalizationKey,
        range: ClosedRange<Int>
    ) {
        self.actionName = actionName
        self.range = range
    }

    public var actionName: LocalizationKey
    public var range: ClosedRange<Int>
}
