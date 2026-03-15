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

#if os(iOS)
import UIKit

final class PopoverPresenter: NSObject, UIPopoverPresentationControllerDelegate {
    static let shared = PopoverPresenter()
    private override init() {}

    func present<Content>(
        from sourceView: UIView,
        content: Content,
        localization: LocalizationRuntime,
        contentSize: CGSize,
        isDial: Bool = false,
        completion: @escaping (() -> Void)
    ) where Content: View {
        let hosting = UIHostingController(rootView: content.environment(localization))
        hosting.modalPresentationStyle = .popover
        hosting.preferredContentSize = contentSize

        guard let popover = hosting.popoverPresentationController else { return }
        popover.sourceView = sourceView
        popover.sourceRect = sourceView.bounds.offsetBy(dx: isDial ? 42.0 : 0.0, dy: 0.0)
        popover.permittedArrowDirections = isDial ? [.right] : [.up, .down]
        popover.canOverlapSourceViewRect = true
        popover.delegate = self
        popover.backgroundColor = UIColor.clear // Let SwiftUI background show through
        popover.passthroughViews = nil // default allows outside taps to dismiss

        if let vc = sourceView.findViewController() {
            vc.present(hosting, animated: true, completion: completion)
        }
    }

    // In compact environments, force popover rather than full screen when possible.
    func adaptivePresentationStyle(
        for controller: UIPresentationController
    ) -> UIModalPresentationStyle {
        return .none
    }
}
#endif
