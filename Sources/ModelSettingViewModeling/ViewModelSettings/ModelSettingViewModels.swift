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

import Foundation
import OrderedCollections

/// A collection of view models for model settings.
@Observable
public final class ModelSettingViewModels {
    public var viewModels: ModelSettingViewModelMap
    public var layoutOptions: ModelSettingViewLayoutOptions

    public init(
        viewModels: ModelSettingViewModelMap,
        layoutOptions: ModelSettingViewLayoutOptions
    ) {
        self.viewModels = viewModels
        self.layoutOptions = layoutOptions
    }
}

public typealias ModelSettingViewModelMap =
    OrderedDictionary<ModelSetting.ID, any ModelSettingViewModel>

/// An Observable view model object, which coordinates:
/// - managing model setting properties
/// - actions on the model
/// - presentation of view setting UI
///
/// As an Observable object, your ViewModel type should be declared with the @Observable macro:
/// ```
/// @Observable public class MyViewModel: ModelSettingViewModel {
/// ```
/// The root View owner of your ViewModel (the "ContentView") can store its reference as @State:
/// ```
///     @State private var ViewModel: MViewModel
/// ```
/// The view model should be stored by subviews in your view hierarchy with the @Bindable property wrapper:
///     ```
///     @Bindable viewModel: MyViewModel
///     ```
/// This style of usage enables binding to specific properties for two-way interactions and notifications.
public protocol ModelSettingViewModel: AnyObject, Identifiable, Observable {
    associatedtype ModelSettingContainer
    associatedtype Context

    var id: ModelSetting.ID { get }

    var containerCollection: any ModelSettingContainerCollection { get }

    /// Each edit of a setting bumps the revision number.
    var revision: UInt { get set }

    /// Called once after init from a task on the ModelSettingGridView.
    func startObservingRevisions()

    /// The keypath to the root container type for the model settings managed by this view model.
    /// Partial keypaths to individual settings are appended to this keypath to form the full keypath for tracking and commits.
    static var modelSettingPropertiesKeyPath: WritableKeyPath<Context, ModelSettingContainer>
        { get }

    /// An ordered collection of Codable configurations for action types.
    var modelSettingActions: ModelSettingActions { get set }

    /// An ordered collection of presentation styles for model setting views.
    var modelSettingViewStyles: ModelSettingViewStyles { get set }

    func resetViewStyles()

    /// Dependencies that run after model setting values are set via keypaths.
    var modelSettingDependencyMap: ModelSettingDependencyMap<Context> { get set }

    /// An ordered collection of runtime model settings with bindings for tracking and committing changes.
    var modelSettingTypes: ModelSettingTypes { get }

    var layoutOptions: ModelSettingViewLayoutOptions { get }
}
