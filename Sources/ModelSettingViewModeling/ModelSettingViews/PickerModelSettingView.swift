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
import OSLog
import LoggerCategories

public struct IconAndName: Equatable, Codable {
    let icon: IconName
    let key: LocalizationKey
}

public struct PickerModelSettingView<ViewModel: ModelSettingViewModel>: ModelSettingView {
    @Environment(\.isEnabled) private var isEnabled

    public let id: DocumentSetting.ID

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

    private var caseNames: [IconAndName] {
        switch self.specialPresentation {
        case .iconPicker(let caseNames):
            return caseNames

        case .integer:
            return []

        case .none:
            return []

        default:
            return []
        }
    }

    private var baseOffset: Int {
        if let range = intModelSetting?.action.range {
            return range.lowerBound
        }
        else {
            return 0
        }
    }

    var pickerImageOpacity: NDFloat {
        0.80
    }

    @State private var pickerValue: Int = 0

    public var body: some View {
        Picker(selection: $pickerValue, label: Text(labelText)) {
            ForEach(0 ..< self.caseNames.count, id: \.self) {
                switch self.caseNames[$0].icon {
                case .system(let name):
                    Image(systemName: name)
                        .renderingMode(.template)
                        .opacity(pickerImageOpacity)
                        .tag($0 + baseOffset)
                        .help(self.caseNames[$0].key)

                case .local(let name):
                    Image(name)
                        .renderingMode(.template)
                        .opacity(pickerImageOpacity)
                        .tag($0 + baseOffset)
                        .help(self.caseNames[$0].key)
                }
            }
        }
        .task {
            if let value = intModelSetting?.committedValue.wrappedValue {
                self.pickerValue = value
            }
        }
        .onChange(of: $pickerValue.wrappedValue) {
            Logger.info("pickerValue: \($pickerValue.wrappedValue)", LogCategory.general)

            intModelSetting?.committedValue.wrappedValue = $pickerValue.wrappedValue
        }
        .onChange(of: intModelSetting?.committedValue.wrappedValue) {

            if let value = intModelSetting?.committedValue.wrappedValue,
               value != $pickerValue.wrappedValue {
                Logger.info("commit: \(value)", LogCategory.general)
                $pickerValue.wrappedValue = value
            }
        }
        .pickerStyle(.segmented)
        .controlSize(.extraLarge)
        .fixedSize()
        .opacity(self.isEnabled ? 1.0 : 0.2)
    }
}
