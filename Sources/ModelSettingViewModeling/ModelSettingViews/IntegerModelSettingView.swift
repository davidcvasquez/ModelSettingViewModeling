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

public struct IntegerModelSettingView<ViewModel: ModelSettingViewModel>: ModelSettingView {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization
    @Environment(\.colorScheme) var colorScheme

    @FocusState private var focused: Bool

    public let id: ModelSetting.ID

    @Bindable public var viewModel: ViewModel


    public var viewModelSetting: (any ViewModelSetting)? {
        self.intModelSetting
    }

    private var intModelSetting: IntegerViewModelSetting? {
        guard case .integer(let intSetting) =
                self.viewModel.modelSettingTypes.types[id]?.settingType else { return nil }
        return intSetting
    }

    @Binding public var isTrackingInput: Bool
    @State private var isTrackingComponentInput: Bool = false
    @Binding public var isFocused: Bool

    @State private var floatProxy: NDFloat = 0.0
    @State private var integerProxy: Int = 0

    @State private var isPopupOpen = false

    @Namespace var mainNameSpace

    public var body: some View {
        HStack {
            IconComponentView(
                viewModel: viewModel,
                labelIcon: _labelIcon,
                labelText: _labelText,
                isTrackingInput: $isTrackingInput
            )

            if layoutOptions.showControls {
                IntegerSliderComponentView(
                    viewModel: viewModel,
                    integerValue: $integerProxy,
                    range: self.range,
                    labelText: self.labelText,
                    isTrackingInput: $isTrackingComponentInput
                )
            }
            else if layoutOptions.showLabelText {
                RenamableLabelTextComponentView(
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    labelText: labelText,
                    verticalAlignment: .top
                )
            }

            if layoutOptions.showTextFields {
                HStack {
                    IntegerTextFieldComponentView(
                        viewModel: viewModel,
                        integerProxy: $integerProxy,
                        range: self.range,
                        labelText: self.labelText,
                        isTrackingInput: $isTrackingComponentInput,
                        isFocused: $isFocused
                    ) {
                        self.commitIntegerProxy()
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
                            PopoverIntegerSliderComponentView(
                                viewModel: viewModel,
                                integerValue: $integerProxy,
                                range: self.range,
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
                                content: PopoverIntegerSliderComponentView(
                                    viewModel: viewModel,
                                    integerValue: $integerProxy,
                                    range: self.range,
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
                IntegerStepperComponentView(
                    viewModel: viewModel,
                    integerProxy: $integerProxy,
                    range: self.range,
                    step: 1,
                    labelText: self.labelText,
                    isTrackingInput: $isTrackingComponentInput
                )
            }
        }
        .padding([.horizontal])
        .onAppear() {
            if let value = intModelSetting?.committedValue.wrappedValue {
                $floatProxy.wrappedValue = NDFloat(value)
            }
        }
        .onChange(of: isTrackingComponentInput) {
            self.isTrackingInput = isTrackingComponentInput
            if !isTrackingComponentInput {
                self.commitIntegerProxy()
            }
        }
        .onChange(of: intModelSetting?.committedValue.wrappedValue) {
            (_, newValue: Int?) in

            if let newValue, newValue != Int($floatProxy.wrappedValue) {
                $floatProxy.wrappedValue = NDFloat(newValue)
                $integerProxy.wrappedValue = Int(newValue)
            }
        }
        .onSubmit {
            onSubmit()
        }
        .onChange(of: viewModel.revision) { _, _ in
            if !isTrackingInput, let newValue = self.intModelSetting?.committedValue.wrappedValue {
                if newValue != integerProxy {
                    $floatProxy.wrappedValue = NDFloat(newValue)
                    $integerProxy.wrappedValue = Int(newValue)
                }
            }
        }
        .onChange(of: integerProxy) {
            if isTrackingInput || isTrackingComponentInput {
                let newValue = integerProxy.clamped(to: self.range)
                if newValue != self.intModelSetting?.trackingValue.wrappedValue {
                    self.intModelSetting?.trackingValue.wrappedValue = newValue
                }
            }
        }
    }

    func commitIntegerProxy() {
        var newValue = $integerProxy.wrappedValue
        newValue = newValue.clamped(to: self.range)
        if newValue != self.intModelSetting?.committedValue.wrappedValue {
            self.intModelSetting?.committedValue.wrappedValue = newValue
        }
    }

    func onSubmit() {
#if os(macOS)
            // https://developer.apple.com/forums/thread/678388
            DispatchQueue.main.async {
                NSApplication.shared.keyWindow?.makeFirstResponder(nil)
            }
#endif
        commitIntegerProxy()
    }

    var labelText: LocalizationKey {
        viewModel.modelSettingViewStyles.viewStyles[id]?.labelText ?? .missing
    }

    var range: ClosedRange<Int> {
        self.intModelSetting?.action.range ?? 0...100
    }
}
