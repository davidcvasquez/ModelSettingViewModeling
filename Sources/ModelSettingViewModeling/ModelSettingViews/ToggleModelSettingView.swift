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

public struct ToggleModelSettingView<ViewModel: ModelSettingViewModel>: ModelSettingView {
    @Environment(\.isEnabled) private var isEnabled

    public let id: ModelSetting.ID

    public let viewModel: ViewModel

    public var viewModelSetting: (any ViewModelSetting)? {
        self.boolModelSetting
    }

    private var boolModelSetting: BoolViewModelSetting? {
        guard case .boolean(let boolSetting) = self.modelSettingType else { return nil }

        return boolSetting
    }

    @Binding public var isTrackingInput: Bool
    @State private var isTrackingComponentInput: Bool = false

    @State private var boolProxy: Bool = false

    public var body: some View {
        let _ = viewModel.revision

        var committed: Bool? { boolModelSetting?.committedValue.wrappedValue }

        HStack {
            IconComponentView(
                viewModel: viewModel,
                labelIcon: _labelIcon,
                labelText: _labelText,
                isTrackingInput: $isTrackingInput
            )

            switch self.viewStyle?.specialPresentation {
            case .native:
                Toggle(isOn: $boolProxy) {
                    Text(self.labelText)
                }
                .padding(EdgeInsets(
                    top: 2,
                    leading: layoutOptions.showIcons ? 20 : 40,
                    bottom: 10, trailing: 0))

            case .iconButtonToggle(let iconName):
                IconButtonToggleComponentView(
                    viewModel: viewModel,
                    isOn: $boolProxy,
                    iconName: iconName,
                    labelText: self._labelText,
                    isTrackingInput: $isTrackingComponentInput
                )

            default:
                Text("Unsupported presentation style")
            }
        } // HStack
        .onAppear {
            if let booleanCommit = self.boolModelSetting?.committedValue.wrappedValue {
                self.boolProxy = booleanCommit
            }
        }
        .onChange(of: boolProxy) {
            if let booleanCommit = self.boolModelSetting?.committedValue.wrappedValue {
                if booleanCommit != self.boolProxy {
                    self.boolModelSetting?.committedValue.wrappedValue = self.boolProxy
                }
            }
        }
        .onChange(of: viewModel.revision) { _, _ in
            Swift.print(".onChange(of: viewModel.editTick)", [
                "committed": "\(String(describing: committed))",
                "isTrackingInput": "\(isTrackingInput)"
                ])

            if !isTrackingInput, let booleanCommit = self.boolModelSetting?.committedValue.wrappedValue {
                if booleanCommit != self.boolProxy {
                    self.boolProxy = booleanCommit
                }
            }
        }
    }
}
