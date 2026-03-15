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
import LoggerCategories
import NDGeometry
import OSLog
import LocalizableStringBundle

public struct ModelSettingGridRowView<ViewModel: ModelSettingViewModel>: View, Identifiable {
    @Environment(\.isEnabled) private var isEnabled

    public let id: String       // This ID is only for the SwiftUI view identity.

    public let modelSettingID: ModelSetting.ID

    @Bindable public var viewModel: ViewModel

    @Binding public var isTrackingInput: Bool
    @Binding public var focusedID: ModelSetting.ID?

    @Binding var dragID: ModelSetting.ID?
    @Binding var hoverID: ModelSetting.ID?

    @Binding var orderedIDsForCustomize: [ModelSetting.ID]

    var viewStyle: ModelSettingViewStyle? {
        self.viewModel.modelSettingViewStyles.viewStyles[self.modelSettingID]
    }

    var styles: ModelSettingViewStyles {
        self.viewModel.modelSettingViewStyles
    }

    var isVisible: Bool {
        viewStyle?.isVisible ?? false
    }

    var specialPresentation: ModelSettingViewStyle.SpecialPresentation? {
        self.viewStyle?.specialPresentation
    }

    private var iconOpacity: NDFloat {
        self.isEnabled ? 0.85 : 0.25
    }

    /// - Returns: The label text to show in this view.
    var labelText: LocalizationKey {
        viewStyle?.labelText ?? .missing
    }

    @State private var isDropTargeted: Bool = false

    private func updateOrderedIDsForCustomize() {
        self.orderedIDsForCustomize = Array(styles.viewStyles.keys)
        self.orderedIDsForCustomize.append("")
    }

    private func modelSettingType(for id: ModelSetting.ID) -> ModelSettingType {
        guard !id.isEmpty else {
            return .placeholder
        }

        guard let modelSetting = viewModel.modelSettingTypes.types[self.modelSettingID] else {
            return .missing("No modelSettingType for ID: \(self.modelSettingID)")
        }
        return modelSetting.settingType
    }

    private func move(
        dragID: ModelSetting.ID,
        hovering targetID: ModelSetting.ID
    ) {
        guard viewModel.layoutOptions.reorderSettings else { return }

        var orderedIDsForCustomize = self.orderedIDsForCustomize

        // Remove the dragged ID from its old position.
        guard let index = orderedIDsForCustomize.firstIndex(of: dragID) else {
            Logger.debug("Index not found for \(dragID)", LogCategory.general)
            return
        }
        orderedIDsForCustomize.remove(at: index)

        // Find the index of the target ID.
        guard let to = orderedIDsForCustomize.firstIndex(of: targetID) else {
            Logger.debug("Index not found for \(targetID)", LogCategory.general)
            return
        }

        let insertion = to

        Logger.debug("Moving \(dragID) to index \(insertion) above \(targetID)", LogCategory.general)

        // Re-insert the dragged ID at the target index.
        orderedIDsForCustomize.insert(dragID, at: max(insertion, 0))

        // Commit the new IDs back to the view model.
        let old = viewModel.modelSettingViewStyles.viewStyles

        var newMap = ModelSettingViewStyleMap()
        newMap.reserveCapacity(old.count)

        for id in orderedIDsForCustomize {
            guard !id.isEmpty else { continue }

            if let style = old[id] {
                newMap[id] = style
            }
        }

        // Safety: if something changed concurrently, keep any missing keys appended.
        if newMap.count != old.count {
            for (id, style) in old where newMap[id] == nil {
                newMap[id] = style
            }
        }

        self.viewModel.modelSettingViewStyles.viewStyles = newMap

        updateOrderedIDsForCustomize()
    }

