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

public extension Document {
    struct MandalaLayerContext {
        var selectedPage: Page
        var selectedLayer: Layer
        var mandalaLayer: MandalaLayer
        var selectedSubLayer: MandalaSubLayer
    }

    // Simple context for selected mandala sublayers, suitable for toggling boolean property state.
    var mandalaLayerContext: MandalaLayerContext? {
        get {
            guard let selectedPage = self.book.selectedPage,
                  let selectedLayer = selectedPage.selectedLayer else {
                return nil
            }

            guard case let .mandala(layer) = selectedLayer.properties else {
                return nil
            }

            guard let subLayer = layer.selectedSubLayer else {
                return nil
            }

            return MandalaLayerContext(
                selectedPage: selectedPage,
                selectedLayer: selectedLayer,
                mandalaLayer: layer,
                selectedSubLayer: subLayer)
        }

        set {
            guard var context = newValue else {
                return
            }
            context.selectedSubLayer.revision &+= 1
            context.mandalaLayer.subLayers[context.selectedSubLayer.id] = context.selectedSubLayer
            context.selectedLayer.properties = .mandala(layer: context.mandalaLayer)
            context.selectedLayer.revision &+= 1
            context.selectedPage.layers[context.selectedLayer.id] = context.selectedLayer
            self.book.pages[context.selectedPage.id] = context.selectedPage

            self.startTrackingLayer()
        }
    }

    // Use this context for operations that potentially span multiple sublayers.
    var allMandalaSubLayersContext: MandalaLayerContext? {
        get {
            guard let selectedPage = self.book.selectedPage,
                  let selectedLayer = selectedPage.selectedLayer else {
                return nil
            }

            guard case let .mandala(layer) = selectedLayer.properties else {
                return nil
            }

            guard let subLayer = layer.selectedSubLayer else {
                return nil
            }

            return MandalaLayerContext(
                selectedPage: selectedPage,
                selectedLayer: selectedLayer,
                mandalaLayer: layer,
                selectedSubLayer: subLayer)
        }

        set {
            guard var context = newValue else {
                return
            }
            context.selectedLayer.properties = .mandala(layer: context.mandalaLayer)
            context.selectedLayer.revision &+= 1
            context.selectedPage.layers[context.selectedLayer.id] = context.selectedLayer
            self.book.pages[context.selectedPage.id] = context.selectedPage

            self.startTrackingLayer()
        }
    }

    // Push context back to the selected layer, page, and book, accounting for value semantics.
    // Suitable for sublayer ops as seen in the layer stack view.
    func pushAllMandalaSubLayers(context: MandalaLayerContext) {
        var context = context
        context.selectedLayer.properties = .mandala(layer: context.mandalaLayer)
        context.selectedLayer.revision &+= 1
        context.selectedPage.layers[context.selectedLayer.id] = context.selectedLayer
        self.book.pages[context.selectedPage.id] = context.selectedPage

        self.startTrackingLayer()
    }
    
    // Tracking context for mandala sublayers, suitable for tracking scalar property state.
    var trackingMandalaLayerContext: MandalaLayerContext? {
        get {
            guard let selectedPage = self.book.selectedPage,
                  let selectedLayer = self.trackingLayer ?? selectedPage.selectedLayer else {
                return nil
            }

            guard case let .mandala(layer) = selectedLayer.properties else {
                return nil
            }

            guard let subLayer = layer.selectedSubLayer else {
                return nil
            }

            return MandalaLayerContext(
                selectedPage: selectedPage,
                selectedLayer: selectedLayer,
                mandalaLayer: layer,
                selectedSubLayer: subLayer)
        }

        set {
            guard var context = newValue else {
                return
            }
            context.selectedSubLayer.revision &+= 1
            context.mandalaLayer.subLayers[context.selectedSubLayer.id] = context.selectedSubLayer
            self.trackingLayer?.revision &+= 1
            self.trackingLayer?.properties = .mandala(layer: context.mandalaLayer)
        }
    }

    struct MandalaSubLayerByIDContext {
        var selectedPage: Page
        var selectedLayer: Layer
        var mandalaLayer: MandalaLayer
        var subLayerByID: MandalaSubLayer
    }

    // Simple context for mandala sublayers by ID, suitable for toggling boolean property state.
    func mandalaSubLayerByIDContext(_ id: MandalaSubLayer.ID) -> MandalaSubLayerByIDContext? {
        guard let selectedPage = self.book.selectedPage,
              let selectedLayer = selectedPage.selectedLayer else {
            return nil
        }

        guard case let .mandala(layer) = selectedLayer.properties else {
            return nil
        }

        guard let subLayerByID = layer.subLayers[id] else {
            return nil
        }

        return MandalaSubLayerByIDContext(
            selectedPage: selectedPage,
            selectedLayer: selectedLayer,
            mandalaLayer: layer,
            subLayerByID: subLayerByID)
    }

    // Push the context back to the selected layer, page, and book, accounting for value semantics.
    func pushMandalaSubLayerByID(context: MandalaSubLayerByIDContext) {
        var context = context
        context.subLayerByID.revision &+= 1
        context.mandalaLayer.subLayers[context.subLayerByID.id] = context.subLayerByID
        context.selectedLayer.properties = .mandala(layer: context.mandalaLayer)
        context.selectedPage.layers[context.selectedLayer.id] = context.selectedLayer
        self.book.pages[context.selectedPage.id] = context.selectedPage

        self.startTrackingLayer()
    }
}
