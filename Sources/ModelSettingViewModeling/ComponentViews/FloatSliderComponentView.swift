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

public struct FloatSliderComponentView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable
{
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization

    public let viewModel: ViewModel

    @Binding private var floatProxy: Value

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        floatProxy: Binding<Value>,
        range: ClosedRange<Value>,
        step: Value.Stride,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._floatProxy = floatProxy
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.step = step
        self.labelText = labelText
    }

    private var labelText: LocalizationKey
    private var range: ClosedRange<Value>
    private var step: Value.Stride

    public var body: some View {
        Group {
            ZStack {
                RenamableLabelTextComponentView(
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    labelText: labelText,
                    verticalAlignment: .top
                )

                Slider(value: $floatProxy, in: self.range) { editing in
                    self.isTrackingInput = editing
                }
                .opacity(isEnabled ? 1.0 : 0.25)
                .help(self.labelText)
                .listRowBackground(Rectangle().fill(Material.ultraThinMaterial))
                .padding(layoutOptions.sliderEdgeInsets)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

public struct PopoverFloatSliderComponentView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable
{
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization

    public let viewModel: ViewModel

    @Binding private var floatProxy: Value

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        floatProxy: Binding<Value>,
        range: ClosedRange<Value>,
        step: Value.Stride,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._floatProxy = floatProxy
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.step = step
        self.labelText = labelText
    }

    private var labelText: LocalizationKey
    private var range: ClosedRange<Value>
    private var step: Value.Stride

    public var body: some View {
        Slider(value: $floatProxy, in: self.range) { editing in
            self.isTrackingInput = editing
        }
        .opacity(isEnabled ? 1.0 : 0.25)
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
}
