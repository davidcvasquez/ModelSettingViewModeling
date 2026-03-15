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

public struct IntegerStepperComponentView<
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled

    public let viewModel: ViewModel

    @Binding private var integerProxy: Int

    @Binding public var isTrackingInput: Bool

    public init(
        viewModel: ViewModel,
        integerProxy: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int.Stride,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._integerProxy = integerProxy
        self._isTrackingInput = isTrackingInput
        self.range = range
        self.step = step
        self.labelText = labelText
    }

    private var labelText: LocalizationKey
    private var range: ClosedRange<Int>
    private var step: Int.Stride

    public var body: some View {
        Stepper(" ", value: $integerProxy,
                in: self.range,
                step: self.step) { editing in
            self.isTrackingInput = editing
        }
        .opacity(isEnabled ? 1.0 : 0.25)
        .help(self.labelText)
        .controlSize(layoutOptions.stepperOptions == .largeStepper ? .extraLarge : .regular)
        .padding(EdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 8))
        .fixedSize(horizontal: true, vertical: true)
        .frame(alignment: .trailing)
    }
}
