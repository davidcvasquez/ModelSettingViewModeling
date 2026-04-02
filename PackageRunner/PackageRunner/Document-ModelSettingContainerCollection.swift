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
import ModelSettingsSupport
import ModelSettingViewModeling
import LocalizableStringBundle

extension Document: ModelSettingContainerCollection {

    public typealias Context = Document.MandalaLayerContext

    @MainActor
    public func makeBindings<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<SettingContext>?,
        actionName: LocalizationKey
    ) -> (committed: Binding<T?>, tracking: Binding<T?>) {
        makeMandalaBindings(
            keyPath,
            dependency: dependency as? ModelSettingDependency<Context>,
            actionName: actionName
        )
    }

    @MainActor
    private func makeMandalaBindings<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<Context>?,
        actionName: LocalizationKey
    ) -> (committed: Binding<T?>, tracking: Binding<T?>) {

        guard let _keyPath = keyPath as? WritableKeyPath<MandalaLayerContext, T> else {
            fatalError()
        }

        let committed = Binding<T?>(
            get: {
                guard let ctx = self.mandalaLayerContext else { return nil }
                return ctx[keyPath: _keyPath]
            },
            set: { [weak self] newValue in
                guard let strongSelf = self else { return }
                guard var ctx = strongSelf.mandalaLayerContext,
                      let newValue else {
                   return
                }

                let oldValue = ctx[keyPath: _keyPath]
                guard newValue != oldValue else {
                    return
                }

                strongSelf.undoablyPerform(
                    actionName: actionName,
                    startGroupIfNotInGroup: false,
                    endGroupIfInGroup: false
                ) {
                    ctx[keyPath: _keyPath] = newValue

                    if let dependency {
                        switch dependency {
                        case .solo(let dep):
                            dep(&ctx)
                        case .point(_, _):
                            break
                        case .size(_, _, _, _):
                            break
                        }
                    }

                    strongSelf.mandalaLayerContext = ctx
                }

                strongSelf.notifyEdit()
            }
        )

        let tracking = Binding<T?>(
            get: {
                guard let ctx = self.trackingMandalaLayerContext else { return nil }
                return ctx[keyPath: _keyPath]
            },
            set: { newValue in
                guard var ctx = self.trackingMandalaLayerContext,
                      let newValue else { return }

                let oldValue = ctx[keyPath: _keyPath]
                guard newValue != oldValue else { return }

                ctx[keyPath: _keyPath] = newValue

                if let dependency {
                    switch dependency {
                    case .solo(let dep):
                        dep(&ctx)
                    case .point(_, _):
                        break
                    case .size(_, _, _, _):
                        break
                    }
                }

                self.trackingMandalaLayerContext = ctx
            }
        )

        return (committed, tracking)
    }

    @MainActor
    public func makeCommitBinding<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<SettingContext>?,
        actionName: LocalizationKey
    ) -> Binding<T?> {
        makeMandalaCommitBinding(
            keyPath,
            dependency: dependency as? ModelSettingDependency<Context>,
            actionName: actionName
        )
    }

    @MainActor
    private func makeMandalaCommitBinding<SettingContext, T: Equatable>(
        _ keyPath: WritableKeyPath<SettingContext, T>,
        dependency: ModelSettingDependency<Context>?,
        actionName: LocalizationKey
    ) -> Binding<T?> {

        guard let _keyPath = keyPath as? WritableKeyPath<MandalaLayerContext, T> else {
            fatalError()
        }

        return Binding<T?>(
            get: {
                guard let ctx = self.mandalaLayerContext else { return nil }
                return ctx[keyPath: _keyPath]
            },
            set: { [weak self] newValue in
                guard let strongSelf = self else { return }
                guard var ctx = strongSelf.mandalaLayerContext,
                      let newValue else { return }

                let oldValue = ctx[keyPath: _keyPath]
                guard newValue != oldValue else {
                    return
                }

                strongSelf.undoablyPerform(
                    actionName: actionName,
                    startGroupIfNotInGroup: false,
                    endGroupIfInGroup: false
                ) {
                    ctx[keyPath: _keyPath] = newValue

                    if let dependency {
                        switch dependency {
                        case .solo(let dep):
                            dep(&ctx)
                        case .point(_, _):
                            break
                        case .size(_, _, _, _):
                            break
                        }
                    }

                    strongSelf.mandalaLayerContext = ctx
                }

                strongSelf.notifyEdit()
            }
        )
    }
}
