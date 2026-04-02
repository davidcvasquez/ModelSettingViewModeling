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
import OrderedCollections
import CompactUUID
import NDGeometry
import ModelSettingsSupport
import ModelSettingViewModeling

/// Test model setting properties, indexed as model settings for use with Codable and runtime settings management.
@ModelSettingProperties(.testSettingsID)
nonisolated public struct TestModelSettingProperties: Codable, Sendable, Equatable, Hashable {
    @ModelSettingID(.testSizeID)
    public var testSize: NDSize = NDSize(width: 0.32, height: 0.32)

    @ModelSettingID(.testMaintainSizeRatioID)
    public var testMaintainSizeRatio: Bool = true

    @ModelSettingID(.testSizeRatioID)
    public var testSizeRatio: NDFloat = .one

    @ModelSettingID(.testSizeFaderID)
    public var testSizeFader: NDFloat = .one

    @ModelSettingID(.testRotationID)
    public var testRotation: NDAngle = .zero

    @ModelSettingID(.testShearXID)
    public var testShearX: NDAngle = .zero

    @ModelSettingID(.testShearYID)
    public var testShearY: NDAngle = .zero

    @ModelSettingID(.testCountID)
    public var testCount: Int = 1
}

nonisolated public extension ModelSetting.ID {
    static let testSettingsID            = ModelSetting.ID("TSG.qtVgBcj4LGwFquLYeewT1a")
    static let testSizeID                = ModelSetting.ID("TSZ.fd3cKtSF7yiDThzwu1Cigs")
    static let testWidthID               = ModelSetting.ID("TWD.qDxfJHuf8WxjpYHzLgTFCc")
    static let testHeightID              = ModelSetting.ID("THT.8b7wTEHVnm6axMA6KHCT41")
    static let testMaintainSizeRatioID   = ModelSetting.ID("TMS.7VDrp3nGMyeyP27HZsNhdo")
    static let testSizeRatioID           = ModelSetting.ID("TSR.bbZMVRqHBPiKBWFkJr1j1L")
    static let testSizeFaderID           = ModelSetting.ID("TSF.Tw4PdZFva1HS8NP7EXiNPG")
    static let testRotationID            = ModelSetting.ID("TRT.JkYknXFB9KCjfoKZmwBB1q")
    static let testShearXID              = ModelSetting.ID("TSX.dVVFtcPDn1BnvaPPwgUSeW")
    static let testShearYID              = ModelSetting.ID("TSY.82NqHAkx6UpGxkfJ9Pt73L")
    static let testCountID               = ModelSetting.ID("TCT.3r9dqQg6hF7LhwLM8L7vN")
}
