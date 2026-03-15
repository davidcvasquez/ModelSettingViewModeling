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
#if os(iOS)
import UIKit
#endif

public struct FloatModelSettingView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ModelSettingView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable {

    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization
    @Environment(\.colorScheme) var colorScheme

    public let id: ModelSetting.ID

    @Bindable public var viewModel: ViewModel

    public var viewModelSetting: (any ViewModelSetting)? {
        self.floatModelSetting
    }

    private var floatModelSetting: FloatViewModelSetting<Value>? {
        if Value.self == Double.self {
            guard case .float(let floatSetting) = self.modelSettingType else { return nil }

            return floatSetting as? FloatViewModelSetting<Value>
        }
        else if Value.self == NDFloat.self {
            guard case .ndFloat(let ndFloatSetting) = self.modelSettingType else { return nil }

            return ndFloatSetting as? FloatViewModelSetting<Value>
        }
        else if Value.self == CGFloat.self {
            guard case .cgFloat(let cgFloatSetting) = self.modelSettingType else { return nil }

            return cgFloatSetting as? FloatViewModelSetting<Value>
        }
        else {
            return nil
        }
    }

    @Binding public var isTrackingInput: Bool
    @Binding public var isFocused: Bool

    @State private var isTrackingComponentInput: Bool = false

    @State private var floatProxy: Value = 0.0

    @State private var isPopupOpen = false

    @Namespace var mainNameSpace

    public var body: some View {
        let _ = viewModel.revision
#if DEBUG
        let _ = Self._logChanges()
#endif
        var committed: Value? { floatModelSetting?.committedValue.wrappedValue }
        var tracking: Value?  { floatModelSetting?.trackingValue.wrappedValue }

        return HStack {
            IconComponentView(
                viewModel: viewModel,
                labelIcon: _labelIcon,
                labelText: _labelText,
                isTrackingInput: $isTrackingInput
            )

            if layoutOptions.showControls {
                FloatSliderComponentView<Value, ViewModel>(
                    viewModel: viewModel,
                    floatProxy: $floatProxy,
                    range: range,
                    step: step,
                    labelText: self.labelText,
                    isTrackingInput: $isTrackingComponentInput
                )
            }
            else if layoutOptions.showLabelText {
                RenamableLabelTextComponentView(
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    labelText: labelText,
                    verticalAlignment: .center
                )
            }

            if layoutOptions.showTextFields {
                HStack {
                    switch self.specialPresentation {
                    case .native, .decimal:
                        DecimalTextFieldComponentView<Value, ViewModel>(
                            viewModel: viewModel,
                            floatProxy: $floatProxy,
                            range: self.range,
                            precision: precision,
                            labelText: self.labelText,
                            isTrackingInput: $isTrackingComponentInput,
                            isFocused: $isFocused
                        ) {
                            self.commitFloatProxy()
                        }

                    case .percent:
                        PercentTextFieldComponentView<Value, ViewModel>(
                            viewModel: viewModel,
                            floatProxy: $floatProxy,
                            range: self.range,
                            precision: self.precision,
                            labelText: self.labelText,
                            isTrackingInput: $isTrackingComponentInput,
                            isFocused: $isFocused
                        ) {
                            self.commitFloatProxy()
                        }

                    default:
                        Text("Unsupported")
                    }

                    if layoutOptions.controlOptions == .showTextFieldWithPopupControl {
#if os(macOS)
                        PopoverButtonView(
                            layoutOptions: self.layoutOptions,
                            colorScheme: self.colorScheme,
                            labelText: self.labelText,
                            isPopupOpen: $isPopupOpen
                        )
                        .popover(
                            isPresented: $isPopupOpen,
                            attachmentAnchor: .rect(.bounds),
                            arrowEdge: .bottom
                        ) {
                            PopoverFloatSliderComponentView(
                                viewModel: viewModel,
                                floatProxy: $floatProxy, range: self.range, step: self.step,
                                labelText: self.labelText,
                                isTrackingInput: $isTrackingComponentInput
                            )
                        }
#endif
#if os(iOS)
                        PopoverButtonView(
                            layoutOptions: self.layoutOptions,
                            colorScheme: self.colorScheme,
                            labelText: self.labelText,
                            isPopupOpen: $isPopupOpen
                        ) { anchorView in
                            PopoverPresenter.shared.present(
                                from: anchorView,
                                content: PopoverFloatSliderComponentView(
                                    viewModel: viewModel,
                                    floatProxy: $floatProxy,
                                    range: self.range,
                                    step: self.step,
                                    labelText: self.labelText,
                                    isTrackingInput: $isTrackingComponentInput
                                ),
                                localization: self.localization,
                                contentSize: self.layoutOptions.popupSliderContentSize
                            ) {
                                isPopupOpen = false
                            }
                        }
#endif
                    }
                } // HStack
            }

            if layoutOptions.showSteppers {
                FloatStepperComponentView<Value, ViewModel>(
                    viewModel: viewModel,
                    floatProxy: $floatProxy,
                    range: range,
                    step: step,
                    labelText: self.labelText,
                    isTrackingInput: $isTrackingComponentInput
                ) {
                    self.commitFloatProxy()
                }
            }
        } // HStack
        .padding([.horizontal])
        .onAppear() {
            if let value = committed {
                floatProxy = Value(NDFloat(value).rounded(self.precision))
            }
        }
        .onChange(of: isTrackingComponentInput) {
            self.isTrackingInput = isTrackingComponentInput
            if !isTrackingComponentInput {
                self.commitFloatProxy()
            }
        }
        .onSubmit {
            onSubmit()
        }
        .onChange(of: viewModel.revision) { _, _ in
            Swift.print(".onChange(of: viewModel.revision)", [
                "committed": "\(String(describing: committed))",
                "isTrackingInput": "\(isTrackingInput)"
                ])

            if !isTrackingInput, let v = self.floatModelSetting?.committedValue.wrappedValue {
                let rounded = Value(NDFloat(v).rounded(precision))
                if rounded != floatProxy {
                    floatProxy = rounded
                }
            }
        }
        .onChange(of: floatProxy) {
            if isTrackingInput || isTrackingComponentInput {
                let ndValue = NDFloat(floatProxy)
                var newValue = Value(ndValue.rounded(self.precision))
                newValue = newValue.clamped(to: self.range)
                if newValue != self.floatModelSetting?.trackingValue.wrappedValue {
                    self.floatModelSetting?.trackingValue.wrappedValue = newValue
                }
            }
        }
    }

    var precision: RoundingPrecision {
        self.floatModelSetting?.action.precision ?? .hundredths
    }

    var range: ClosedRange<Value> {
        self.floatModelSetting?.action.range ?? 0.0...100.0
    }

    var step: Value.Stride {
        self.floatModelSetting?.action.step ?? 1.0
    }

    func commitFloatProxy() {
        let ndValue = NDFloat($floatProxy.wrappedValue)
        var newValue = Value(ndValue.rounded(self.precision))
        newValue = newValue.clamped(to: self.range)
        if newValue != self.floatModelSetting?.committedValue.wrappedValue {
            self.floatModelSetting?.committedValue.wrappedValue = newValue
        }
    }

    func onSubmit() {
#if os(macOS)
        // https://developer.apple.com/forums/thread/678388
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
#endif
        self.commitFloatProxy()
    }

    // Computed in case we want to make precision variable later on.
    private var textFieldWidth: NDFloat {
        65
    }
}
