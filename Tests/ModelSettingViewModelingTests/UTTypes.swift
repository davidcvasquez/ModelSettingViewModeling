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

extension UTType {
    static var exportedDocument = UTType(
        exportedAs: "com.davidcvasquez.test", conformingTo: .package)

    static var importedDocument = UTType(
        importedAs: "com.davidcvasquez.test", conformingTo: .package)

    static var exportedBook = UTType(
        exportedAs: "com.davidcvasquez.book", conformingTo: .json)

    static var importedBook = UTType(
        importedAs: "com.davidcvasquez.book", conformingTo: .json)

    static var exportedMetadata = UTType(
        exportedAs: "com.davidcvasquez.metadata", conformingTo: .json)

    static var importedMetadata = UTType(
        importedAs: "com.davidcvasquez.metadata", conformingTo: .json)
}

///-------------------------------------------------------------------------------------------------
/// EOF
///-------------------------------------------------------------------------------------------------
