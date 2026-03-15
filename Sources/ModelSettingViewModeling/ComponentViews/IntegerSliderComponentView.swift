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
import LocalizableStringBundle

public struct IntegerSliderComponentView<
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled

    public let viewModel: ViewModel

    @Binding private var integerValue: Int

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        integerValue: Binding<Int>,
        range: ClosedRange<Int>,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._integerValue = integerValue
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.labelText = labelText

        self.floatProxy = NDFloat(integerValue.wrappedValue)
    }

    @State private var floatProxy: NDFloat

    private var labelText: LocalizationKey
    private var range: ClosedRange<Int>

    private var floatRange: ClosedRange<NDFloat> {
        NDFloat(range.lowerBound)...NDFloat(range.upperBound)
    }

    public var body: some View {
        Group {
            ZStack {
                if layoutOptions.showLabelText {
                    Text(self.labelText)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .padding(EdgeInsets(top: layoutOptions.verticalTitleMargin,
                                            leading: 20.0, bottom: 0, trailing: 0))
                        .font(.caption2)
                        .opacity(captionOpacity)
                }

                Slider(value: $floatProxy, in: self.floatRange) { editing in
                    self.isTrackingInput = editing
                }
                .opacity(isEnabled ? 1.0 : 0.25)
                .onChange(of: floatProxy) {
                    integerValue = Int($floatProxy.wrappedValue)
                }
                .help(self.labelText)
                .listRowBackground(Rectangle().fill(Material.ultraThinMaterial))
                .padding(layoutOptions.sliderEdgeInsets)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.67 : 0.2
    }
}

public struct PopoverIntegerSliderComponentView<
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled

    public let viewModel: ViewModel

    @Binding private var integerValue: Int

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        integerValue: Binding<Int>,
        range: ClosedRange<Int>,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._integerValue = integerValue
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.labelText = labelText

        self.floatProxy = NDFloat(integerValue.wrappedValue)
    }

    @State private var floatProxy: NDFloat

    private var labelText: LocalizationKey
    private var range: ClosedRange<Int>

    private var floatRange: ClosedRange<NDFloat> {
        NDFloat(range.lowerBound)...NDFloat(range.upperBound)
    }

    public var body: some View {
        Slider(value: $floatProxy, in: self.floatRange) { editing in
            self.isTrackingInput = editing
        }
        .opacity(isEnabled ? 1.0 : 0.25)
        .onChange(of: floatProxy) {
            integerValue = Int($floatProxy.wrappedValue)
        }
        .help(self.labelText)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
#if os(macOS)
        .frame(width: self.layoutOptions.popupSliderContentSize.width,
               height: self.layoutOptions.popupSliderContentSize.height,
               alignment: .center)
#endif
        .background {
            RoundedRectangle(cornerRadius: 6)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
        }
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.67 : 0.2
    }
}
