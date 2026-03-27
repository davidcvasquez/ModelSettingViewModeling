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

/// A live runtime setting that manages boolean bindings for committing and tracking actions with the model.
public struct BoolViewModelSetting: ViewModelSetting {
    public typealias ActionType = BoolModelSettingAction
    public var action: ActionType

    public var committedValue: Binding<Bool?>

    public init(action: ActionType, committedValue: Binding<Bool?>) {
        self.action = action
        self.committedValue = committedValue
    }
}

@MainActor
public struct BoolModelSettingAction: @MainActor ModelSettingAction {
    public var actionName: LocalizationKey

    public init(actionName: LocalizationKey) {
        self.actionName = actionName
    }
}
