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
import OrderedCollections

nonisolated public enum LayerProperties: Codable, nonisolated Equatable, nonisolated Hashable {
    case mandala(layer: MandalaLayer)

    public var name: String {
        switch self {
        case .mandala(_):
            "Mandala"
        }
    }
}

nonisolated public struct Layer: Codable, nonisolated Equatable, Hashable, Identifiable {
    public typealias ID = UUIDBase58
    public let id: ID
    public var revision: UInt64 = 0

    // A given layer can only be clipped by a PathLayer.
    // TODO: Add support for clipping layers with TextLayer. [NED]
    public var clipLayerID: Layer.ID?

    public var properties: LayerProperties

    public static func defaultLayer() -> Layer {
        let newMandalaSubLayer = MandalaSubLayer.defaultSubLayer()

        let newMandalaLayer = MandalaLayer(
            selectedSubLayerID: newMandalaSubLayer.id,
            selectedSubLayerIDs: [newMandalaSubLayer.id],
            subLayers: [newMandalaSubLayer.id: newMandalaSubLayer])

        return Layer(id: .idBase58,
                     properties: .mandala(layer: newMandalaLayer))
    }
}

public typealias LayerMap = OrderedDictionary<UUIDBase58, Layer>
