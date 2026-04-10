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

import Foundation
import OSLog
import LoggerCategories

// Private token for this module to identify the bundle where this code is compiled.
private final class ModuleBundleToken {}
private let moduleSubsystem: String = Logging.subsystem(for: ModuleBundleToken.self)

enum LogCategory: String, LogCategoryType {
    case general, view, model, viewmodel, localization, network

    public var name: String { self.rawValue }

    public var logger: Logger {
        Logger(subsystem: moduleSubsystem, category: rawValue)
    }
}
