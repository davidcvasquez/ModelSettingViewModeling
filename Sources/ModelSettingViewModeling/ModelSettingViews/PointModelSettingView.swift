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

public struct PointModelSettingView<
    Value: BinaryFloatingPoint,
    ViewModel: ModelSettingViewModel
>: ModelSettingView
    where Value.Stride: BinaryFloatingPoint,
          Value: Codable,
          Value.Stride: Codable {

    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization
    @Environment(\.colorScheme) var colorScheme

    @FocusState private var focused: Bool

    public let id: ModelSetting.ID

    @Bindable public var viewModel: ViewModel

    public var viewModelSetting: (any ViewModelSetting)? {
        self.pointModelSetting
    }

    private var pointModelSetting: PointViewModelSetting<Value>? {
        if Value.self == NDFloat.self {
            guard case .ndPoint(let ndPointSetting) = self.modelSettingType else { return nil }

            return ndPointSetting as? PointViewModelSetting<Value>
        }
        else if Value.self == CGFloat.self {
            guard case .cgPoint(let cgFloatSetting) = self.modelSettingType else { return nil }

            return cgFloatSetting as? PointViewModelSetting<Value>
        }
        else {
            return nil
        }
    }

    private var xModelSetting: FloatViewModelSetting<Value>? {
        pointModelSetting?.xSetting
    }

    private var yModelSetting: FloatViewModelSetting<Value>? {
        pointModelSetting?.ySetting
    }

    private var xViewStyle: ModelSettingViewStyle? {
        if let xSettingID = pointModelSetting?.action.xSettingID {
            return viewModel.modelSettingViewStyles.viewStyles[xSettingID]
        }
        else {
            return nil
        }
    }

    private var yViewStyle: ModelSettingViewStyle? {
        if let ySettingID = pointModelSetting?.action.ySettingID {
            return viewModel.modelSettingViewStyles.viewStyles[ySettingID]
        }
        else {
            return nil
        }
    }

    /// - Returns: The label icon to show for the x in this view.
    var xLabelIcon: IconName {
        (viewStyle?.labelIcon) ?? .system(name: "suit.diamond.fill")
    }

    /// - Returns: A binding to the label icon to show for the x in this view.
    var _xLabelIcon: Binding<IconName?> {
        Binding(
            get: {
                viewStyle?.labelIcon
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: The label icon to show for the y in this view.
    var yLabelIcon: IconName {
        var iconName: IconName? = nil
        switch self.specialPresentation {
        case .linkedDecimal(let linkedLabelIcon, _, _, _):
            iconName = linkedLabelIcon

        case .linkedPercent(let linkedLabelIcon, _, _, _):
            iconName = linkedLabelIcon

        default:
            break
        }
        return iconName ?? .system(name: "suit.diamond.fill")
    }

    /// - Returns: A binding to the label icon to show for the y in this view.
    var _yLabelIcon: Binding<IconName?> {
        Binding(
            get: {
                self.yLabelIcon
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: The label text to show for the x in this view.
    var xLabelText: LocalizationKey {
        xViewStyle?.labelText ?? .missing
    }

    /// - Returns: A binding to the label text to show for the x in this view.
    var _xLabelText: Binding<LocalizationKey?> {
        Binding(
            get: {
                xViewStyle?.labelText
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: The label text to show for the y in this view.
    var yLabelText: LocalizationKey {
        var linkedText: LocalizationKey? = nil
        switch self.specialPresentation {
        case .linkedDecimal(_, let linkedLabelText, _, _):
            linkedText = linkedLabelText

        case .linkedPercent(_, let linkedLabelText, _, _):
            linkedText = linkedLabelText

        default:
            break
        }
        return linkedText ?? .missing
    }

    /// - Returns: A binding to the label text to show for the y in this view.
    var _yLabelText: Binding<LocalizationKey?> {
        Binding(
            get: {
                self.yLabelText
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    @Binding public var isTrackingInput: Bool
    @Binding public var focusedID: ModelSetting.ID?

    @State private var isTrackingXComponentInput: Bool = false
    @State private var isTrackingYComponentInput: Bool = false

    @State private var xFloatProxy: Value = 0.0
    @State private var yFloatProxy: Value = 0.0

    @State private var isXPopupOpen = false
    @State private var isYPopupOpen = false

    @Namespace var mainNameSpace

    var stackRowSpacing: CGFloat {
        if layoutOptions.showLabelText {
            return layoutOptions.stepperOptions == .largeStepper ? 6.0 : 4.0
        }
        else {
            return layoutOptions.stepperOptions == .largeStepper ? 6.0 : 4.0
        }
    }

    let sizeSliderTrailingMargin = 33.0

    var toggleTopEdgeInset: CGFloat {
        layoutOptions.showLabelText ? -12.0 : -10.0
    }

    var toggleBottomEdgeInset: CGFloat {
        layoutOptions.showLabelText ? -24.0 : -22.0
    }

    var toggleTrailingEdgeInset: CGFloat {
        switch layoutOptions.stepperOptions {
        case .noStepper:
            -3.0

        case .smallStepper:
            8.0

        case .largeStepper:
            4.0
        }
    }

    var toggleEdgeInsets: EdgeInsets {
        EdgeInsets(
            top: toggleTopEdgeInset,
            leading: layoutOptions.stepperOptions == .noStepper ? 3.0 : 0.0,
            bottom: toggleBottomEdgeInset,
            trailing: toggleTrailingEdgeInset)
    }

    var xCommitted: Value? { xModelSetting?.committedValue.wrappedValue }
    var xTracking: Value?  { xModelSetting?.trackingValue.wrappedValue }

    var yCommitted: Value? { yModelSetting?.committedValue.wrappedValue }
    var yTracking: Value?  { yModelSetting?.trackingValue.wrappedValue }

    public var body: some View {
        let _ = viewModel.revision
#if DEBUG
        let _ = Self._logChanges()
#endif
        return VStack(alignment: .leading, spacing: stackRowSpacing) {
            HStack {
                IconComponentView(
                    viewModel: viewModel,
                    labelIcon: _xLabelIcon,
                    labelText: _xLabelText,
                    isTrackingInput: $isTrackingXComponentInput
                )

                if layoutOptions.showControls {
                    FloatSliderComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $xFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.labelText,
                        isTrackingInput: $isTrackingXComponentInput
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
                        case .native, .linkedDecimal:
                            DecimalTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $xFloatProxy,
                                range: self.range,
                                precision: precision,
                                labelText: self.labelText,
                                isTrackingInput: $isTrackingXComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == pointModelSetting?.action.xSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = pointModelSetting?.action.xSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitXFloatProxy()
                            }

                        case .linkedPercent:
                            PercentTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $xFloatProxy,
                                range: self.range,
                                precision: self.precision,
                                labelText: self.labelText,
                                isTrackingInput: $isTrackingXComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == pointModelSetting?.action.xSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = pointModelSetting?.action.xSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitXFloatProxy()
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
                                isPopupOpen: $isXPopupOpen
                            )
                            .popover(
                                isPresented: $isXPopupOpen,
                                attachmentAnchor: .rect(.bounds),
                                arrowEdge: .bottom
                            ) {
                                PopoverFloatSliderComponentView(
                                    viewModel: viewModel,
                                    floatProxy: $xFloatProxy,
                                    range: self.range, step: self.step,
                                    labelText: self.labelText,
                                    isTrackingInput: $isTrackingXComponentInput
                                )
                            }
    #endif
    #if os(iOS)
                            PopoverButtonView(
                                layoutOptions: self.layoutOptions,
                                colorScheme: self.colorScheme,
                                labelText: self.labelText,
                                isPopupOpen: $isXPopupOpen
                            ) { anchorView in
                                PopoverPresenter.shared.present(
                                    from: anchorView,
                                    content: PopoverFloatSliderComponentView(
                                        viewModel: viewModel,
                                        floatProxy: $xFloatProxy,
                                        range: self.range,
                                        step: self.step,
                                        labelText: self.labelText,
                                        isTrackingInput: $isTrackingXComponentInput
                                    ),
                                    localization: self.localization,
                                    contentSize: self.layoutOptions.popupSliderContentSize
                                ) {
                                    isXPopupOpen = false
                                }
                            }
    #endif
                        }
                    } // HStack
                }

                if layoutOptions.showSteppers {
                    FloatStepperComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $xFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.xLabelText,
                        isTrackingInput: $isTrackingXComponentInput
                    ) {
                        self.commitXFloatProxy()
                    }
                }
            } // HStack
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: sizeSliderTrailingMargin))

            HStack {
                IconComponentView(
                    viewModel: viewModel,
                    labelIcon: _yLabelIcon,
                    labelText: _yLabelText,
                    isTrackingInput: $isTrackingYComponentInput
                )

                if layoutOptions.showControls {
                    FloatSliderComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $yFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.yLabelText,
                        isTrackingInput: $isTrackingYComponentInput
                    )
                }
                else if layoutOptions.showLabelText {
                    RenamableLabelTextComponentView(
                        viewModel: viewModel,
                        isTrackingInput: $isTrackingInput,
                        labelText: yLabelText,
                        verticalAlignment: .center
                    )
                }

                if layoutOptions.showTextFields {
                    HStack {
                        switch self.specialPresentation {
                        case .native, .linkedDecimal:
                            DecimalTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $yFloatProxy,
                                range: self.range,
                                precision: precision,
                                labelText: self.yLabelText,
                                isTrackingInput: $isTrackingYComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == pointModelSetting?.action.ySettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = pointModelSetting?.action.ySettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitYFloatProxy()
                            }

                        case .linkedPercent:
                            PercentTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $yFloatProxy,
                                range: self.range,
                                precision: self.precision,
                                labelText: self.yLabelText,
                                isTrackingInput: $isTrackingYComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == pointModelSetting?.action.ySettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = pointModelSetting?.action.ySettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitYFloatProxy()
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
                                isPopupOpen: $isYPopupOpen
                            )
                            .popover(
                                isPresented: $isYPopupOpen,
                                attachmentAnchor: .rect(.bounds),
                                arrowEdge: .bottom
                            ) {
                                PopoverFloatSliderComponentView(
                                    viewModel: viewModel,
                                    floatProxy: $yFloatProxy,
                                    range: self.range, step: self.step,
                                    labelText: self.yLabelText,
                                    isTrackingInput: $isTrackingYComponentInput
                                )
                            }
    #endif
    #if os(iOS)
                            PopoverButtonView(
                                layoutOptions: self.layoutOptions,
                                colorScheme: self.colorScheme,
                                labelText: self.yLabelText,
                                isPopupOpen: $isYPopupOpen
                            ) { anchorView in
                                PopoverPresenter.shared.present(
                                    from: anchorView,
                                    content: PopoverFloatSliderComponentView(
                                        viewModel: viewModel,
                                        floatProxy: $yFloatProxy,
                                        range: self.range,
                                        step: self.step,
                                        labelText: self.yLabelText,
                                        isTrackingInput: $isTrackingYComponentInput
                                    ),
                                    localization: self.localization,
                                    contentSize: self.layoutOptions.popupSliderContentSize
                                ) {
                                    isYPopupOpen = false
                                }
                            }
    #endif
                        }
                    } // HStack
                }

                if layoutOptions.showSteppers {
                    FloatStepperComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $yFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.yLabelText,
                        isTrackingInput: $isTrackingYComponentInput
                    ) {
                        self.commitYFloatProxy()
                    }
                }
            } // HStack
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: sizeSliderTrailingMargin))
        } // VStack
        .padding([.horizontal])
        .onAppear() {
            self.onAppear()
        }
        .onChange(of: isTrackingXComponentInput) {
            self.isTrackingInput = isTrackingXComponentInput
            if !isTrackingXComponentInput {
                self.commitXFloatProxy()
            }
        }
        .onChange(of: isTrackingYComponentInput) {
            self.isTrackingInput = isTrackingYComponentInput
            if !isTrackingYComponentInput {
                self.commitYFloatProxy()
            }
        }
        .onSubmit {
            onSubmitX()
        }
        .onChange(of: viewModel.revision) { _, _ in
            self.onChangeOfRevision()
        }
        .onChange(of: xFloatProxy) {
            self.onChangeOfXFloatProxy()
        }
        .onChange(of: yFloatProxy) {
            self.onChangeOfYFloatProxy()
        }
    }

    func onAppear() {
        if let value = xCommitted {
            xFloatProxy = Value(NDFloat(value).rounded(self.precision))
        }
        if let value = yCommitted {
            yFloatProxy = Value(NDFloat(value).rounded(self.precision))
        }
    }

    func onChangeOfRevision() {
        if !isTrackingInput {
            if let v = self.xCommitted {
                let rounded = Value(NDFloat(v).rounded(precision))
                if rounded != xFloatProxy {
                    xFloatProxy = rounded
                }
            }
            if let v = self.yCommitted {
                let rounded = Value(NDFloat(v).rounded(precision))
                if rounded != yFloatProxy {
                    yFloatProxy = rounded
                }
            }
        }
    }

    func onChangeOfXFloatProxy() {
        if isTrackingInput || isTrackingXComponentInput {
            let ndXValue = NDFloat(xFloatProxy)
            var newXValue = Value(ndXValue.rounded(self.precision))
            newXValue = newXValue.clamped(to: self.range)
            if newXValue != self.xTracking {
                self.xModelSetting?.trackingValue.wrappedValue = newXValue
            }
        }
    }

    func onChangeOfYFloatProxy() {
        if isTrackingInput || isTrackingYComponentInput {
            let ndYValue = NDFloat(yFloatProxy)
            var newYValue = Value(ndYValue.rounded(self.precision))
            newYValue = newYValue.clamped(to: self.range)
            if newYValue != self.yTracking {
                self.yModelSetting?.trackingValue.wrappedValue = newYValue
            }
        }
    }

    func commitXFloatProxy() {
        let ndXValue = NDFloat($xFloatProxy.wrappedValue)
        var newXValue = Value(ndXValue.rounded(self.precision))
        newXValue = newXValue.clamped(to: self.range)
        if newXValue != self.xCommitted {
            self.xModelSetting?.committedValue.wrappedValue = newXValue
        }
    }

    func commitYFloatProxy() {
        let ndYValue = NDFloat($yFloatProxy.wrappedValue)
        var newYValue = Value(ndYValue.rounded(self.precision))
        newYValue = newYValue.clamped(to: self.range)
        if newYValue != self.yCommitted {
            self.yModelSetting?.committedValue.wrappedValue = newYValue
        }
    }

    func onSubmitX() {
#if os(macOS)
        // https://developer.apple.com/forums/thread/678388
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
#endif
        self.commitXFloatProxy()
    }

    func onSubmitY() {
#if os(macOS)
        // https://developer.apple.com/forums/thread/678388
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
#endif
        self.commitYFloatProxy()
    }

    var precision: RoundingPrecision {
        self.pointModelSetting?.action.precision ?? .hundredths
    }

    var range: ClosedRange<Value> {
        self.pointModelSetting?.action.range ?? 0.0...100.0
    }

    var step: Value.Stride {
        self.pointModelSetting?.action.step ?? 1.0
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.67 : 0.2
    }

    // Computed in case we want to make precision variable later on.
    private var textFieldWidth: NDFloat {
        65
    }
}
