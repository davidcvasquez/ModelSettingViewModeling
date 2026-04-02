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
import ModelSettingViewModeling
import OrderedCollections

struct ContentView: View {
    @Environment(\.isEnabled) private var isEnabled

    @ObservedObject var document: Document
    @Bindable private var layoutOptions: ModelSettingViewLayoutOptions

    @State private var viewModels: ModelSettingViewModels

    @State private var isTrackingInput: Bool = false

    init(
        document: Document,
        layoutOptions: ModelSettingViewLayoutOptions
    ) {
        self.document = document
        self._layoutOptions = Bindable(wrappedValue: layoutOptions)
        self.viewModels = Self.buildViewModels(
            document: document, layoutOptions: layoutOptions)
    }

    var body: some View {
        let _ = document.revision // ensures re-evaluation after undo/redo
#if DEBUG
        let _ = Self._logChanges()
        let _ = { Swift.print("ShapeOptionsView doc:", ObjectIdentifier(document)) }()
#endif

        GeometryReader { proxy in
//            let size = proxy.size

            VStack(spacing: 8) {
                HStack {
                    Text("Stack of Settings")
                        .font(.title3)
                        .opacity(captionOpacity)
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 4, trailing: 0))
                    Spacer()

                    ModelSettingViewLayoutOptionsView(viewModels: viewModels)
                }
                .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ModelSettingStackOfGridsView(
                            viewModels: viewModels,
                            isTrackingInput: $isTrackingInput
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    var captionOpacity: CGFloat {
        self.isEnabled ? 0.67 : 0.2
    }

    private static func buildViewModels(
        document: Document,
        layoutOptions: ModelSettingViewLayoutOptions
    ) -> ModelSettingViewModels {
        ModelSettingViewModels(
            viewModels: [
            .testSettingsID: TestModelSettingViewModel(
                containerCollection: document,
                layoutOptions: layoutOptions)
            ],
            layoutOptions: layoutOptions)
    }
}
