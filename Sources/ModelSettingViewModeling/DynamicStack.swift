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

/// A stack view that can dynamically switch between a horizontal and vertical stack, in lazy mode or not.
///
/// Usage of ``DynamicStack`` in a view:
///
///     struct SampleConditionalStackView: View {
///         @State private var isPortraitOrientation = true
///
///         var body: some View {
///             VStack {
///                 Toggle("Is Portrait", isOn: $isPortraitOrientation)
///                     .padding()
///
///                 DynamicStack(
///                     orientation: isPortraitOrientation ? .portrait : .landscape,
///                     isLazy: false
///                 ) {
///                     Text("A")
///                     Text("B")
///                     Text("C")
///                 }
///             }
///             .padding()
///         }
///     }
///
public struct DynamicStack<Content: View>: View {
    public let orientation: Orientation
    public let isLazy: Bool

    @ViewBuilder public let content: Content

    public init(orientation: Orientation, isLazy: Bool, @ViewBuilder content: () -> Content) {
        self.orientation = orientation
        self.isLazy = isLazy
        self.content = content()
    }

    public var body: some View {
        Group {
            if orientation == .landscape {
                if isLazy {
                    LazyHStack {
                        content
                    }
                }
                else {
                    HStack {
                        content
                    }
                }
            } else {
                if isLazy {
                    LazyVStack {
                        content
                    }
                }
                else {
                    VStack {
                        content
                    }
                }
            }
        }
    }
}
