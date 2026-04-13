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
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestCreateNewDocument"]
        app.launch()
        print(app.debugDescription)
        let newDocumentButton = app.windows.buttons["NewDocumentButton"].firstMatch
        XCTAssertTrue(newDocumentButton.waitForExistence(timeout: 5))
        newDocumentButton.click()
    }

    func testNoStepperOption() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestCreateNewDocument"]
        app.launch()
        print(app.debugDescription)
        let newDocumentButton = app.windows.buttons["NewDocumentButton"].firstMatch
        XCTAssertTrue(newDocumentButton.waitForExistence(timeout: 5))
        newDocumentButton.click()

        let customizeButton = app.windows.menuButtons[
            LayoutOptionsViewAccessibilityIDs.customizeSettingsButtonAccessibilityIdentifier].firstMatch
        XCTAssertTrue(customizeButton.waitForExistence(timeout: 5))
        customizeButton.click()

        let customLayoutButton = app.menuItems[LayoutSizeOptions.custom.accessibilityIdentifier].firstMatch
        XCTAssertTrue(customLayoutButton.waitForExistence(timeout: 5))
        customLayoutButton.click()

        customizeButton.click()

        let noStepperButton = app.menuItems[StepperOptions.noStepper.accessibilityIdentifier].firstMatch
        XCTAssertTrue(noStepperButton.waitForExistence(timeout: 5))
        noStepperButton.click()
    }

    func testSmallStepperOption() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestCreateNewDocument"]
        app.launch()
        print(app.debugDescription)
        let newDocumentButton = app.windows.buttons["NewDocumentButton"].firstMatch
        XCTAssertTrue(newDocumentButton.waitForExistence(timeout: 5))
        newDocumentButton.click()

        let customizeButton = app.windows.menuButtons[
            LayoutOptionsViewAccessibilityIDs.customizeSettingsButtonAccessibilityIdentifier].firstMatch
        XCTAssertTrue(customizeButton.waitForExistence(timeout: 5))
        customizeButton.click()

        let customLayoutButton = app.menuItems[LayoutSizeOptions.custom.accessibilityIdentifier].firstMatch
        XCTAssertTrue(customLayoutButton.waitForExistence(timeout: 5))
        customLayoutButton.click()

        customizeButton.click()

        let smallStepperButton = app.menuItems[StepperOptions.smallStepper.accessibilityIdentifier].firstMatch
        XCTAssertTrue(smallStepperButton.waitForExistence(timeout: 5))
        smallStepperButton.click()
    }

    func testLargeStepperOption() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments += ["-uiTestCreateNewDocument"]
        app.launch()
        print(app.debugDescription)
        let newDocumentButton = app.windows.buttons["NewDocumentButton"].firstMatch
        XCTAssertTrue(newDocumentButton.waitForExistence(timeout: 5))
        newDocumentButton.click()

        let customizeButton = app.windows.menuButtons[
            LayoutOptionsViewAccessibilityIDs.customizeSettingsButtonAccessibilityIdentifier].firstMatch
        XCTAssertTrue(customizeButton.waitForExistence(timeout: 5))
        customizeButton.click()

        let customLayoutButton = app.menuItems[LayoutSizeOptions.custom.accessibilityIdentifier].firstMatch
        XCTAssertTrue(customLayoutButton.waitForExistence(timeout: 5))
        customLayoutButton.click()

        customizeButton.click()

        let largeStepperButton = app.menuItems[StepperOptions.largeStepper.accessibilityIdentifier].firstMatch
        XCTAssertTrue(largeStepperButton.waitForExistence(timeout: 5))
        largeStepperButton.click()
    }

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
