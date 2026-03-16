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

import XCTest
import LocalizableStringBundle
import ModelSettingViewModeling
import ModelSettingsSupport

final class ModelSettingViewModelingTests: XCTestCase {
    @MainActor
    func testInternalStringsInstaller() {
        do {
            try Self.installStrings()
        } catch {
            XCTFail("Failed to install Strings: \(error)")
        }
    }

    @MainActor
    func testInternalStringLookups() {
        do {
            try Self.installStrings()
        } catch {
            XCTFail("Failed to install LocalizableStringBundle.Strings: \(error)")
        }

        let applyLabel = String(localized: LocalizationKey.applyLabel.resource)
        XCTAssertEqual(applyLabel, "Apply")

        let resetLabel = String(localized: LocalizationKey.resetLabel.resource)
        XCTAssertEqual(resetLabel, "Reset")
    }

    @MainActor
    func testMakeViewModel() {
        let layoutOptions = ModelSettingViewLayoutOptions()

        do {
            try Self.installStrings()
        } catch {
            XCTFail("Failed to install Strings: \(error)")
        }
        let localization = LocalizationRuntime()
        let newDocument = Document.init()
        let viewModels: ModelSettingViewModels = Self.buildViewModels(
            document: newDocument, layoutOptions: layoutOptions)

        XCTAssertTrue(viewModels.viewModels.count > 0)
        guard let viewModel = viewModels.viewModels.values.first else {
            XCTFail()
            return
        }
        let modelSettingTypes = viewModel.modelSettingTypes
        for type in modelSettingTypes.types.values {
            Swift.print("type: \(type)")
        }
        XCTAssertGreaterThan(modelSettingTypes.types.count, 0)

        XCTAssertEqual(viewModels.viewModels.count, 1)
        XCTAssertEqual(localization.revision, 0)
        XCTAssertFalse(LocalizationKey.supportBundles.isEmpty)
    }

    @MainActor
    private static func installStrings() throws {
        try LocalizableStringBundle.Strings.install()
        try ModelSettingViewModeling.Strings.install()
        try Strings.install()
    }

    @MainActor
    private static func buildViewModels(
        document: Document,
        layoutOptions: ModelSettingViewLayoutOptions
    ) -> ModelSettingViewModels {
        ModelSettingViewModels(
            viewModels: [
            .testSettingsID: TestModelSettingViewModel(
                containerCollection: document,
                layoutOptions: layoutOptions)
            ],
            layoutOptions: layoutOptions)
    }
}

@MainActor
public enum Strings {
    public static func install() throws {
        try LocalizedStringBundleInstaller.install(
            from: .module,
            installName: "Test-Strings",
            overwriteExisting: true)
    }
}
