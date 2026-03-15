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

public struct BoolViewModelSetting: ViewModelSetting {
    public typealias ActionType = BoolModelSettingAction
    public var action: ActionType

    public var committedValue: Binding<Bool?>

    public init(action: ActionType, committedValue: Binding<Bool?>) {
        self.action = action
        self.committedValue = committedValue
    }
}

public struct BoolModelSettingAction: ModelSettingAction {
    public var actionName: LocalizedKey

    public init(actionName: LocalizedKey) {
        self.actionName = actionName
    }
}
