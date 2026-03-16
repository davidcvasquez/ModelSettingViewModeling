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
import Observation
import ModelSettingsSupport
import ModelSettingViewModeling

/// An observable view model object for model settings, which coordinates:
/// - managing model setting properties
/// - actions on the model
/// - presentation of view setting UI
@MainActor
@Observable
public final class TestModelSettingViewModel: ModelSettingViewModel {

    public typealias ModelSettingContainer = TestModelSettingProperties

    public typealias Context = Document.MandalaLayerContext

    // The keypath for the model setting properties within the Context.
    public typealias PropertiesKeyPath = WritableKeyPath<Context, TestModelSettingProperties>
    public static let modelSettingPropertiesKeyPath: PropertiesKeyPath =
        \.selectedSubLayer.path.modelSettings

    public let id: ModelSetting.ID = .testSettingsID

    @ObservationIgnored
    public let containerCollection: any ModelSettingContainerCollection

    public var revision: UInt = 0

    public init(containerCollection: any ModelSettingContainerCollection,
         layoutOptions: ModelSettingViewLayoutOptions
    ) {
        self.containerCollection = containerCollection
        self.layoutOptions = layoutOptions
    }

    // Workaround for XCTest crash during deallocation.
    // Reproduces when module is built with default isolation set to MainActor.
    // https://github.com/swiftlang/swift/issues/87316
    nonisolated deinit {}

    @ObservationIgnored private var isObserving = false

    /// Called once after init from a task on the ModelSettingGridView.
    public func startObservingRevisions() {
        guard !isObserving else { return }
        isObserving = true
        observeRevision()
    }

    private func observeRevision() {
        withObservationTracking {
            _ = containerCollection.revision
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.revision &+= 1
                strongSelf.observeRevision()  // re-arm
            }
        }
    }

    public var modelSettingActions = TestModelSettingActions.actions

    public var modelSettingViewStyles = TestModelSettingViewStyles.viewStyles

    public func resetViewStyles() {
        modelSettingViewStyles = TestModelSettingViewStyles.viewStyles
    }

    public var modelSettingDependencyMap: ModelSettingDependencyMap<Context> = [:]

    private var _settingMap: ModelSettingMap = [:]
    public var modelSettingTypes: ModelSettingTypes {
        if let containerCollection = self.containerCollection as? Document,
           self._settingMap.isEmpty {
            containerCollection.installSettings(
                ModelSettingContainer.__modelSettingProperties,
                modelSettingActions: modelSettingActions,
                dependencyMap: modelSettingDependencyMap,
                contextKeyPath: Self.modelSettingPropertiesKeyPath,
                into: &self._settingMap)
        }
        return ModelSettingTypes(
            id: .testSettingsID,
            name: ModelSettingContainer.__name,
            types: self._settingMap)
    }

    public var layoutOptions: ModelSettingViewLayoutOptions
}


#Preview("TestModelSettingViewModel") {
    @Previewable @State var layoutOptions = ModelSettingViewLayoutOptions()
    ModelSettingViewLayoutOptionsPreview(layoutOptions: layoutOptions) {
        var isTrackingInput: Binding<Bool> = .constant(false)
        var focusedID: Binding<ModelSetting.ID?> = .constant(nil)
        ModelSettingGridView(
            viewModel: TestModelSettingViewModel(
                containerCollection: Document(),
                layoutOptions: layoutOptions),
            isTrackingInput: isTrackingInput,
            focusedID: focusedID
        )
    }
}

public extension String {
    static let showModelSettingsPrefKey = "showModelSettings"
}
