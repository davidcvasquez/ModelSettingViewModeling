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

final class ModelSettingViewModelingTests: XCTestCase {
    @MainActor
    func testInternalStringsInstaller() {
        do {
            try LocalizableStringBundle.Strings.install()
            try ModelSettingViewModeling.Strings.install()
            try Strings.install()
        } catch {
            XCTFail("Failed to install Strings: \(error)")
        }
    }

    @MainActor
    func testInternalStringLookups() {
        do {
            try LocalizableStringBundle.Strings.install()
        } catch {
            XCTFail("Failed to install LocalizableStringBundle.Strings: \(error)")
        }

        let applyLabel = String(localized: LocalizationKey.applyLabel.resource)
        XCTAssertEqual(applyLabel, "Apply")

        let resetLabel = String(localized: LocalizationKey.resetLabel.resource)
        XCTAssertEqual(resetLabel, "Reset")
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

@MainActor
fileprivate func testName(_ key: String) -> LocalizationKey {
    LocalizationKey(key, bundle: .module, tableName: "Test")
}

public extension LocalizationKey {
    static let testLabel = testName("test")
    static let anotherTestLabel = testName("anotherTest")
}
