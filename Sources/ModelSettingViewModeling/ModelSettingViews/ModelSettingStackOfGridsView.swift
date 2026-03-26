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

public struct ModelSettingStackOfGridsView: View {
    @Bindable public var viewModels: ModelSettingViewModels
    @Binding public var isTrackingInput: Bool

    @State private var focusedID: ModelSetting.ID?

    public init(
        viewModels: ModelSettingViewModels,
        isTrackingInput: Binding<Bool>
    ) {
        self._viewModels = Bindable(wrappedValue: viewModels)
        self._isTrackingInput = isTrackingInput
    }

    public var body: some View {
        ForEach(viewModels.viewModels.keys, id: \.self) { id in
            if let viewModel = viewModels.viewModels[id] {
                ModelSettingGridView(
                    viewModel: AnyModelSettingViewModel(viewModel),
                    isTrackingInput: $isTrackingInput,
                    focusedID: $focusedID
                )
            }
        }
#if os(iOS)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedID = nil     // dismiss
                }
            }
        }
#endif
    }
}
