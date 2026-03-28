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
import LocalizableStringBundle

/// Default implementations of various ModelSettingContainerCollection methods.
public extension ModelSettingContainerCollection {

    /// Combines settings config with a model setting property keypath to install a model setting in a map keyed by the property ID.
    @MainActor
    func installSettings<ModelSettingContainer>(
        _ propertyMap: ModelSettingPropertiesMap<ModelSettingContainer>,
        modelSettingActions: ModelSettingActions,
        dependencyMap: ModelSettingDependencyMap<Context>? = nil,
        contextKeyPath: WritableKeyPath<Context, ModelSettingContainer>,
        into map: inout ModelSettingMap
    ) {
        for property in propertyMap.values {
            guard let action = modelSettingActions.actions[property.id] else {
                // Skip properties with no action.
                continue
            }
            switch action {
            case .boolean(let boolAction):
                installBooleanAction(property, boolAction)

            case .float(let floatAction):
                installFloatAction(property, floatAction)

            case .ndFloat(let ndFloatAction):
                installNDFloatAction(property, ndFloatAction)

            case .cgFloat(let cgFloatAction):
                installCGFloatAction(property, cgFloatAction)

            case .ndPoint(let pointAction):
                installNDPointAction(property, pointAction)

            case .cgPoint(let pointAction):
                installCGPointAction(property, pointAction)

            case .ndSize(let sizeAction):
                installNDSizeAction(property, sizeAction)

            case .cgSize(let sizeAction):
                installCGSizeAction(property, sizeAction)

            case .ndAngle(let ndAngleAction):
                installNDAngleAction(property, ndAngleAction)

            case .angle(let angleAction):
                installAngleAction(property, angleAction)

            case .integer(let integerAction):
                installIntegerAction(property, integerAction)
            }
        }

        func installBooleanAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ boolAction: BoolModelSettingAction
        ) {
            var boolModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    boolModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: Bool.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .boolean(boolSettingByKeyPath(
                    keyPath,
                    dependency: boolModelDependency,
                    action: boolAction
                )))
            }
        }

        func installFloatAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ floatAction: FloatModelSettingAction<Double>
        ) {
            var floatModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    floatModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: Double.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .float(floatSettingByKeyPath(
                    keyPath,
                    dependency: floatModelDependency,
                    action: floatAction
                )))
            }
        }

        func installNDFloatAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ ndFloatAction: FloatModelSettingAction<NDFloat>
        ) {
            var floatModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    floatModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: NDFloat.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .ndFloat(floatSettingByKeyPath(
                    keyPath,
                    dependency: floatModelDependency,
                    action: ndFloatAction
                )))
            }
        }

        func installCGFloatAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ cgFloatAction: FloatModelSettingAction<CGFloat>
        ) {
            var floatModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    floatModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: CGFloat.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .cgFloat(floatSettingByKeyPath(
                    keyPath,
                    dependency: floatModelDependency,
                    action: cgFloatAction
                )))
            }
        }

        func installNDPointAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ pointAction: PointModelSettingAction<NDFloat>
        ) {
            var xModelDependency: ModelSettingDependency<Context>?
            var yModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .point(let x, let y) = dependency {
                    xModelDependency = .solo(x)
                    yModelDependency = .solo(y)
                }
            }

            property.withWritablePointPath(
                from: contextKeyPath,
                as: NDPoint.self) { xKeyPath, yKeyPath in

                map[property.id] = ModelSetting(settingType: .ndPoint(
                    PointViewModelSetting(
                        action: pointAction,
                        xSetting: floatSettingByKeyPath(
                            xKeyPath,
                            dependency: xModelDependency,
                            action: FloatModelSettingAction(
                                actionName: pointAction.xActionName,
                                range: pointAction.range, step: pointAction.step,
                                precision: pointAction.precision)
                        ),
                        ySetting: floatSettingByKeyPath(
                            yKeyPath,
                            dependency: yModelDependency,
                            action: FloatModelSettingAction(
                                actionName: pointAction.yActionName,
                                range: pointAction.range, step: pointAction.step,
                                precision: pointAction.precision)
                        )
                    )))
            }
        }

        func installCGPointAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ pointAction: PointModelSettingAction<CGFloat>
        ) {
            var xModelDependency: ModelSettingDependency<Context>?
            var yModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .point(let x, let y) = dependency {
                    xModelDependency = .solo(x)
                    yModelDependency = .solo(y)
                }
            }

            property.withWritablePointPath(
                from: contextKeyPath,
                as: CGPoint.self) { xKeyPath, yKeyPath in

                map[property.id] = ModelSetting(settingType: .cgPoint(
                    PointViewModelSetting(
                        action: pointAction,
                        xSetting: floatSettingByKeyPath(
                            xKeyPath,
                            dependency: xModelDependency,
                            action: FloatModelSettingAction(
                                actionName: pointAction.xActionName,
                                range: pointAction.range, step: pointAction.step,
                                precision: pointAction.precision)
                        ),
                        ySetting: floatSettingByKeyPath(
                            yKeyPath,
                            dependency: yModelDependency,
                            action: FloatModelSettingAction(
                                actionName: pointAction.yActionName,
                                range: pointAction.range, step: pointAction.step,
                                precision: pointAction.precision)
                        )
                    )))
            }
        }


        func installNDSizeAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ sizeAction: SizeModelSettingAction<NDFloat>
        ) {
            var widthModelDependency: ModelSettingDependency<Context>?
            var heightModelDependency: ModelSettingDependency<Context>?
            var maintainSizeRatioModelDependency: ModelSettingDependency<Context>?
            var sizeRatioModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .size(let width, let height, let maintainSizeRatio, let sizeRatio) = dependency {
                    widthModelDependency = .solo(width)
                    heightModelDependency = .solo(height)
                    maintainSizeRatioModelDependency = .solo(maintainSizeRatio)
                    sizeRatioModelDependency = .solo(sizeRatio)
                }
            }
            guard let maintainSizeRatioProp =
                    propertyMap[sizeAction.maintainSizeRatioSettingID] else {
                return
            }

            guard let sizeRatioProp = propertyMap[sizeAction.sizeRatioSettingID] else {
                return
            }
            property.withWritableSizePath(
                from: contextKeyPath,
                as: NDSize.self) { widthKeyPath, heightKeyPath in

                maintainSizeRatioProp.withWritablePath(
                    from: contextKeyPath,
                    as: Bool.self) { maintainSizeRatioKeyPath in

                    sizeRatioProp.withWritablePath(
                        from: contextKeyPath,
                        as: NDFloat.self) { sizeRatioKeyPath in

                        map[property.id] = ModelSetting(settingType: .ndSize(
                            SizeViewModelSetting(
                                action: sizeAction,
                                widthSetting: floatSettingByKeyPath(
                                    widthKeyPath,
                                    dependency: widthModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.widthActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                ),
                                heightSetting: floatSettingByKeyPath(
                                    heightKeyPath,
                                    dependency: heightModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.heightActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                ),
                                maintainSizeRatioSetting: boolSettingByKeyPath(
                                    maintainSizeRatioKeyPath,
                                    dependency: maintainSizeRatioModelDependency,
                                    action: BoolModelSettingAction(
                                        actionName: sizeAction.maintainSizeRatioActionName)
                                ),
                                sizeRatioSetting: floatSettingByKeyPath(
                                    sizeRatioKeyPath,
                                    dependency: sizeRatioModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.heightActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                )
                            )))
                    }
                }
            }
        }

        func installCGSizeAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ sizeAction: SizeModelSettingAction<CGFloat>
        ) {
            var widthModelDependency: ModelSettingDependency<Context>?
            var heightModelDependency: ModelSettingDependency<Context>?
            var maintainSizeRatioModelDependency: ModelSettingDependency<Context>?
            var sizeRatioModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .size(let width, let height, let maintainSizeRatio, let sizeRatio) = dependency {
                    widthModelDependency = .solo(width)
                    heightModelDependency = .solo(height)
                    maintainSizeRatioModelDependency = .solo(maintainSizeRatio)
                    sizeRatioModelDependency = .solo(sizeRatio)
                }
            }
            guard let maintainSizeRatioProp =
                    propertyMap[sizeAction.maintainSizeRatioSettingID] else {
                return
            }

            guard let sizeRatioProp = propertyMap[sizeAction.sizeRatioSettingID] else {
                return
            }

            property.withWritableSizePath(
                from: contextKeyPath,
                as: CGSize.self) { widthKeyPath, heightKeyPath in

                maintainSizeRatioProp.withWritablePath(
                    from: contextKeyPath,
                    as: Bool.self) { maintainSizeRatioKeyPath in

                    sizeRatioProp.withWritablePath(
                        from: contextKeyPath,
                        as: CGFloat.self) { sizeRatioKeyPath in

                        map[property.id] = ModelSetting(settingType: .cgSize(
                            SizeViewModelSetting(
                                action: sizeAction,
                                widthSetting: floatSettingByKeyPath(
                                    widthKeyPath,
                                    dependency: widthModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.widthActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                ),
                                heightSetting: floatSettingByKeyPath(
                                    heightKeyPath,
                                    dependency: heightModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.heightActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                ),
                                maintainSizeRatioSetting: boolSettingByKeyPath(
                                    maintainSizeRatioKeyPath,
                                    dependency: maintainSizeRatioModelDependency,
                                    action: BoolModelSettingAction(
                                        actionName: sizeAction.maintainSizeRatioActionName)
                                ),
                                sizeRatioSetting: floatSettingByKeyPath(
                                    sizeRatioKeyPath,
                                    dependency: sizeRatioModelDependency,
                                    action: FloatModelSettingAction(
                                        actionName: sizeAction.heightActionName,
                                        range: sizeAction.range, step: sizeAction.step,
                                        precision: sizeAction.precision)
                                )
                            )))
                    }
                }
            }
        }

        func installAngleAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ angleAction: AngleModelSettingAction<Angle>
        ) {
            var angleModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    angleModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: Angle.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .angle(angleSettingByKeyPath(
                    keyPath,
                    dependency: angleModelDependency,
                    action: angleAction
                )))
            }
        }

        func installNDAngleAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ ndAngleAction: AngleModelSettingAction<NDAngle>
        ) {
            var angleModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    angleModelDependency = dependency
                }
            }
            property.withWritablePath(from: contextKeyPath, as: NDAngle.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .ndAngle(ndAngleSettingByKeyPath(
                    keyPath,
                    dependency: angleModelDependency,
                    action: ndAngleAction
                )))
            }
        }

        func installIntegerAction(
            _ property: ModelSettingProperty<ModelSettingContainer>,
            _ integerAction: IntegerModelSettingAction
        ) {
            var integerModelDependency: ModelSettingDependency<Context>?
            if let dependency = dependencyMap?[property.id] {
                if case .solo = dependency {
                    integerModelDependency = dependency
                }
            }

            property.withWritablePath(from: contextKeyPath, as: Int.self) { keyPath in
                map[property.id] = ModelSetting(settingType: .integer(integerSettingByKeyPath(
                    keyPath,
                    dependency: integerModelDependency,
                    action: integerAction
                )))
            }
        }
    }

    func floatSettingByKeyPath<SettingContext, Value: BinaryFloatingPoint>(
        _ keyPath: WritableKeyPath<SettingContext, Value>,
        dependency: ModelSettingDependency<SettingContext>?,
        action: FloatModelSettingAction<Value>
    ) -> FloatViewModelSetting<Value> {
        let bindings = makeBindings(
            keyPath, dependency: dependency, actionName: action.actionName)
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
            keyPath, dependency: dependency, actionName: action.actionName)

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
            keyPath, dependency: dependency, actionName: action.actionName)

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
            keyPath, dependency: dependency, actionName: action.actionName)

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
                actionName: action.actionName)
        )
    }
}
