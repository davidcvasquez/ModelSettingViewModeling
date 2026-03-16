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

struct Book: Codable, Identifiable {
    public var formatVersion: Int = latestFormatVersion
    public static let latestFormatVersion: Int = 1

    public static let preferredFilename = "book.json"

    public typealias ID = UUIDBase58
    public var id: ID = .idBase58

    public var pages: PageMap

    public var selectedPage: Page? {
        guard let selectedPageID else {
            return nil
        }

        return self[selectedPageID]
    }

    public var selectedPageID: String?

    subscript(pageID: Page.ID) -> Page? {
        pages[pageID]
    }

    subscript(pageID: Page.ID, layerID: Layer.ID) -> Layer? {
        pages[pageID]?[layerID]
    }

    var json: Data {
        get throws {
            try JSONEncoder().encode(self)
        }
    }

    init() {
        let newLayer = Layer.defaultLayer()

        let defaultPage = Page(layers: [newLayer.id: newLayer], selectedLayerID: newLayer.id)
        self.pages = [defaultPage.id: defaultPage]
        self.selectedPageID = defaultPage.id
    }

    init?(json: Data?) {
        if json != nil, let newBook = try? JSONDecoder().decode(Book.self, from: json!) {
            self = newBook
        } else {
            // Only return nil if it fails to load
            return nil
        }
    }
}
