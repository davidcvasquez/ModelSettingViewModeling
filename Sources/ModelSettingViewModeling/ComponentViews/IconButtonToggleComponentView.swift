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

public struct IconButtonToggleComponentView<
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled

    public let viewModel: ViewModel

    @Binding public var isOn: Bool
    public let iconName: IconName
    @Binding public var labelText: LocalizationKey?
    @Binding public var isTrackingInput: Bool

    public static var defaultSymbolSize: CGFloat {
        14.0
    }
    public var symbolSize: CGFloat = defaultSymbolSize

    public static var defaultSymbolPadding: CGFloat {
        4.0
    }
    public var symbolPadding: CGFloat = defaultSymbolPadding

    public var totalSymbolSize: CGFloat {
        symbolSize + symbolPadding * 2.0
    }

    public var body: some View {
        Button {
            isOn.toggle()
        } label: {
            // Wrap the image in a padded container so background respects padding
            let icon: Image = {
                switch iconName {
                case .system(let name):
                    return Image(systemName: name)
                case .local(let name):
                    return Image(name)
                }
            }()

            icon
                .font(.system(size: symbolSize))
                .padding(symbolPadding)
                .background(
                    Circle()
                        .fill(isOn ? Color.accentColor : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .help(self.labelText ?? .missing)
    }
}
