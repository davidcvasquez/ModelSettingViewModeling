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
import OrderedCollections
import CompactUUID
import NDGeometry

nonisolated public struct MandalaLayer: Codable, Sendable, nonisolated Equatable, Hashable {
    public var selectedSubLayerID: MandalaSubLayer.ID?
    public var selectedSubLayerIDs: [MandalaSubLayer.ID] = []

    static func defaultLayer() -> MandalaLayer {
        let newMandalaSubLayer = MandalaSubLayer.defaultSubLayer()
        return MandalaLayer(
            selectedSubLayerID: newMandalaSubLayer.id,
            subLayers: [newMandalaSubLayer.id: newMandalaSubLayer])
    }

    public var selectedSubLayer: MandalaSubLayer? {
        if let selectedSubLayerID {
            return subLayers[selectedSubLayerID]
        }
        else {
            return nil
        }
    }

    public var selectedSubLayers: MandalaSubLayerMap {
        var selectedLayers: MandalaSubLayerMap = [:]
        for subLayer in self.subLayers {
            if selectedSubLayerIDs.contains(subLayer.key) {
                selectedLayers[subLayer.key] = subLayer.value
            }
        }
        return selectedLayers
    }

    public func subLayer(by id: MandalaSubLayer.ID) -> MandalaSubLayer? {
        self.subLayers[id]
    }

    public mutating func updateSubLayer(by id: MandalaSubLayer.ID, subLayer: MandalaSubLayer) {
        self.subLayers[id] = subLayer
    }

    public var subLayers: MandalaSubLayerMap
}

nonisolated public struct MandalaSubLayer: Codable, Sendable, Identifiable, Equatable, Hashable {
    public typealias ID = UUIDBase58
    public let id: ID
    public var revision: UInt64 = 0

    public var name: String?

    public var path: MandalaPath

    static func defaultSubLayer() -> MandalaSubLayer {
        MandalaSubLayer(
            id: .idBase58,
            path: MandalaPath(
                id: .idBase58,
                modelSettings: TestModelSettingProperties())
        )
    }

    /// Create a duplicate with a new ID.
    func duplicate() -> MandalaSubLayer {
        MandalaSubLayer(
            id: .idBase58,          // generate a new ID - the duplicate must have its own ID
            path: self.path)
    }
}

public typealias MandalaSubLayerMap = OrderedDictionary<UUIDBase58, MandalaSubLayer>

public struct UnionLayers: Codable, Identifiable {
    public typealias ID = UUIDBase58
    public var id: ID = .idBase58

    public var layers: MandalaSubLayerMap = [:]
}

public typealias UnionLayerStack = [UnionLayers]