    private var visibilityToggleView: some View {
        Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
            .resizable()
            .scaledToFit()
            .opacity(self.iconOpacity)
            .frame(width: 18, height: 18)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8.0))
            .help(self.labelText)
            .onTapGesture {
                withAnimation {
                    self.viewModel.modelSettingViewStyles.viewStyles[self.modelSettingID]?.isVisible.toggle()
                }
            }
    }

    private var dragGrabberView: some View {
        // Show reorder symbol on trailing edge of each item.
        Image(systemName: "line.3.horizontal")
            .resizable()
            .scaledToFit()
            .opacity(self.iconOpacity)
            .frame(width: 18, height: 18)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8.0))
            .help("Reorder")
    }

    private var modelSettingView: some View {
        Group {
            switch modelSettingType(for: modelSettingID) {
            case .placeholder:
                Rectangle()
                    .fill(.clear)
                    .frame(height: 42.0)

            case .missing(let name):
                Text(name)
                    .foregroundColor(.secondary)

            case .boolean(_):
                ToggleModelSettingView(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .float(_):
                FloatModelSettingView<Double, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    isFocused: Binding(
                        get: { focusedID == modelSettingID },
                        set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                    ),
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .ndFloat(_):
                FloatModelSettingView<NDFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    isFocused: Binding(
                        get: { focusedID == modelSettingID },
                        set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                    ),
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .cgFloat(_):
                FloatModelSettingView<CGFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    isFocused: Binding(
                        get: { focusedID == modelSettingID },
                        set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                    ),
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .ndPoint(_):
                PointModelSettingView<NDFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    focusedID: $focusedID
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .cgPoint(_):
                PointModelSettingView<CGFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    focusedID: $focusedID
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .ndSize(_):
                SizeModelSettingView<NDFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    focusedID: $focusedID
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .cgSize(_):
                SizeModelSettingView<CGFloat, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    focusedID: $focusedID
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .ndAngle(_):
                AngleModelSettingView<NDAngle, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    isFocused: Binding(
                        get: { focusedID == modelSettingID },
                        set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                    )
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .angle(_):
                AngleModelSettingView<Angle, ViewModel>(
                    id: self.modelSettingID,
                    viewModel: viewModel,
                    isTrackingInput: $isTrackingInput,
                    isFocused: Binding(
                        get: { focusedID == modelSettingID },
                        set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                    )
                )
                .environment(\.isEnabled, isEnabled && isVisible)

            case .integer(_):
                switch self.specialPresentation {
                case .native, .integer:
                    IntegerModelSettingView(
                        id: self.modelSettingID,
                        viewModel: viewModel,
                        isTrackingInput: $isTrackingInput,
                        isFocused: Binding(
                            get: { focusedID == modelSettingID },
                            set: { $0 ? (focusedID = modelSettingID) : (focusedID = nil) }
                        ),
                    )
                    .environment(\.isEnabled, isEnabled && isVisible)

                case .iconPicker(_):
                    PickerModelSettingView(
                        id: self.modelSettingID,
                        viewModel: viewModel,
                        isTrackingInput: $isTrackingInput
                    )
                    .environment(\.isEnabled, isEnabled && isVisible)

                default:
                    EmptyView()
                }
            } // switch
        }
    }

    public var body: some View {
        VStack {
            HStack {
                if viewModel.layoutOptions.reorderSettings, !modelSettingID.isEmpty {
                    visibilityToggleView
                }

                modelSettingView

                // In customize settings mode, add drag-n-drop indicator on trailing edge of item.
                if viewModel.layoutOptions.reorderSettings, !modelSettingID.isEmpty {
                    dragGrabberView
                }
            } // HStack
            .frame(maxWidth: .infinity, alignment: .leading) // fill row width
            .contentShape(Rectangle())                       // row is hit-testable
            .background(isDropTargeted ? Color.accentColor.opacity(0.20) : Color.clear)
#if os(macOS)
            .dropConfiguration { dropSession in
                Swift.print("dropConfiguration Session: \(dropSession)")
                return DropConfiguration(operation: .move)
            }
            .dropDestination(
                for: String.self, isEnabled: true) { draggedIDs, session in
                    Swift.print("dropDestination Session: \(session), draggedIDs: \(draggedIDs)")
                    if session.phase == .entering {
                        guard let dragID, dragID != modelSettingID else { return }

                        move(dragID: dragID, hovering: modelSettingID)
                        hoverID = nil
                    }
                }
            .onDropSessionUpdated { session in
                dropSessionUpdated(session)

            }
#else
            .onDrop(of: [.text], delegate: GridRowDropDelegate(
                dragID: $dragID,
                hoverID: $hoverID,
                orderedIDsForCustomize: $orderedIDsForCustomize,
                performMove: move
                ))

            .dropDestination(
                for: String.self,
                action: { items, _ in
                    // Drop committed
                    dragID = nil
                    return true
                },
                isTargeted: { targeted in
                    isDropTargeted = targeted
                    guard targeted else { return }
                    guard viewModel.layoutOptions.reorderSettings else { return }
                    guard let dragID, dragID != modelSettingID else { return }

                    move(dragID: dragID, hovering: modelSettingID)
                }
            )
#endif
            // Divider below each item in customize settings mode.
            if viewModel.layoutOptions.reorderSettings, !modelSettingID.isEmpty {
                let _ = { print(modelSettingID) }
                Rectangle()
                    .fill(.labelColor.opacity(0.25))
                    .frame(height: 1)
            }
        } // VStack
        .contentShape(Rectangle())
    } // body

    func dropSessionUpdated(_ session: DropSession) {
        if session.phase == .entering {
            hoverID = modelSettingID
            Swift.print("onDropSessionUpdated .entering hoverID: \(modelSettingID)")
        }
        else if case .ended(let drop) = session.phase {
            guard let dragID, let hoverID, dragID != modelSettingID else {
                Swift.print("onDropSessionUpdated early exit from drop: \(drop)")
                return
            }
            Swift.print("onDropSessionUpdated drop: \(drop)")
            if drop == .copy || drop == .move {
                self.move(dragID: dragID, hovering: hoverID)
                self.hoverID = nil
                self.dragID = nil
            }
            else if drop == .cancel {
                self.hoverID = nil
                self.dragID = nil
                self.updateOrderedIDsForCustomize()
           }
        }
        else if session.phase == .exiting {
            Swift.print("onDropSessionUpdated phase .exiting")
            // Leave hoverID set until it's set by another row or reset to nil on end drop.
        }
        else if session.phase == .dataTransferCompleted {
            Swift.print("onDropSessionUpdated phase .dataTransferCompleted")
            guard let dragID, dragID != modelSettingID else { return }

        }
        else if session.phase == .active {
            if hoverID != modelSettingID {
                hoverID = modelSettingID
                Swift.print("onDropSessionUpdated phase .active hoverID: \(modelSettingID)")
            }
        }
    }
}

#if os(iOS)
struct GridRowDropDelegate: DropDelegate {
    @Binding var dragID: ModelSetting.ID?
    @Binding var hoverID: ModelSetting.ID?
    @Binding var orderedIDsForCustomize: [ModelSetting.ID]
    var performMove: (_ dragID: ModelSetting.ID, _ targetID: ModelSetting.ID) -> Void

    // iOS equivalent of .onDropSessionUpdated, but only with location, no phase.
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let location = info.location

        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        Swift.print("GridRowDropDelegate performDrop")

        let location = info.location

        if let provider = info.itemProviders(for: [.text]).first {
            provider.loadObject(ofClass: NSString.self) { (reading, error) in
                if let string = reading as? String {
                    // This closure runs on a background thread, so we
                    // switch to the main thread to perform the move.
                    DispatchQueue.main.async {
                        self.dragID = string
                        if let dragID, let hoverID {
                            performMove(dragID, hoverID)
                        }
                        self.hoverID = nil
                        self.dragID = nil

                        print("Dropped item: \(string)")
                    }
                }
            }
            return true
        }
        return false
    }

    func dropExited(info: DropInfo) {
        Swift.print("GridRowDropDelegate dropExited")
    }
}
#endif
