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
import ModelSettingsSupport

/// An ordered collection of runtime model settings with bindings for tracking and committing changes
public struct ModelSettingTypes {
    public let id: ModelSetting.ID
    public let name: String
    public var types: ModelSettingMap

    public init(id: ModelSetting.ID, name: String, types: ModelSettingMap) {
        self.id = id
        self.name = name
        self.types = types
    }
}

public typealias ModelSettingMap = OrderedDictionary<ModelSetting.ID, ModelSetting>

/// The runtime model setting with bindings for tracking and committing changes.
nonisolated public struct ModelSetting {
    public typealias ID = UUIDBase58

    public init(settingType: ModelSettingType) {
        self.settingType = settingType
    }

    public var settingType: ModelSettingType
}

/// An enumeration of types of model settings.
public enum ModelSettingType {
    case boolean(BoolViewModelSetting?)

    case float(FloatViewModelSetting<Double>)
    case ndFloat(FloatViewModelSetting<NDFloat>)
    case cgFloat(FloatViewModelSetting<CGFloat>)

    case ndPoint(PointViewModelSetting<NDFloat>)
    case cgPoint(PointViewModelSetting<CGFloat>)

    case ndSize(SizeViewModelSetting<NDFloat>)
    case cgSize(SizeViewModelSetting<CGFloat>)

    case ndAngle(AngleViewModelSetting<NDAngle>)
    case angle(AngleViewModelSetting<Angle>)

    case integer(IntegerViewModelSetting)

    case missing(String)
    case placeholder
}

/// The runtime model setting. TODO: This type is deprecated - use ModelSetting
nonisolated public struct DocumentSetting {
    public typealias ID = UUIDBase58

    public var settingType: ModelSettingType
}
public typealias DocumentSettingsMap = [DocumentSetting.ID: DocumentSetting]
