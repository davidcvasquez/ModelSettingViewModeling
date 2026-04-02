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
import ModelSettingViewModeling
import LocalizableStringBundle
import LoggerCategories
import OSLog

var initCount: Int = 0

struct PackageRunnerApp: App {
//#if os(macOS)
//    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
//#endif

    @State private var localization: LocalizationRuntime
    @State private var layoutOptions: ModelSettingViewLayoutOptions

    init() {
        initCount += 1
        Logger.debug("initCount: \(initCount)", LogCategory.general)

        self.localization = LocalizationRuntime()
        self.layoutOptions = ModelSettingViewLayoutOptions()

        self.registerPreferences()

        do {
            try LocalizableStringBundle.Strings.install()
            try ModelSettingViewModeling.Strings.install()
            try SettingsStrings.install()
        } catch {
            Logger.debug("Install error: \(error)", LogCategory.localization)
        }
    }

    var body: some Scene {
        DocumentGroup(newDocument: Document.init) { config in
            ContentView(document: config.document, layoutOptions: layoutOptions)
                .environment(localization)
                .focusedSceneObject(config.document)
                .task {
                    config.document.fileURL = config.fileURL
                }
                .onChange(of: config.fileURL) { oldURL, newURL in
                    config.document.fileURL = newURL
                }
        }
    }

    private func registerPreferences() {
        UserDefaults.standard.register(defaults: [
            .showModelSettingsPrefKey: true
        ])
    }
}

#if os(iOS)
private struct PackageRunnerUITestApp: App {
    @State private var localization: LocalizationRuntime
    @State private var layoutOptions: ModelSettingViewLayoutOptions

    init() {
        initCount += 1
        Logger.debug("initCount: \(initCount)", LogCategory.general)

        self.localization = LocalizationRuntime()
        self.layoutOptions = ModelSettingViewLayoutOptions()

        self.registerPreferences()

        do {
            try LocalizableStringBundle.Strings.install()
            try ModelSettingViewModeling.Strings.install()
            try SettingsStrings.install()
        } catch {
            Logger.debug("Install error: \(error)", LogCategory.localization)
        }
    }

    var body: some Scene {
        WindowGroup("UI Test Document") {
            TestDocumentContentView(layoutOptions: layoutOptions)
                .environment(localization)
        }
    }

    private func registerPreferences() {
        UserDefaults.standard.register(defaults: [
            .showModelSettingsPrefKey: true
        ])
    }
}

private struct TestDocumentContentView: View {
    @State private var document = Document()
    let layoutOptions: ModelSettingViewLayoutOptions

    var body: some View {
        ContentView(document: document, layoutOptions: layoutOptions)
            .focusedSceneObject(document)
    }
}
#endif

@main
private enum PackageRunnerMain {
    static func main() {
#if os(iOS)
        if ProcessInfo.processInfo.arguments.contains("-uiTestCreateNewDocument") {
            PackageRunnerUITestApp.main()
        } else {
            PackageRunnerApp.main()
        }
#else
        PackageRunnerApp.main()
#endif
    }
}
