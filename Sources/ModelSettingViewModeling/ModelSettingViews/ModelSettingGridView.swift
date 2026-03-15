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
import OrderedCollections
import LocalizableStringBundle

/// A SwiftUI Grid View of a collection of ModelSettingView subviews, coordinated by a ViewModel type.
public struct ModelSettingGridView<ViewModel: ModelSettingViewModel>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization

    @Bindable public var viewModel: ViewModel

    @Binding public var isTrackingInput: Bool
    @Binding public var focusedID: ModelSetting.ID?

    @State var showSettings: Bool = true
    @State private var glow = true

    public init(
        viewModel: ViewModel,
        isTrackingInput: Binding<Bool>,
        focusedID: Binding<ModelSetting.ID?>
    ) {
        self.viewModel = viewModel
        self._isTrackingInput = isTrackingInput
        self._focusedID = focusedID
    }

    public var layoutOptions: ModelSettingViewLayoutOptions {
        viewModel.layoutOptions
    }

    public var body: some View {
        let _ = viewModel.revision
#if DEBUG
        let _ = Self._logChanges()
#endif
        Group {
            if styles.presentInDisclosureGroup {
                DisclosureGroup(isExpanded: $showSettings) {
                    gridView
                } label: {
                    if layoutOptions.showIcons {
                        Image(systemName: "leaf")
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                    }
                    if layoutOptions.showLabelText {
                        Text(self.styles.labelText)
                            .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 0))
                            .font(.caption)
                    }
                }
                .foregroundStyle(Color.primary.opacity(captionOpacity))
                .onChange(of: showSettings) {
                    UserDefaults.standard.set(showSettings, forKey: self.styles.isVisiblePrefKey)
                }
            }
            else if showSettings {
                gridView
            }
        }
        .onChange(of: layoutOptions.reorderSettings) {
            if layoutOptions.reorderSettings {
                self.updateOrderedIDsForCustomize()
            } else {
                dragID = nil
                hoverID = nil
                orderedIDsForCustomize = []
            }
        }
        .task {
            self.showSettings = UserDefaults.standard.bool(
                forKey: viewModel.modelSettingViewStyles.isVisiblePrefKey)
            viewModel.startObservingRevisions()

            if layoutOptions.reorderSettings {
                self.updateOrderedIDsForCustomize()
            }
        }
        .id(localization.revision)   // forces re-evaluation of the view tree
    }

    public var gridView: some View {
        let ids = layoutOptions.reorderSettings ? orderedIDsForCustomize : visibleViewIDs

        return Grid(alignment: .leading,
             horizontalSpacing: spacing.width,
             verticalSpacing: spacing.height) {

            ForEach(ids, id: \.self) { modelSettingID in
                // The hoverID is for a temporary row to show a drop destination.
                if isDropDestinationID(ids, modelSettingID) {
                    GridRow {
                        dropDestinationView
                    }
                }

                GridRow {
                    ModelSettingGridRowView(
                        id: "\(modelSettingID)-\(showSettings)",
                        modelSettingID: modelSettingID,
                        viewModel: viewModel,
                        isTrackingInput: $isTrackingInput,
                        focusedID: $focusedID,
                        dragID: $dragID,
                        hoverID: $hoverID,
                        orderedIDsForCustomize: $orderedIDsForCustomize
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle()) // make the entire row hit-testable
                    .background(Color.clear)

                    .applyIf(layoutOptions.reorderSettings) { row in
                        row.draggable(dragPayload(for: modelSettingID)) {
                            ModelSettingGridRowView(
                                id: "preview-\(modelSettingID)",
                                modelSettingID: modelSettingID,
                                viewModel: viewModel,
                                isTrackingInput: $isTrackingInput,
                                focusedID: $focusedID,
                                dragID: $dragID,
                                hoverID: $hoverID,
                                orderedIDsForCustomize: $orderedIDsForCustomize
                            )
                            .environment(self.localization)
                            .padding(6)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                } // GridRow
            } // ForEach
        } // Grid
    }

    public var dropDestinationView: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.background.shadow(.inner(
                    color: .accentColor.opacity(glow ? 0.85 : 0.20),
                    radius: 8, x: 0, y: 0)
                ))
                .stroke(Color.accentColor, lineWidth: 2)
                .frame(height: 36)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(
                        autoreverses: true)) {
                            glow.toggle()
                        }
                }
            Rectangle()
                .fill(.labelColor.opacity(0.25))
                .frame(height: 1)
        }
    }

    func signedIndexOf(_ ids: [ModelSetting.ID], id: ModelSetting.ID) -> Int {
        ids.firstIndex(of: id) ?? -1
    }

    func isDropDestinationID(_ ids: [ModelSetting.ID], _ modelSettingID: ModelSetting.ID) -> Bool {
        if let dragID, let hoverID {
            return modelSettingID == hoverID &&
                hoverID != dragID &&
                signedIndexOf(ids, id: dragID) != signedIndexOf(ids, id: hoverID) - 1
        }
        else {
            return false
        }
    }

    private func dragPayload(for id: ModelSetting.ID) -> String {
        self.dragID = id
        return id
    }

    func updateOrderedIDsForCustomize() {
        self.orderedIDsForCustomize = Array(styles.viewStyles.keys)
        self.orderedIDsForCustomize.append("")
    }

    var styles: ModelSettingViewStyles {
        self.viewModel.modelSettingViewStyles
    }

    var isDragDropActive: Bool {
        dragID != nil
    }

    @State private var dragID: ModelSetting.ID? = nil
    @State private var hoverID: ModelSetting.ID? = nil

    @State private var orderedIDsForCustomize: [ModelSetting.ID] = []

    var visibleViewIDs: [ModelSetting.ID] {
        let showAll = layoutOptions.reorderSettings

        return styles.viewStyles.compactMap { id, style in
            (showAll || style.isVisible) ? id : nil
        }
    }

    var captionOpacity: CGFloat {
        return self.isEnabled ? 0.85 : 0.33
    }

    var spacing: CGSize {
        layoutOptions.settingGridSpacing
    }
}

extension View {
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
