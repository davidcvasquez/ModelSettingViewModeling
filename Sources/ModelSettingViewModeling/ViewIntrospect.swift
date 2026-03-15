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

#if os(iOS)

/// Resolves a UIView to serve as an anchor.
public struct ViewIntrospect: UIViewRepresentable {
    var onResolve: (UIView) -> Void

    /// Creates the view object and configures its initial state.
    public func makeUIView(context: Context) -> UIView {
        let v = UIView(frame: .zero)
        DispatchQueue.main.async { onResolve(v) }
        return v
    }

    /// Updates the state of the specified view with new information from SwiftUI.
    public func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async { onResolve(uiView) }
    }
}

public extension UIView {
    /// - Returns: The UIViewController associated with this UIView.
    func findViewController() -> UIViewController? {
        sequence(first: self, next: { $0.next as? UIView })
            .compactMap { $0.next as? UIViewController }
            .first
        ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.rootViewController
    }
}

#endif
