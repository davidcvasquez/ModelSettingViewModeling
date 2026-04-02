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

struct Metadata: Codable, Identifiable {
    public var formatVersion: Int = latestFormatVersion
    public static let latestFormatVersion: Int = 1

    public static let preferredFilename = "metadata.json"

    public typealias ID = UUIDBase58
    public var id: ID = .idBase58

    public var trimSize: NDSize

    var json: Data {
        get throws {
            try JSONEncoder().encode(self)
        }
    }

    init(
        trimSize: NDSize
    ) {
        self.trimSize = trimSize
    }

    init?(json: Data?) {
        if json != nil, let newMetadata = try? JSONDecoder().decode(Metadata.self, from: json!) {
            self = newMetadata
        } else {
            // Only return nil if it fails to load
            return nil
        }
    }
}

public extension NDSize {
    static let printDPI = 300.0

    static let usLetterInches = NDSize(width: 8.5, height: 11.0)
    static let usLetterPixelsAt300dpi = NDSize(
        width: usLetterInches.width * printDPI, height: usLetterInches.height * printDPI)

    var heightToWidthRatio: NDFloat {
        self.height / self.width
    }
}
