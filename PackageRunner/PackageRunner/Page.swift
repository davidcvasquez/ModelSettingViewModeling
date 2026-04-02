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
import OrderedCollections

// Cover, Back, or Interior page
nonisolated public struct Page: Codable, Equatable, Hashable, Identifiable {
    public typealias ID = UUIDBase58
    public let id: ID
    public var layers: LayerMap

    public var trackingLayer: Layer?

    public var selectedLayer: Layer? {
        guard let selectedLayerID else {
            return nil
        }

        return self.layers[selectedLayerID]
    }

    public var selectedLayerID: Layer.ID?

    subscript(layerID: Layer.ID) -> Layer? {
        layers[layerID]
    }

    init(id: ID = .idBase58, layers: LayerMap = [:], selectedLayerID: Layer.ID? = nil) {
        self.id = id
        self.layers = layers
        self.selectedLayerID = selectedLayerID
    }
}

public typealias PageMap = OrderedDictionary<UUIDBase58, Page>
