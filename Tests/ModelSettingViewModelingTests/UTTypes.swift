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

import UniformTypeIdentifiers

nonisolated extension UTType {
    static let exportedDocument = UTType(
        exportedAs: "com.davidcvasquez.test", conformingTo: .package)

    static let importedDocument = UTType(
        importedAs: "com.davidcvasquez.test", conformingTo: .package)

    static let exportedBook = UTType(
        exportedAs: "com.davidcvasquez.book", conformingTo: .json)

    static let importedBook = UTType(
        importedAs: "com.davidcvasquez.book", conformingTo: .json)

    static let exportedMetadata = UTType(
        exportedAs: "com.davidcvasquez.metadata", conformingTo: .json)

    static let importedMetadata = UTType(
        importedAs: "com.davidcvasquez.metadata", conformingTo: .json)
}
