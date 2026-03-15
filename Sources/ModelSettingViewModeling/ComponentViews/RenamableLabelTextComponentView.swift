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
import LocalizableStringBundle

public struct RenamableLabelTextComponentView<ViewModel: ModelSettingViewModel>: ViewModelComponentView {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(LocalizationRuntime.self) private var localization

    public let viewModel: ViewModel
    @Binding public var isTrackingInput: Bool

    public var labelText: LocalizationKey
    public let verticalAlignment: VerticalAlignment

    public var body: some View {
        if layoutOptions.showLabelText {
            if layoutOptions.reorderSettings, layoutOptions.enableRenaming {
                HStack {
                    if self.isEditingName {
                        TextField("", text: $draft)
                            .textFieldStyle(.roundedBorder)
                            .font(.caption)
                            .padding(self.labelTextFieldPadding)
                            .onAppear {
                                if let editor {
                                    draft = editor.currentValue(for: labelText)
                                }
                            }
                            .focused($focused)
                            .onSubmit {
                                Task {
                                    if let editor {
                                        await editor.setSupportValue(draft, for: labelText)
                                    }
                                }
                            }
                            .contextMenu {
                                Button("Apply") {
                                    Task {
                                        if let editor {
                                            await editor.setSupportValue(draft, for: labelText)
                                        }
                                    }
                                }
                                Button("Reset") {
                                    Task {
                                        if let editor {
                                            await editor.clearSupportValue(for: labelText)
                                        }
                                    }
                                }
                            }
                    }
                    else {
                        textLabel
                    }
                    Button {
                        self.editor?.isEditingStrings.toggle()
                    } label: {
                        if isEditingName {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .symbolRenderingMode(.multicolor)
                                .foregroundStyle(.tint)
                                .frame(width: renameButtonSize, height: renameButtonSize)
                                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                        }
                        else {
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .resizable()
                                .scaledToFit()
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.tint)
                                .frame(width: renameButtonSize, height: renameButtonSize)
                                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                       }
                    }
                    .controlSize(.extraLarge)
                    .buttonStyle(.plain)
                    .padding(EdgeInsets(
                        top: self.renameVerticleMargin,
                        leading: 5.0,
                        bottom: 0, trailing: 0))
                   .help(self.isEditingName ? "Done" : "Edit Setting Name")

                    Spacer()
                }
                .task {
                    self.editor = LocalizationEditorService(runtime: localization)
                }
            }
            else {
                textLabel
            }
        }
    }

    @State private var editor: LocalizationEditorService?
    private var isEditingName: Bool {
        self.editor?.isEditingStrings ?? false
    }

    @State private var draft: String = ""
    @FocusState private var focused: Bool

    let renameButtonSize: CGFloat = 18.0

    var renameVerticleMargin: CGFloat {
        (verticalAlignment == .top ?
            layoutOptions.verticalTitleMargin :
            layoutOptions.centeredVerticalTitleMargin) - (self.isEditingName ? 0.0 : 2.0)
    }

    var labelEditFieldVerticalMargin: CGFloat {
        (verticalAlignment == .top ?
            layoutOptions.verticalTitleMargin :
            layoutOptions.centeredVerticalTitleMargin) - (self.isEditingName ? 3.0 : 0.0)
    }

    var labelTextFieldPadding: EdgeInsets {
        EdgeInsets(
            top: labelEditFieldVerticalMargin,
            leading: 14.0,
            bottom: 0, trailing: 0)
    }

    var labelTextPadding: EdgeInsets {
        EdgeInsets(
            top: verticalAlignment == .top ?
                self.layoutOptions.verticalTitleMargin :
                self.layoutOptions.centeredVerticalTitleMargin,
            leading: 20.0,
            bottom: 0, trailing: 0)
    }

    public var textLabel: some View {
        Text(self.labelText)
            .id(localization.revision)
            .font(.caption)
            .foregroundStyle(Color.primary.opacity(captionOpacity))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(labelTextPadding)
    }

    private var captionOpacity: CGFloat {
        self.isEnabled ? 0.75 : 0.33
    }
}
