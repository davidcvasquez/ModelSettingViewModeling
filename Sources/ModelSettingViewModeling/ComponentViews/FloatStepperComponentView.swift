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

public struct FloatStepperComponentView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable
{
    @Environment(\.isEnabled) private var isEnabled

    @Bindable public var viewModel: ViewModel

    @Binding private var floatProxy: Value

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        floatProxy: Binding<Value>,
        range: ClosedRange<Value>,
        step: Value.Stride,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>,
        onCommit: @escaping () -> Void
   ) {
        self.viewModel = viewModel
        self._floatProxy = floatProxy
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.step = step
        self.labelText = labelText
        self.onCommit = onCommit
    }

    private var labelText: LocalizationKey
    private var range: ClosedRange<Value>
    private var step: Value.Stride
    private var onCommit: () -> Void

    private var stepperEdgeInsets: EdgeInsets {
        EdgeInsets(
            top: layoutOptions.stepperOptions == .largeStepper ? 4.0 : 0,
            leading: -4,
            bottom: layoutOptions.stepperOptions == .largeStepper ? 4.0 : 0,
            trailing: 8)
    }

    public var body: some View {
        Stepper(" ", value: $floatProxy,
                in: self.range,
                step: self.step) { editing in
            self.isTrackingInput = editing
            if !editing {
                onCommit()
            }
        }
        .opacity(isEnabled ? 1.0 : 0.25)
        .help(self.labelText)
        .controlSize(layoutOptions.stepperOptions == .largeStepper ? .extraLarge : .regular)
        .padding(self.stepperEdgeInsets)
        .fixedSize(horizontal: true, vertical: true)
        .frame(alignment: .trailing)
    }
}
