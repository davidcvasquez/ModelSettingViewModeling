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

/// A system or local icon name.
public enum IconName: Codable, Equatable {
    case system(name: String)
    case local(name: String)

    var name: String {
        switch self {
        case .system(let name):
            name
        case .local(let name):
            name
        }
    }
}
