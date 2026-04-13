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
import ModelSettingViewModelingCore

final class PackageRunnerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNewUntitledDocument() throws {
        let _ = launchAppAndMakeNewDocument()
    }

    // Layout Size options

    func testAdaptiveLayoutOption() throws {
        chooseLayoutSizeOption(.adaptive)
    }

    func testCompactLayoutOption() throws {
        chooseLayoutSizeOption(.compact)
    }

    func testExpandedLayoutOption() throws {
        chooseLayoutSizeOption(.expanded)
    }

    func testCustomLayoutOption() throws {
        chooseLayoutSizeOption(.custom)
    }

    private func chooseLayoutSizeOption(_ option: LayoutSizeOptions) {
        let app = launchAppAndOpenCustomLayout()
        chooseMenuItem(option.accessibilityIdentifier, fromCustomizeMenuIn: app)
    }

    // Label options

    func testIconOnlyLabelOption() throws {
        chooseLabelOption(.showIconOnly)
    }

    func testTextOnlyLabelOption() throws {
        chooseLabelOption(.showTextOnly)
    }

    func testIconAndTextLabelOption() throws {
        chooseLabelOption(.showIconAndText)
    }

    private func chooseLabelOption(_ option: LabelOptions) {
        let app = launchAppAndOpenCustomLayout()
        chooseMenuItem(option.accessibilityIdentifier, fromCustomizeMenuIn: app)
    }

    // Control options

    func testControlOnlyOption() throws {
        chooseControlOption(.showControlOnly)
    }

    func testControlTextFieldOnly() throws {
        chooseControlOption(.showTextFieldOnly)
    }

    func testControlTextFieldWithPopupControl() throws {
        chooseControlOption(.showTextFieldWithPopupControl)
    }

    func testControlTextFieldWithControl() throws {
        chooseControlOption(.showTextFieldWithControl)
    }

    private func chooseControlOption(_ option: ControlOptions) {
        let app = launchAppAndOpenCustomLayout()
        chooseMenuItem(option.accessibilityIdentifier, fromCustomizeMenuIn: app)
    }

    // Stepper options

    func testNoStepperOption() throws {
        chooseStepperOption(.noStepper)
    }

    func testSmallStepperOption() throws {
        chooseStepperOption(.smallStepper)
    }

    func testLargeStepperOption() throws {
        chooseStepperOption(.largeStepper)
    }

    private func chooseStepperOption(_ option: StepperOptions) {
        let app = launchAppAndOpenCustomLayout()
        chooseMenuItem(option.accessibilityIdentifier, fromCustomizeMenuIn: app)
    }

    // Helpers

    private func launchAppAndOpenCustomLayout() -> XCUIApplication {
        let app = launchAppAndMakeNewDocument()

        let customizeButton = customizeMenuButton(in: app)
        customizeButton.click()

        let customLayoutButton = app.menuItems[
            LayoutSizeOptions.custom.accessibilityIdentifier
        ].firstMatch
        XCTAssertTrue(customLayoutButton.waitForExistence(timeout: 5))
        customLayoutButton.click()

        return app
    }

    private func launchAppAndMakeNewDocument() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestCreateNewDocument"]
        app.launch()

        let newDocumentButton = app.windows.buttons["NewDocumentButton"].firstMatch
        XCTAssertTrue(newDocumentButton.waitForExistence(timeout: 5))
        newDocumentButton.click()

        return app
    }

    private func chooseMenuItem(
        _ accessibilityIdentifier: String,
        fromCustomizeMenuIn app: XCUIApplication
    ) {
        let customizeButton = customizeMenuButton(in: app)
        customizeButton.click()

        let menuItem = app.menuItems[accessibilityIdentifier].firstMatch
        XCTAssertTrue(menuItem.waitForExistence(timeout: 5))
        menuItem.click()
    }

    private func customizeMenuButton(in app: XCUIApplication) -> XCUIElement {
        let button = app.windows.menuButtons[
            LayoutOptionsViewAccessibilityIDs.customizeSettingsButtonAccessibilityIdentifier
        ].firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        return button
    }

    // Launch time
    func testLaunchPerformance() throws {
        let options = XCTMeasureOptions()
        options.iterationCount = 3

        measure(metrics: [XCTApplicationLaunchMetric()], options: options) {
            let app = XCUIApplication()
            app.launchArguments += ["-uiTestCreateNewDocument"]
            app.launch()
        }
    }
}
