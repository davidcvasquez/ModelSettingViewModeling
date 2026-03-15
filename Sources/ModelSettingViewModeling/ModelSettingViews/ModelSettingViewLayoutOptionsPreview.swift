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

public struct ModelSettingViewLayoutOptionsPreview<Content: View>: View {
    @State private var isEnabled: Bool = true
    let layoutOptions: ModelSettingViewLayoutOptions
    let maxPreviewHeight: CGFloat
    private let content: () -> Content

    public init(
        layoutOptions: ModelSettingViewLayoutOptions,
        maxPreviewHeight: CGFloat = 800,
         @ViewBuilder content: @escaping () -> Content) {
        self.layoutOptions = layoutOptions
        self.maxPreviewHeight = maxPreviewHeight
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Customize the layout of the view under test.

            // Enter and Exit customize mode.
            HStack {
                Spacer()

                // TODO: Convert to use viewModels:
                // ModelSettingViewLayoutOptionsView(layoutOptions: layoutOptions)
            }
            .padding(.horizontal)
            .padding(.top)

            if layoutOptions.reorderSettings {
                HStack {
                    Toggle("Enabled", isOn: $isEnabled)
                        .fixedSize()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }

            // View under test (and all its descendants) use the same options instance.
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    content()
                        .environment(\.isEnabled, isEnabled)
                        .previewMode()
                        .padding()
                }
            }
            // Grow to content, but stop growing after maxPreviewHeight,
            // at which point it will scroll.
            .frame(minWidth: layoutOptions.minStackWidth,
                   idealWidth: layoutOptions.minStackWidth,
                   maxWidth: layoutOptions.minStackWidth,
                   minHeight: layoutOptions.reorderSettings ? 400 : 320,
                   idealHeight: layoutOptions.reorderSettings ? 400 : 320,
                   maxHeight: maxPreviewHeight - 20.0)
            .panelGlassBackground(
                gray: 0.12,
                shadowColor: layoutOptions.reorderSettings ?
                    Color.orange.opacity(0.50) :
                    Color(.sRGBLinear, white: 0, opacity: 0.33))
            .padding()
        }
        .frame(width: layoutOptions.minStackWidth + 40.0, height: maxPreviewHeight)
    }
}

private struct IsPreviewKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isPreview: Bool {
        get { self[IsPreviewKey.self] }
        set { self[IsPreviewKey.self] = newValue }
    }
}

public extension View {
    func previewMode(_ isPreview: Bool = true) -> some View {
        environment(\.isPreview, isPreview)
    }
}

enum PreviewHeuristics {
    static var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
