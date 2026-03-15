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
import LocalizableStringBundle

public struct IconComponentView<
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled

    public let viewModel: ViewModel

    @Binding public var labelIcon: IconName?
    @Binding public var labelText: LocalizationKey?

    @Binding public var isTrackingInput: Bool

    let iconSize: CGFloat = 24

    public init(
        viewModel: ViewModel,
        labelIcon: Binding<IconName?>,
        labelText: Binding<LocalizationKey?>,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._labelIcon = labelIcon
        self._labelText = labelText
        self._isTrackingInput = isTrackingInput
    }

    public var body: some View {
        HStack {
            if layoutOptions.showIcons {
                switch self.labelIcon {
                case .system(let name):
                    Image(systemName: name)
                        .resizable()
                        .scaledToFit()
                        .opacity(self.iconOpacity)
                        .frame(width: iconSize, height: iconSize)
                        .help(self.labelText ?? .missing)

                case .local(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .opacity(self.iconOpacity)
                        .frame(width: iconSize, height: iconSize)
                        .help(self.labelText ?? .missing)

                case .none:
                    EmptyView()
                }
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: layoutOptions.horizontalSettingGroupNoIconMargin,
                           height: layoutOptions.verticalNoIconMargin)
            }
        }
    }

    private var iconOpacity: NDFloat {
        self.isEnabled ? 0.80 : 0.33
    }
}
