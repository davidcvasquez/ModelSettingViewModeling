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

public struct PercentTextFieldComponentView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ViewModelComponentView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable
{
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var focused: Bool

    public let viewModel: ViewModel

    @Binding private var floatProxy: Value

    @Binding public var isTrackingInput: Bool
    @Binding public var isFocused: Bool

    public init(
        viewModel: ViewModel,
        floatProxy: Binding<Value>,
        range: ClosedRange<Value>,
        precision: RoundingPrecision,
        labelText: LocalizationKey,
        isTrackingInput: Binding<Bool>,
        isFocused: Binding<Bool>,
        onCommit: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self._floatProxy = floatProxy
        self._isTrackingInput = isTrackingInput
        self._isFocused = isFocused
        self.range = range
        self.precision = precision
        self.labelText = labelText
        self.onCommit = onCommit
    }

    private var range: ClosedRange<Value>
    private var precision: RoundingPrecision
    private var labelText: LocalizationKey
    private var onCommit: () -> Void

    @Namespace var mainNameSpace

    public var body: some View {
        Group {
            TextField(
                "",
                value: $floatProxy,
                format: FloatingPointFormatStyle<Value>.Percent().precision(
                    .fractionLength(max(0, self.precision.decimalPlaces - 2)))
            )
            .opacity(isEnabled ? 1.0 : 0.25)
            .focused($focused)
            .help(self.labelText)
#if os(iOS)
            .keyboardType(.decimalPad)
            .submitLabel(.done)
#endif
#if os(macOS)
            .prefersDefaultFocus(false, in: mainNameSpace)
#endif
            .onChange(of: focused) { _, nowFocused in
                // Resigning focus, by tabbing out or clicking elsewhere, commits the value.
                if !nowFocused {
                    self.onCommit()
                }
#if os(iOS)
                if self.isFocused != nowFocused {
                    self.isFocused = nowFocused
                }
#endif
            }
#if os(iOS)
            .onAppear {
                self.focused = self.isFocused
            }
            .onChange(of: isFocused) { _, nowFocused in
                if !nowFocused {
                    self.onCommit()
                    self.focused = false
                }
            }
#endif
            .onSubmit {
                self.isTrackingInput = false
                var newValue = $floatProxy.wrappedValue
                newValue = newValue.clamped(to: self.range)
                if newValue != $floatProxy.wrappedValue {
                    $floatProxy.wrappedValue = newValue
                }
            }
            .textFieldStyle(.roundedBorder)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: -4))
            .frame(
                width: Self.textFieldWidth,
                alignment: .trailing
            )
        }
    }

    // Computed in case we want to use precision variable later on.
    private static var textFieldWidth: NDFloat {
        65
    }
}
