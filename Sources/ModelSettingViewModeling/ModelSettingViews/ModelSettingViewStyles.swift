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
import LocalizableStringBundle

/// A collection of presentation styles for model setting views.
nonisolated public struct ModelSettingViewStyles: Codable {
    public let id: ModelSetting.ID
    public var labelText: LocalizationKey
    public var name: String
    public var presentInDisclosureGroup: Bool
    public var isVisiblePrefKey: String
    public var viewStyles: ModelSettingViewStyleMap

    public init(
        id: ModelSetting.ID,
        labelText: LocalizationKey,
        name: String,
        presentInDisclosureGroup: Bool,
        isVisiblePrefKey: String,
        viewStyles: ModelSettingViewStyleMap
    ) {
        self.id = id
        self.labelText = labelText
        self.name = name
        self.presentInDisclosureGroup = presentInDisclosureGroup
        self.isVisiblePrefKey = isVisiblePrefKey
        self.viewStyles = viewStyles
    }

    func exportJSON(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(self)
        try data.write(to: url, options: [.atomic])
    }

    static func importJSON(from url: URL) throws -> ModelSettingViewStyles {
        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()
        return try decoder.decode(ModelSettingViewStyles.self, from: data)
    }
}

public typealias ModelSettingViewStyleMap =
    OrderedDictionary<ModelSetting.ID, ModelSettingViewStyle>

/// The presentation style to view a mode setting in the UI, with special presentations for custom formatting and dependencies.
public struct ModelSettingViewStyle: Codable, Identifiable {
    public let id: ModelSetting.ID
    public var isVisible: Bool
    public var labelIcon: IconName
    public var labelText: LocalizationKey

    public init(
        id: ModelSetting.ID,
        isVisible: Bool = true,
        labelIcon: IconName,
        labelText: LocalizationKey,
        specialPresentation: SpecialPresentation
    ) {
        self.id = id
        self.isVisible = isVisible
        self.labelIcon = labelIcon
        self.labelText = labelText
        self.specialPresentation = specialPresentation
    }

    /// Use `.native` for the default presentation.
    public enum SpecialPresentation: Codable {
        case native
        case iconButtonToggle(IconName)
        case integer
        case iconPicker(caseNames: [IconAndName])
        case decimal
        case percent
        case degrees
        case radians
        case linkedDecimal(
            linkedLabelIcon: IconName,
            linkedLabelText: LocalizationKey,
            maintainRatioToggleLabelIcon: IconName,
            maintainRatioToggleLabelText: LocalizationKey
        )
        case linkedPercent(
            linkedLabelIcon: IconName,
            linkedLabelText: LocalizationKey,
            maintainRatioToggleLabelIcon: IconName,
            maintainRatioToggleLabelText: LocalizationKey
        )
        case linkedDegrees(
            linkedLabelIcon: IconName,
            linkedLabelText: LocalizationKey,
            maintainRatioToggleLabelIcon: IconName,
            maintainRatioToggleLabelText: LocalizationKey
        )
        case linkedRadians(
            linkedLabelIcon: IconName,
            linkedLabelText: LocalizationKey,
            maintainRatioToggleLabelIcon: IconName,
            maintainRatioToggleLabelText: LocalizationKey
        )
    }
    public var specialPresentation: SpecialPresentation
}
