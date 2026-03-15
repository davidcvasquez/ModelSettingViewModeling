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

    private let factory: ModelSettingGridViewFactory

    public init(
        viewModels: ModelSettingViewModels,
        isTrackingInput: Binding<Bool>,
        factory: ModelSettingGridViewFactory
    ) {
        self._viewModels = Bindable(wrappedValue: viewModels)
        self._isTrackingInput = isTrackingInput
        self.factory = factory
    }

    public var body: some View {
        ForEach(viewModels.viewModels.keys, id: \.self) { id in
            if let view = factory.makeGridView(
                for: id,
                from: viewModels,
                isTrackingInput: $isTrackingInput,
                focusedID: $focusedID
            ) {
                view
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

public protocol ModelSettingGridViewFactory {
    func makeGridView(
        for id: ModelSetting.ID,
        from store: ModelSettingViewModels,
        isTrackingInput: Binding<Bool>,
        focusedID: Binding<ModelSetting.ID?>
    ) -> AnyView?
}
