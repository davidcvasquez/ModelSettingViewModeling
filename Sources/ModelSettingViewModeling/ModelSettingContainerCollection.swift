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
import OrderedCollections
import NDGeometry
import ModelSettingsSupport

public protocol ModelSettingContainerCollection {
    associatedtype Context

    var revision: UInt { get set }

    typealias SettingDependency = (inout Context) -> Void

    @MainActor
    func installSettings<ModelSettingContainer>(
        _ propertyMap: ModelSettingPropertiesMap<ModelSettingContainer>,
        modelSettingActions: ModelSettingActions,
        dependencyMap: ModelSettingDependencyMap<Context>?,
        contextKeyPath: WritableKeyPath<Context, ModelSettingContainer>,
        into map: inout ModelSettingMap
    )

    var canUndo: Bool { get }

    var canRedo: Bool { get }

    var undoActionName: String { get }

    var redoActionName: String { get }

    func undo()

    func redo()

    func startUndoGroup()

    func undoablyPerform(
        actionName: LocalizedStringKey,
        startGroupIfNotInGroup: Bool,
        endGroupIfInGroup: Bool,
        doit: () -> Void
    )

    func endUndoGroup()

    @MainActor
    func floatSettingByKeyPath<SettingContext, Value: BinaryFloatingPoint>(
        _ keyPath: WritableKeyPath<SettingContext, Value>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: FloatModelSettingAction<Value>
    ) -> FloatViewModelSetting<Value>

    @MainActor
    func angleSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Angle>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: AngleModelSettingAction<Angle>
    ) -> AngleViewModelSetting<Angle>

    @MainActor
    func ndAngleSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, NDAngle>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: AngleModelSettingAction<NDAngle>
    ) -> AngleViewModelSetting<NDAngle>

    @MainActor
    func integerSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Int>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: IntegerModelSettingAction
    ) -> IntegerViewModelSetting

    @MainActor
    func boolSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Bool>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: BoolModelSettingAction
    ) -> BoolViewModelSetting

    @MainActor
    func makeBindings<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<SettingContext>?,
        actionName: LocalizedStringKey
    ) -> (committed: Binding<T?>, tracking: Binding<T?>)

    @MainActor
    func makeCommitBinding<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<SettingContext>?,
        actionName: LocalizedStringKey
    ) -> Binding<T?>
}

public enum ModelSettingDependency<Context> {
    case solo((inout Context) -> Void)

    case point(x: (inout Context) -> Void,
               y: (inout Context) -> Void)

    case size(width: (inout Context) -> Void,
              height: (inout Context) -> Void,
              maintainSizeRatio: (inout Context) -> Void,
              sizeRatio: (inout Context) -> Void)
}

public typealias ModelSettingDependencyMap<Context> =
    [ModelSetting.ID: ModelSettingDependency<Context>]

/// Default implementations of various ModelSettingContainerCollection methods.
public extension ModelSettingContainerCollection {
    func floatSettingByKeyPath<SettingContext, Value: BinaryFloatingPoint>(
        _ keyPath: WritableKeyPath<SettingContext, Value>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: FloatModelSettingAction<Value>
    ) -> FloatViewModelSetting<Value> {
        let bindings = makeBindings(
            keyPath, dependency: dependency, actionName: action.actionNameKey)
        return FloatViewModelSetting<Value>(
            action: action,
            committedValue: bindings.committed,
            trackingValue: bindings.tracking
        )
    }

    @MainActor
    func angleSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Angle>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: AngleModelSettingAction<Angle>
    ) -> AngleViewModelSetting<Angle> {
        let bindings = makeBindings(
            keyPath, dependency: dependency, actionName: action.actionNameKey)

        return AngleViewModelSetting(
            action: action,
            committedValue: bindings.committed,
            trackingValue: bindings.tracking
        )
    }

    @MainActor
    func ndAngleSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, NDAngle>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: AngleModelSettingAction<NDAngle>
    ) -> AngleViewModelSetting<NDAngle> {
        let bindings = makeBindings(
            keyPath, dependency: dependency, actionName: action.actionNameKey)

        return AngleViewModelSetting(
            action: action,
            committedValue: bindings.committed,
            trackingValue: bindings.tracking
        )
    }

    @MainActor
    func integerSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Int>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: IntegerModelSettingAction
    ) -> IntegerViewModelSetting {
        let bindings = makeBindings(
            keyPath, dependency: dependency, actionName: action.actionNameKey)

        return IntegerViewModelSetting(
            action: action,
            committedValue: bindings.committed,
            trackingValue: bindings.tracking
        )
    }

    @MainActor
    func boolSettingByKeyPath<SettingContext>(
        _ keyPath: WritableKeyPath<SettingContext, Bool>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: BoolModelSettingAction
    ) -> BoolViewModelSetting {
        BoolViewModelSetting(
            action: action,
            committedValue: makeCommitBinding(
                keyPath,
                dependency: dependency,
                actionName: action.actionNameKey)
        )
    }
}
