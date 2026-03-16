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
import CompactUUID
import NDGeometry

nonisolated public struct MandalaPath: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: UUIDBase58
    public var revision: UInt64 = 0

    public var modelSettings: TestModelSettingProperties
}
