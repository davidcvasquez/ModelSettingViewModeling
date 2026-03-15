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
import NDGeometry

/// Lays out 3 subviews in order: main, divider, options.
/// - If proposedWidth/proposedHeight >= aspectThreshold => horizontal split
/// - Else => vertical split
/// - optionsFraction is the fraction of the main axis given to the options view (0.35 = 35%)
struct AdaptiveOptionsSplitLayout: Layout {
    var optionsFraction: CGFloat = 0.35
    var isHorizontal: Bool = true
    var aspectThreshold: CGFloat = 1.0          // 1.0 == wider-than-tall => horizontal
    var dividerThickness: CGFloat = 1.0
    var minimumOptionsMainAxis: CGFloat = 200   // optional safety clamp
    var minimumMainMainAxis: CGFloat = 200      // optional safety clamp

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        // Accept the proposed size if it exists; otherwise fall back to measuring.
        // We pin maxWidth/maxHeight to infinity, so proposal is usually non-nil.
        let w = proposal.width
        let h = proposal.height
        if let w, let h { return CGSize(width: w, height: h) }

        // Fallback measurement
        let main = subviews.first?.sizeThatFits(.unspecified) ?? .zero
        let options = subviews.dropFirst(2).first?.sizeThatFits(.unspecified) ?? .zero
        return CGSize(width: max(main.width, options.width), height: max(main.height, options.height))
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard subviews.count == 3 else {
            // If caller accidentally passes in the wrong number of children, just stack them.
            var y = bounds.minY
            for s in subviews {
                let sz = s.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
                s.place(at: CGPoint(x: bounds.minX, y: y),
                        anchor: .topLeading,
                        proposal: ProposedViewSize(width: bounds.width, height: sz.height))
                y += sz.height
            }
            return
        }

        let main = subviews[0]
        let divider = subviews[1]
        let options = subviews[2]

        if isHorizontal {
            let total = bounds.width
            let usable = max(0, total - dividerThickness)

            var optionsW = usable * optionsFraction
            var mainW = usable - optionsW

            // Clamp (optional safety)
            optionsW = max(minimumOptionsMainAxis, optionsW)
            mainW = max(minimumMainMainAxis, mainW)

            // Re-balance if clamping overflowed
            if mainW + optionsW > usable {
                // Prefer keeping main usable
                optionsW = max(minimumOptionsMainAxis, usable - mainW)
                mainW = usable - optionsW
            }

            let mainRect = CGRect(
                x: bounds.minX, y: bounds.minY,
                width: mainW, height: bounds.height)

            let dividerRect = CGRect(
                x: mainRect.maxX, y: bounds.minY,
                width: dividerThickness, height: bounds.height)

            let optionsRect = CGRect(
                x: dividerRect.maxX, y: bounds.minY,
                width: bounds.maxX - dividerRect.maxX, height: bounds.height)

            main.place(
                at: mainRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: mainRect.width, height: mainRect.height)
            )

            divider.place(
                at: dividerRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: dividerRect.width, height: dividerRect.height)
            )

            options.place(
                at: optionsRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: optionsRect.width, height: optionsRect.height)
            )
        } else {
            let total = bounds.height
            let usable = max(0, total - dividerThickness)

            var optionsH = usable * optionsFraction
            var mainH = usable - optionsH

            // Clamp (optional safety)
            optionsH = max(minimumOptionsMainAxis, optionsH)
            mainH = max(minimumMainMainAxis, mainH)

            if mainH + optionsH > usable {
                optionsH = max(minimumOptionsMainAxis, usable - mainH)
                mainH = usable - optionsH
            }

            let mainRect = CGRect(
                x: bounds.minX, y: bounds.minY,
                width: bounds.width, height: mainH)

            let dividerRect = CGRect(
                x: bounds.minX, y: mainRect.maxY,
                width: bounds.width, height: dividerThickness)

            let optionsRect = CGRect(
                x: bounds.minX, y: dividerRect.maxY,
                width: bounds.width, height: bounds.maxY - dividerRect.maxY)

            main.place(
                at: mainRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: mainRect.width, height: mainRect.height)
            )

            divider.place(
                at: dividerRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: dividerRect.width, height: dividerRect.height)
            )

            options.place(
                at: optionsRect.origin,
                anchor: .topLeading,
                proposal: ProposedViewSize(width: optionsRect.width, height: optionsRect.height)
            )
        }
    }
}
