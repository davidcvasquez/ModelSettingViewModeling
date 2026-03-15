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
import CompactUUID
import LocalizableStringBundle

public struct AngleModelSettingView<
    MoA: AnyAngle,
    ViewModel: ModelSettingViewModel
>: ModelSettingView
    where MoA: Strideable & Comparable & Codable & Sendable,
          MoA.Stride: Codable & Sendable
{
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization
    @Environment(\.colorScheme) var colorScheme

    @FocusState private var focused: Bool

    public let id: ModelSettingView.ID

    public let viewModel: ViewModel

    public var viewModelSetting: (any ViewModelSetting)? {
        self.angleModelSetting
    }

    private var angleModelSetting: AngleViewModelSetting<MoA>? {
        if case .angle(let angleSetting) = self.modelSettingType {
            return angleSetting as? AngleViewModelSetting<MoA>
        }
        else if case .ndAngle(let ndAngleSetting) = self.modelSettingType {
            return ndAngleSetting as? AngleViewModelSetting<MoA>
        }
        else {
            return nil
        }
    }

    @Binding public var isTrackingInput: Bool
    @Binding public var isFocused: Bool

    @State private var isTrackingComponentInput: Bool = false
    @State private var isPopupOpen = false

    @Namespace private var mainNameSpace

    @State private var angleProxy: MoA = MoA()

    @State private var draftAngleProxy: Measurement<UnitAngle> =
        Measurement(value: 0.0, unit: UnitAngle.degrees)

    @State private var draft: String = ""

    public var body: some View {
        let _ = viewModel.revision

        var committed: MoA? { angleModelSetting?.committedValue.wrappedValue }
        var tracking: MoA?  { angleModelSetting?.trackingValue.wrappedValue }

        HStack {
            IconComponentView(
                viewModel: viewModel,
                labelIcon: self._labelIcon,
                labelText: self._labelText,
                isTrackingInput: $isTrackingInput)

            if layoutOptions.showControls {
                Spacer()
                AngleComponentView(
                    viewModel: viewModel,
                    labelText: self.labelText,
                    value: $angleProxy,
                    in: self.range,
                    isTrackingInput: $isTrackingComponentInput
                )
                .help(self.labelText)
                Spacer()
            }
            else if layoutOptions.showLabelText {
                Spacer()
                RenamableLabelTextComponentView(
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    labelText: labelText,
                    verticalAlignment: .center
                )
                Spacer()
            }

            if layoutOptions.showTextFields {
                HStack {
                    textFieldView

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
                            AngleComponentView(
                                viewModel: viewModel,
                                isPopover: true,
                                labelText: self.labelText,
                                value: $angleProxy,
                                in: self.range,
                                isTrackingInput: $isTrackingComponentInput)
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
                                content: AngleComponentView(
                                    viewModel: viewModel,
                                    isPopover: true,
                                    labelText: self.labelText,
                                    value: $angleProxy,
                                    in: self.range,
                                    isTrackingInput: $isTrackingComponentInput),
                                localization: self.localization,
                                contentSize: self.layoutOptions.popupDialContentSize,
                                isDial: true
                            ) {
                                isPopupOpen = false
                            }
                        }
#endif
                    }
                } // HStack
            }

            if layoutOptions.showSteppers {
                stepperView
            }
        } // HStack
        .padding([.horizontal])
        .onAppear {
            if let committedAngle = self.angleModelSetting?.committedValue.wrappedValue {
                self.angleProxy = committedAngle
            }
        }
        .onChange(of: angleProxy) {
            if isTrackingInput || isTrackingComponentInput {
                self.angleModelSetting?.trackingValue.wrappedValue = $angleProxy.wrappedValue
            }
        }
        .onChange(of: isTrackingComponentInput) {
            self.isTrackingInput = isTrackingComponentInput
            if !isTrackingComponentInput {
                if $angleProxy.wrappedValue != self.angleModelSetting?.committedValue.wrappedValue {
                    self.angleModelSetting?.committedValue.wrappedValue = $angleProxy.wrappedValue
                }
            }
        }
        .onChange(of: angleModelSetting?.committedValue.wrappedValue) {
            (_, newValue: MoA?) in

            if let newValue, newValue.degrees != MoA.Scalar(self.draftAngleProxy.converted(to: .degrees).value) {
                self.draftAngleProxy = Measurement(
                    value: Double(newValue.degrees), unit: UnitAngle.degrees)
            }
        }
        .onChange(of: angleModelSetting?.trackingValue.wrappedValue) {
            (_, newValue: MoA?) in

            if let newValue, newValue.degrees != MoA.Scalar(self.draftAngleProxy.converted(to: .degrees).value) {
                self.draftAngleProxy = Measurement(
                    value: Double(newValue.degrees), unit: UnitAngle.degrees)
            }
        }
        .onChange(of: viewModel.revision) { _, _ in
            Swift.print(".onChange(of: viewModel.editTick)", [
                "committed": "\(String(describing: committed))",
                "isTrackingInput": "\(isTrackingInput)"
                ])

            if !isTrackingInput, let v = self.angleModelSetting?.committedValue.wrappedValue {
                let rounded = MoA.Scalar(NDFloat(v.degrees).rounded(precision))
                if rounded != self.angleProxy.degrees {
                    self.angleProxy = MoA(degrees: rounded)
                }
            }
        }
    }

    var captionOpacity: NDFloat {
        self.isEnabled ? 0.75 : 0.33
    }

    // Returns our custom style specifically for 'Value'
    private var degreeFormat: DegreeMeasurementFormatStyle {
        DegreeMeasurementFormatStyle(precision: 1)
    }

    @ViewBuilder
    private var textField: some View {
        TextField("", value: $draftAngleProxy, format: degreeFormat)
    }

    private var textFieldView: some View {
        Group {
            textField
                .focused($focused)
                .help(self.labelText)
#if os(iOS)
                .keyboardType(.decimalPad)
#endif
#if os(macOS)
                .prefersDefaultFocus(false, in: mainNameSpace)
#endif
                .submitLabel(.done)                // iOS: “Done” where available

                .onChange(of: draftAngleProxy) {
                    let newValue = MoA(degrees: MoA.Scalar(self.draftAngleProxy.converted(
                        to: .degrees).value))
                    if newValue != self.angleProxy {
                        self.angleProxy = newValue
                    }
                }

                .onSubmit {
#if os(macOS)
                    // https://developer.apple.com/forums/thread/678388
                    DispatchQueue.main.async {
                        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
                    }
#endif
                    self.angleModelSetting?.committedValue.wrappedValue = self.angleProxy
                    self.isTrackingInput = false
                }
#if os(iOS)
                .onAppear {
                    self.focused = self.isFocused
                }
                .onChange(of: isFocused) { _, nowFocused in
                    if !nowFocused {
                        self.commitDraft()
                        self.focused = false
                    }
                }
#endif
                .onChange(of: focused) { _, nowFocused in
                    if !nowFocused {
                        commitDraft()
                    }
#if os(iOS)
                    if self.isFocused != nowFocused {
                        self.isFocused = nowFocused
                    }
#endif
                }
                .onChange(of: angleProxy) { _, newValue in
                    if !focused {
                        draftAngleProxy = Measurement(value: Double(newValue.degrees), unit: .degrees)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: -4))
                .frame(
                    width: 65
                )
        }
        .opacity(isEnabled ? 1.0 : 0.25)
    }

    private func commitDraft() {
        let degrees = draftAngleProxy.converted(to: .degrees).value
        self.angleModelSetting?.committedValue.wrappedValue = MoA(degrees: MoA.Scalar(degrees))
    }

    private var stepperView: some View {
        Group {
            Stepper(" ", value: $angleProxy, in: self.range, step: self.step) { editing in
                self.isTrackingInput = editing
                if !editing {
                    self.angleModelSetting?.committedValue.wrappedValue = $angleProxy.wrappedValue
                }
            }
            .opacity(isEnabled ? 1.0 : 0.25)
            .help(self.labelText)
            .controlSize(layoutOptions.stepperOptions == .largeStepper ? .extraLarge : .regular)
            .padding(EdgeInsets(top: 0, leading: -4, bottom: 0, trailing: 8))
            .fixedSize(horizontal: true, vertical: true)
        }
    }

    private var precision: RoundingPrecision {
        self.angleModelSetting?.action.precision ?? .hundredths
    }

    private var range: ClosedRange<MoA> {
        self.angleModelSetting?.action.range ?? MoA()...MoA(degrees: 360.0)
    }

    private var step: MoA.Stride {
        self.angleModelSetting?.action.step ?? MoA.Stride(exactly: 0)!
    }

    private let didUndoObserver = NotificationCenter.default.publisher(
        for: .NSUndoManagerDidUndoChange)
    private let didRedoObserver = NotificationCenter.default.publisher(
        for: .NSUndoManagerDidRedoChange)
}

public struct DegreeMeasurementFormatStyle: ParseableFormatStyle {
    public typealias FormatInput = Measurement<UnitAngle>
    public typealias FormatOutput = String

    public var parseStrategy: DegreeMeasurementParseStrategy = .init()
    private let precision: Int

    public init(precision: Int) {
        self.precision = precision
    }

    public func format(_ value: Measurement<UnitAngle>) -> String {
        let degrees = value.converted(to: .degrees).value
        let formatted = String(format: "%.*f", precision, degrees)
            .replacingOccurrences(of: #"(\.\d*?)0+$"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"\.$"#, with: "", options: .regularExpression)
        return formatted + "°"
    }
}

public struct DegreeMeasurementParseStrategy: ParseStrategy {
    public typealias Input = String
    public typealias Output = Measurement<UnitAngle>

    public init() {}

    public func parse(_ value: String) throws -> Measurement<UnitAngle> {
        let cleaned = value.replacingOccurrences(of: "°", with: "").trimmingCharacters(in: .whitespaces)
        guard let doubleValue = Double(cleaned) else {
            throw CocoaError(.formatting)
        }
        return Measurement(value: doubleValue, unit: .degrees)
    }
}
