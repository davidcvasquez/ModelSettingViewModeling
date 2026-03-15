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

nonisolated public struct IntegerModelSettingAction: ModelSettingAction {
    public init(
        actionName: LocalizedKey,
        range: ClosedRange<Int>
    ) {
        self.actionName = actionName
        self.range = range
    }

    public var actionName: LocalizedKey
    public var range: ClosedRange<Int>
}
