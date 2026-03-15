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

/// A popup button view.
public struct PopoverButtonView: View {
    public let layoutOptions: ModelSettingViewLayoutOptions
    public let colorScheme: ColorScheme
    public var labelText: LocalizationKey
    @Binding public var isPopupOpen: Bool

#if os(iOS)
    public var present: (_ anchor: UIView) -> Void

    @State private var buttonAnchorView: UIView?
#endif

    public var body: some View {
        Button {
            isPopupOpen.toggle()
#if os(iOS)
            if isPopupOpen, let anchor = buttonAnchorView {
                self.present(anchor)
            }
#endif

        } label: {
            Image(systemName: self.layoutOptions.popupButtonSymbolName)
                .font(self.layoutOptions.popupButtonFont)
                .frame(
                    width: self.layoutOptions.popupButtonFrameSize,
                    height: self.layoutOptions.popupButtonFrameSize
                )
                .foregroundStyle(self.layoutOptions.popupButtonSymbolColor(
                    isPopupOpen: isPopupOpen
                ))
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: self.layoutOptions.popupButtonCornerRadius)
                        .fill(self.layoutOptions.popupButtonBackgroundColor(
                            isPopupOpen: isPopupOpen,
                            colorScheme: colorScheme
                        ))
                )

#if os(iOS)
            // Resolve a UIView to serve as an anchor.
            ViewIntrospect { view in
                if buttonAnchorView == nil {
                    buttonAnchorView = view
                }
            }
            .allowsHitTesting(false) // don't interfere with button taps
#endif
        }
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
        .buttonStyle(.plain)
        .help(self.labelText)
    }
}
