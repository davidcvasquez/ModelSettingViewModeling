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
import LocalizableStringBundle

public protocol ViewModelComponentView: View {
    associatedtype ViewModel: ModelSettingViewModel

    var viewModel: ViewModel { get }

    var isTrackingInput: Bool { get }
}

public extension ViewModelComponentView {
    var layoutOptions: ModelSettingViewLayoutOptions {
        viewModel.layoutOptions
    }
}

/// A SwiftUI view of a ModelSetting, bound to a ViewModel type that manages type, actions, and presentation style.
public protocol ModelSettingView: View {
    associatedtype ViewModel: ModelSettingViewModel

    /// For live updates, use the @Bindable property wrapper in the conforming type:
    /// ```
    /// @Bindable public var viewModel: ViewModel
    /// ```
    var viewModel: ViewModel { get }

    typealias ID = UUIDBase58
    var id: ID { get }

    /// - The associated ViewModelSetting for this view.
    var viewModelSetting: (any ViewModelSetting)? { get }
}

public extension ModelSettingView {
    /// - Returns: Layout options for model setting views.
    var layoutOptions: ModelSettingViewLayoutOptions {
        viewModel.layoutOptions
    }

    /// - Returns: The model setting type of the value represented by this view.
    var modelSettingType: ModelSettingType? {
        viewModel.modelSettingTypes.types[id]?.settingType
    }

    /// - Returns: The presentation viewing style of this view.
    var viewStyle: ModelSettingViewStyle? {
        viewModel.modelSettingViewStyles.viewStyles[id]
    }

    /// - Returns: The label icon to show in this view.
    var labelIcon: IconName {
        (viewStyle?.labelIcon) ?? .system(name: "suit.diamond.fill")
    }

    /// - Returns: A binding to the label icon to show in this view.
    var _labelIcon: Binding<IconName?> {
        Binding(
            get: {
                viewModel.modelSettingViewStyles.viewStyles[id]?.labelIcon
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: The label text to show in this view.
    var labelText: LocalizationKey {
        viewStyle?.labelText ?? .missing
    }

    /// - Returns: A binding to the label text to show in this view.
    var _labelText: Binding<LocalizationKey?> {
        Binding(
            get: {
                viewModel.modelSettingViewStyles.viewStyles[id]?.labelText
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: Any special presentation attributes used for this view. Use `.native` for the default presentation.
    var specialPresentation: ModelSettingViewStyle.SpecialPresentation? {
        viewStyle?.specialPresentation
    }
}
