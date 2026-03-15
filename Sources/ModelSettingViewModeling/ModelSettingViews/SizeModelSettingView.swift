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
import LoggerCategories
import OSLog
#if os(iOS)
import UIKit
#endif

public struct SizeModelSettingView<
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
         self.sizeModelSetting
    }

    private var sizeModelSetting: SizeViewModelSetting<Value>? {
        if Value.self == NDFloat.self {
            guard case .ndSize(let ndSizeSetting) = self.modelSettingType else { return nil }

            return ndSizeSetting as? SizeViewModelSetting<Value>
        }
        else if Value.self == CGFloat.self {
            guard case .cgSize(let cgSizeSetting) = self.modelSettingType else { return nil }

            return cgSizeSetting as? SizeViewModelSetting<Value>
        }
        else {
            return nil
        }
    }

    private var widthModelSetting: FloatViewModelSetting<Value>? {
        sizeModelSetting?.widthSetting
    }

    private var heightModelSetting: FloatViewModelSetting<Value>? {
        sizeModelSetting?.heightSetting
    }

    private var maintainSizeRatioSetting: BoolViewModelSetting? {
        sizeModelSetting?.maintainSizeRatioSetting
    }

    private var sizeRatioSetting: FloatViewModelSetting<Value>? {
        sizeModelSetting?.sizeRatioSetting
    }

    /// - Returns: The label icon to show for the width in this view.
    var widthLabelIcon: IconName {
        (viewStyle?.labelIcon) ?? .system(name: "suit.diamond.fill")
    }

    /// - Returns: A binding to the label icon to show for the width in this view.
    var _widthLabelIcon: Binding<IconName?> {
        Binding(
            get: {
                viewStyle?.labelIcon
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    /// - Returns: The label icon to show for the height in this view.
    var heightLabelIcon: IconName {
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

    /// - Returns: A binding to the label icon to show for the height in this view.
    var _heightLabelIcon: Binding<IconName?> {
        Binding(
            get: {
                self.heightLabelIcon
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    var maintainSizeRatioLabelIcon: IconName {
        var iconName: IconName? = nil
        switch self.specialPresentation {
        case .linkedDecimal(_, _, let maintainRatioToggleLabelIcon, _):
            iconName = maintainRatioToggleLabelIcon

        case .linkedPercent(_, _, let maintainRatioToggleLabelIcon, _):
            iconName = maintainRatioToggleLabelIcon

        default:
            break
        }
        return iconName ?? .system(name: "suit.diamond.fill")
    }

    /// - Returns: The label text to show for the height in this view.
    var heightLabelText: LocalizationKey {
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

    /// - Returns: A binding to the label text to show for the height in this view.
    var _heightLabelText: Binding<LocalizationKey?> {
        Binding(
            get: {
                self.heightLabelText
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    var maintainSizeRatioLabelText: LocalizationKey {
        var toggleText: LocalizationKey? = nil
        switch self.specialPresentation {
        case .linkedDecimal(_, _, _, let maintainRatioToggleLabelText):
            toggleText = maintainRatioToggleLabelText

        case .linkedPercent(_, _, _, let maintainRatioToggleLabelText):
            toggleText = maintainRatioToggleLabelText

        default:
            break
        }
        return toggleText ?? .missing
    }

    /// - Returns: A binding to the label text to show for the height in this view.
    var _maintainSizeRatioLabelText: Binding<LocalizationKey?> {
        Binding(
            get: {
                self.maintainSizeRatioLabelText
            },
            set: { newValue in
                // Read-only
            }
        )
    }

    @Binding public var isTrackingInput: Bool
    @Binding public var focusedID: ModelSetting.ID?

    @State private var isTrackingWidthComponentInput: Bool = false
    @State private var isTrackingHeightComponentInput: Bool = false
    @State private var isTrackingMaintainSizeRatioComponentInput: Bool = false

    @State private var widthFloatProxy: Value = 0.0
    @State private var heightFloatProxy: Value = 0.0
    @State private var maintainBoolProxy: Bool = false

    @State private var isWidthPopupOpen = false
    @State private var isHeightPopupOpen = false

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

    var widthCommitted: Value? { widthModelSetting?.committedValue.wrappedValue }
    var widthTracking: Value?  { widthModelSetting?.trackingValue.wrappedValue }

    var heightCommitted: Value? { heightModelSetting?.committedValue.wrappedValue }
    var heightTracking: Value?  { heightModelSetting?.trackingValue.wrappedValue }

    var maintainSizeRatioCommitted: Bool? {
        self.maintainSizeRatioSetting?.committedValue.wrappedValue
    }

    var sizeRatioCommitted: Value? {
        self.sizeRatioSetting?.committedValue.wrappedValue
    }

    public var body: some View {
        let _ = viewModel.revision
#if DEBUG
        let _ = Self._logChanges()
#endif
        return VStack(alignment: .leading, spacing: stackRowSpacing) {
            HStack {
                IconComponentView(
                    viewModel: viewModel,
                    labelIcon: self._labelIcon,
                    labelText: self._labelText,
                    isTrackingInput: $isTrackingWidthComponentInput
                )

                if layoutOptions.showControls {
                    FloatSliderComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $widthFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.labelText,
                        isTrackingInput: $isTrackingWidthComponentInput
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
                                floatProxy: $widthFloatProxy,
                                range: self.range,
                                precision: precision,
                                labelText: self.labelText,
                                isTrackingInput: $isTrackingWidthComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == sizeModelSetting?.action.widthSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = sizeModelSetting?.action.widthSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitWidthFloatProxy()
                            }

                        case .linkedPercent:
                            PercentTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $widthFloatProxy,
                                range: self.range,
                                precision: self.precision,
                                labelText: self.labelText,
                                isTrackingInput: $isTrackingWidthComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == sizeModelSetting?.action.widthSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = sizeModelSetting?.action.widthSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitWidthFloatProxy()
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
                                isPopupOpen: $isWidthPopupOpen
                            )
                            .popover(
                                isPresented: $isWidthPopupOpen,
                                attachmentAnchor: .rect(.bounds),
                                arrowEdge: .bottom
                            ) {
                                PopoverFloatSliderComponentView(
                                    viewModel: viewModel,
                                    floatProxy: $widthFloatProxy,
                                    range: self.range, step: self.step,
                                    labelText: self.labelText,
                                    isTrackingInput: $isTrackingWidthComponentInput
                                )
                            }
    #endif
    #if os(iOS)
                            PopoverButtonView(
                                layoutOptions: self.layoutOptions,
                                colorScheme: self.colorScheme,
                                labelText: self.labelText,
                                isPopupOpen: $isWidthPopupOpen
                            ) { anchorView in
                                PopoverPresenter.shared.present(
                                    from: anchorView,
                                    content: PopoverFloatSliderComponentView(
                                        viewModel: viewModel,
                                        floatProxy: $widthFloatProxy,
                                        range: self.range,
                                        step: self.step,
                                        labelText: self.labelText,
                                        isTrackingInput: $isTrackingWidthComponentInput
                                    ),
                                    localization: self.localization,
                                    contentSize: self.layoutOptions.popupSliderContentSize
                                ) {
                                    isWidthPopupOpen = false
                                }
                            }
    #endif
                        }
                    } // HStack
                }
                
                if layoutOptions.showSteppers {
                    FloatStepperComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $widthFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.labelText,
                        isTrackingInput: $isTrackingWidthComponentInput
                    ) {
                        self.commitWidthFloatProxy()
                    }
                }
            } // HStack
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: sizeSliderTrailingMargin))

            HStack {
                Spacer()
                IconButtonToggleComponentView(
                    viewModel: viewModel,
                    isOn: $maintainBoolProxy,
                    iconName: self.maintainSizeRatioLabelIcon,
                    labelText: self._maintainSizeRatioLabelText,
                    isTrackingInput: $isTrackingMaintainSizeRatioComponentInput
                )
                .padding(toggleEdgeInsets)
            }

            HStack {
                IconComponentView(
                    viewModel: viewModel,
                    labelIcon: _heightLabelIcon,
                    labelText: _heightLabelText,
                    isTrackingInput: $isTrackingHeightComponentInput
                )

                if layoutOptions.showControls {
                    FloatSliderComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $heightFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.heightLabelText,
                        isTrackingInput: $isTrackingHeightComponentInput
                    )
                }
                else if layoutOptions.showLabelText {
                    RenamableLabelTextComponentView(
                        viewModel: viewModel,
                        isTrackingInput: $isTrackingInput,
                        labelText: heightLabelText,
                        verticalAlignment: .center
                    )
                }

                if layoutOptions.showTextFields {
                    HStack {
                        switch self.specialPresentation {
                        case .native, .linkedDecimal:
                            DecimalTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $heightFloatProxy,
                                range: self.range,
                                precision: precision,
                                labelText: self.heightLabelText,
                                isTrackingInput: $isTrackingHeightComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == sizeModelSetting?.action.heightSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = sizeModelSetting?.action.heightSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitHeightFloatProxy()
                            }

                        case .linkedPercent:
                            PercentTextFieldComponentView<Value, ViewModel>(
                                viewModel: viewModel,
                                floatProxy: $heightFloatProxy,
                                range: self.range,
                                precision: self.precision,
                                labelText: self.heightLabelText,
                                isTrackingInput: $isTrackingHeightComponentInput,
                                isFocused: Binding(
                                    get: { focusedID == sizeModelSetting?.action.heightSettingID },
                                    set: {
                                        $0 ?
                                        (focusedID = sizeModelSetting?.action.heightSettingID) :
                                        (focusedID = nil)
                                    }
                                )
                            ) {
                                self.commitHeightFloatProxy()
                            }

                        default:
                            Text("Unsupported")
                        }

                        if layoutOptions.controlOptions == .showTextFieldWithPopupControl {
    #if os(macOS)
                            PopoverButtonView(
                                layoutOptions: self.layoutOptions,
                                colorScheme: self.colorScheme,
                                labelText: self.heightLabelText,
                                isPopupOpen: $isHeightPopupOpen
                            )
                            .popover(
                                isPresented: $isHeightPopupOpen,
                                attachmentAnchor: .rect(.bounds),
                                arrowEdge: .bottom
                            ) {
                                PopoverFloatSliderComponentView(
                                    viewModel: viewModel,
                                    floatProxy: $heightFloatProxy,
                                    range: self.range, step: self.step,
                                    labelText: self.heightLabelText,
                                    isTrackingInput: $isTrackingHeightComponentInput
                                )
                            }
    #endif
    #if os(iOS)
                            PopoverButtonView(
                                layoutOptions: self.layoutOptions,
                                colorScheme: self.colorScheme,
                                labelText: self.heightLabelText,
                                isPopupOpen: $isHeightPopupOpen
                            ) { anchorView in
                                PopoverPresenter.shared.present(
                                    from: anchorView,
                                    content: PopoverFloatSliderComponentView(
                                        viewModel: viewModel,
                                        floatProxy: $heightFloatProxy,
                                        range: self.range,
                                        step: self.step,
                                        labelText: self.heightLabelText,
                                        isTrackingInput: $isTrackingHeightComponentInput
                                    ),
                                    localization: self.localization,
                                    contentSize: self.layoutOptions.popupSliderContentSize
                                ) {
                                    isHeightPopupOpen = false
                                }
                            }
    #endif
                        }
                    } // HStack
                }

                if layoutOptions.showSteppers {
                    FloatStepperComponentView<Value, ViewModel>(
                        viewModel: viewModel,
                        floatProxy: $heightFloatProxy,
                        range: range,
                        step: step,
                        labelText: self.heightLabelText,
                        isTrackingInput: $isTrackingHeightComponentInput
                    ) {
                        self.commitHeightFloatProxy()
                    }
                }
            } // HStack
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: sizeSliderTrailingMargin))
        } // VStack
        .padding([.horizontal])
        .onAppear() {
            self.onAppear()
        }
        .onChange(of: isTrackingWidthComponentInput) {
            self.isTrackingInput = isTrackingWidthComponentInput
            if !isTrackingWidthComponentInput {
                self.commitWidthFloatProxy()
            }
        }
        .onChange(of: isTrackingHeightComponentInput) {
            self.isTrackingInput = isTrackingHeightComponentInput
            if !isTrackingHeightComponentInput {
                self.commitHeightFloatProxy()
            }
        }
        .onSubmit {
            onSubmitWidth()
        }
        .onChange(of: viewModel.revision) { _, _ in
            self.onChangeOfRevision()
        }
        .onChange(of: widthFloatProxy) {
            self.onChangeOfWidthFloatProxy()
        }
        .onChange(of: heightFloatProxy) {
            self.onChangeOfHeightFloatProxy()
        }
        .onChange(of: maintainBoolProxy) {
            self.onChangeOfMaintainBoolProxy()
        }
    }

    func onAppear() {
        if let value = widthCommitted {
            widthFloatProxy = Value(NDFloat(value).rounded(self.precision))
        }
        if let value = heightCommitted {
            heightFloatProxy = Value(NDFloat(value).rounded(self.precision))
        }
        if let booleanCommit = self.maintainSizeRatioCommitted {
            self.maintainBoolProxy = booleanCommit
        }
    }

    func onChangeOfRevision() {
        if !isTrackingInput {
            if let v = self.widthCommitted {
                let rounded = Value(NDFloat(v).rounded(precision))
                if rounded != widthFloatProxy {
                    widthFloatProxy = rounded
                }
            }
            if let v = self.heightCommitted {
                let rounded = Value(NDFloat(v).rounded(precision))
                if rounded != heightFloatProxy {
                    heightFloatProxy = rounded
                }
            }
            if let booleanCommit = self.maintainSizeRatioCommitted,
               booleanCommit != self.maintainBoolProxy {
                self.maintainBoolProxy = booleanCommit
            }
        }
    }

    func onChangeOfWidthFloatProxy() {
        if isTrackingInput || isTrackingWidthComponentInput {
            let ndWidthValue = NDFloat(widthFloatProxy)
            var newWidthValue = Value(ndWidthValue.rounded(self.precision))
            newWidthValue = newWidthValue.clamped(to: self.range)
            if newWidthValue != self.widthTracking {
                self.widthModelSetting?.trackingValue.wrappedValue = newWidthValue

                if let maintainSizeRatio = self.maintainSizeRatioCommitted,
                   maintainSizeRatio,
                    let sizeRatio = self.sizeRatioCommitted,
                   sizeRatio != 0.0 {
                    heightFloatProxy = newWidthValue / sizeRatio
                }
            }
        }
    }

    func onChangeOfHeightFloatProxy() {
        if isTrackingInput || isTrackingHeightComponentInput {
            let ndHeightValue = NDFloat(heightFloatProxy)
            var newHeightValue = Value(ndHeightValue.rounded(self.precision))
            newHeightValue = newHeightValue.clamped(to: self.range)
            if newHeightValue != self.heightTracking {
                self.heightModelSetting?.trackingValue.wrappedValue = newHeightValue

                if let sizeRatio = self.sizeRatioCommitted,
                   let maintainSizeRatio = self.maintainSizeRatioCommitted,
                   maintainSizeRatio {
                    widthFloatProxy = newHeightValue * sizeRatio
                }
            }
        }
    }

    func onChangeOfMaintainBoolProxy() {
        if let maintainSizeRatio = self.maintainSizeRatioCommitted {
            if maintainSizeRatio != self.maintainBoolProxy {
                // Group the maintain bool and size float changes into one undoable action.
                self.viewModel.containerCollection.startUndoGroup()
                self.sizeModelSetting?.maintainSizeRatioSetting.committedValue.wrappedValue =
                    self.maintainBoolProxy
                if self.maintainBoolProxy {
                    let ndNewRatio = NDFloat(widthFloatProxy / heightFloatProxy)
                    let newRatio = Value(ndNewRatio.rounded(self.precision))
                    Logger.info("Setting sizeRatio: \(newRatio)", LogCategory.general)
                    self.sizeModelSetting?.sizeRatioSetting.committedValue.wrappedValue =
                        newRatio
                }
                self.viewModel.containerCollection.endUndoGroup()
            }
        }
    }

    func commitWidthFloatProxy() {
        let ndWidthValue = NDFloat($widthFloatProxy.wrappedValue)
        var newWidthValue = Value(ndWidthValue.rounded(self.precision))
        newWidthValue = newWidthValue.clamped(to: self.range)
        if newWidthValue != self.widthCommitted {
            // Group the width and potential height changes into one undoable action.
            self.viewModel.containerCollection.startUndoGroup()
            self.widthModelSetting?.committedValue.wrappedValue = newWidthValue
            if let maintainSizeRatio = self.maintainSizeRatioCommitted,
               maintainSizeRatio,
               let sizeRatio = sizeRatioCommitted,
               sizeRatio != 0.0 {
                let newHeight = newWidthValue / sizeRatio
                self.heightModelSetting?.committedValue.wrappedValue = newHeight
            }
            self.viewModel.containerCollection.endUndoGroup()
        }
    }

    func commitHeightFloatProxy() {
        let ndHeightValue = NDFloat($heightFloatProxy.wrappedValue)
        var newHeightValue = Value(ndHeightValue.rounded(self.precision))
        newHeightValue = newHeightValue.clamped(to: self.range)
        if newHeightValue != self.heightCommitted {
            // Group the height and width changes into one undoable action.
            self.viewModel.containerCollection.startUndoGroup()
            self.heightModelSetting?.committedValue.wrappedValue = newHeightValue
            if let maintainSizeRatio = self.maintainSizeRatioCommitted,
               maintainSizeRatio,
               let sizeRatio = self.sizeRatioCommitted {
                let newWidth = newHeightValue * sizeRatio
                self.widthModelSetting?.committedValue.wrappedValue = newWidth
            }
            self.viewModel.containerCollection.endUndoGroup()
        }
    }

    func onSubmitWidth() {
#if os(macOS)
        // https://developer.apple.com/forums/thread/678388
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
#endif
        self.commitWidthFloatProxy()
    }

    func onSubmitHeight() {
#if os(macOS)
        // https://developer.apple.com/forums/thread/678388
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
#endif
        self.commitHeightFloatProxy()
    }

    var precision: RoundingPrecision {
        self.sizeModelSetting?.action.precision ?? .hundredths
    }

    var range: ClosedRange<Value> {
        self.sizeModelSetting?.action.range ?? 0.0...100.0
    }

    var step: Value.Stride {
        self.sizeModelSetting?.action.step ?? 1.0
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.67 : 0.2
    }

    // Computed in case we want to make precision variable later on.
    private var textFieldWidth: NDFloat {
        65
    }
}
