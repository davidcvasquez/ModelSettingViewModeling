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

/// The live runtime setting that manages bindings for committing and tracking actions with the model.
@MainActor
public protocol ViewModelSetting {
    associatedtype ActionType: ModelSettingAction
    var action: ActionType { get }
}
