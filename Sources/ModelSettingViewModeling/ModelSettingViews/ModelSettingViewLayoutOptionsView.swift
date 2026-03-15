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
import LocalizableStringBundle

/// A view with layout options for model setting views, including adaptive, preset, or custom layout sizes.
public struct ModelSettingViewLayoutOptionsView: View {
    @Environment(\.isEnabled) public var isEnabled
    @Bindable public var viewModels: ModelSettingViewModels

    public init(viewModels: ModelSettingViewModels) {
        self.viewModels = viewModels
    }

    public var body: some View {
        HStack {
            if viewModels.layoutOptions.reorderSettings {
                Button {
                    viewModels.layoutOptions.reorderSettings = false
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.tint)
                        .frame(width: 20, height: 20)
                        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                }
                .controlSize(.extraLarge)
                .frame(alignment: .init(horizontal: .trailing, vertical: .center))
                .buttonStyle(.plain)
                .disabled(false)
                .help("Done")
            }
            else {
                Button {
                    viewModels.layoutOptions.reorderSettings = true
                } label: {
                    Label(.reorderLabel, systemImage: "arrow.up.arrow.down")
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.plain)
            }

            Menu {
                Button {
                    viewModels.viewModels.values.forEach { viewModel in
                        viewModel.resetViewStyles()
                    }
                } label: {
                    Label(.resetSettingsLabel, systemImage: "eraser")
                }

                Divider()

                Picker(LocalizationKey.layoutLabel.resource, selection: $viewModels.layoutOptions.layoutSize) {
                    ForEach(ModelSettingViewLayoutOptions.LayoutSizeOptions.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)

                Divider()

                Picker(LocalizationKey.labelsLabel.resource,
                       selection: $viewModels.layoutOptions.labelOptions) {
                    ForEach(ModelSettingViewLayoutOptions.LabelOptions.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .disabled(viewModels.layoutOptions.isFixedSizeLayout)

                Picker(LocalizationKey.controlsLabel.resource,
                       selection: $viewModels.layoutOptions.controlOptions) {
                    ForEach(ModelSettingViewLayoutOptions.ControlOptions.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .disabled(viewModels.layoutOptions.isFixedSizeLayout)

                Picker(LocalizationKey.steppersLabel.resource,
                       selection: $viewModels.layoutOptions.stepperOptions) {
                    ForEach(ModelSettingViewLayoutOptions.StepperOptions.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .disabled(viewModels.layoutOptions.isFixedSizeLayout)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.tint)
                    .opacity(iconOpacity)
                    .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            }
            .buttonStyle(.plain)
            .help("Customize Settings")
            .controlSize(.extraLarge)
            .padding([.horizontal, .vertical])
            .menuIndicator(.hidden)
        }
    }

    public var iconOpacity: CGFloat {
        self.isEnabled ? 0.85 : 0.2
    }
}
