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
import NDGeometry
import OrderedCollections
import SwiftUI
import LocalizableStringBundle

/// An ordered collection of Codable configurations for action types.
/// Separates the persistent settings description from runtime-only closures used for reads, tracking, and commits.
@MainActor
public struct ModelSettingActions: Codable {
    public let id: ModelSetting.ID
    public let name: String
    public var actions: ModelSettingActionMap

    public init(id: ModelSetting.ID, name: String, actions: ModelSettingActionMap) {
        self.id = id
        self.name = name
        self.actions = actions
    }

    public func exportJSON(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(self)
        try data.write(to: url, options: [.atomic])
    }

    public static func importJSON(from url: URL) throws -> ModelSettingActions {
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        return try decoder.decode(ModelSettingActions.self, from: data)
    }
}

/// A protocol for each ModelSettingActionType that can perform an action with a given type.
@MainActor
public protocol ModelSettingAction: Codable {
    var actionName: LocalizationKey { get }
}

/// An enumeration of Codable configurations for action types.
/// Separates the persistent settings description from runtime-only closures used for reads, tracking, and commits.
@MainActor
public enum ModelSettingActionType: Codable {
    case boolean(BoolModelSettingAction)

    case float(FloatModelSettingAction<Double>)
    case ndFloat(FloatModelSettingAction<NDFloat>)
    case cgFloat(FloatModelSettingAction<CGFloat>)

    case ndPoint(PointModelSettingAction<NDFloat>)
    case cgPoint(PointModelSettingAction<CGFloat>)

    case ndSize(SizeModelSettingAction<NDFloat>)
    case cgSize(SizeModelSettingAction<CGFloat>)

    case ndAngle(AngleModelSettingAction<NDAngle>)
    case angle(AngleModelSettingAction<Angle>)

    case integer(IntegerModelSettingAction)
}

public typealias ModelSettingActionMap = OrderedDictionary<ModelSetting.ID, ModelSettingActionType>
