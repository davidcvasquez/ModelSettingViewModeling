// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ModelSettingViewModeling",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(name: "ModelSettingViewModelingCore", targets: ["ModelSettingViewModelingCore"]),
        .library(name: "ModelSettingViewModeling", targets: ["ModelSettingViewModeling"])
    ],
    dependencies: [
        .package(url: "https://github.com/davidcvasquez/LoggerCategories.git", from: "1.0.0"),
        .package(url: "https://github.com/davidcvasquez/CompactUUID.git", from: "1.1.1"),
        .package(url: "https://github.com/davidcvasquez/NDGeometry", from: "1.3.1"),
        .package(url: "https://github.com/davidcvasquez/ModelSettingsSupport", from: "1.3.0"),
        .package(url: "https://github.com/davidcvasquez/LocalizableStringBundle", from: "1.4.0"),
        // DocC plugin (command plugin that adds `generate-documentation`)
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "ModelSettingViewModelingCore",
            dependencies: [
                .product(name: "LoggerCategories", package: "LoggerCategories"),
                .product(name: "LocalizableStringBundle", package: "LocalizableStringBundle")
            ],
            path: "Sources/ModelSettingViewModelingCore",
            resources: [
                .process("Resources/Strings")
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .swiftLanguageMode(.v5)
            ]
        ),
        .target(
            name: "ModelSettingViewModeling",
            dependencies: [
                "ModelSettingViewModelingCore",
                .product(name: "LoggerCategories", package: "LoggerCategories"),
                .product(name: "CompactUUID", package: "CompactUUID"),
                .product(name: "NDGeometry", package: "NDGeometry"),
                .product(name: "ModelSettingsSupport", package: "ModelSettingsSupport"),
                .product(name: "LocalizableStringBundle", package: "LocalizableStringBundle"),
                .product(name: "LocalizableStringBundleUI", package: "LocalizableStringBundle")
            ],
            path: "Sources/ModelSettingViewModeling",
            resources: [
                .process("Resources/Shaders"),
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self),
                .swiftLanguageMode(.v5)
            ]
        ),
        .testTarget(
            name: "ModelSettingViewModelingTests",
            dependencies: [
                "ModelSettingViewModelingCore",
                "ModelSettingViewModeling",
                .product(name: "LoggerCategories", package: "LoggerCategories"),
                .product(name: "CompactUUID", package: "CompactUUID"),
                .product(name: "NDGeometry", package: "NDGeometry"),
                .product(name: "ModelSettingsSupport", package: "ModelSettingsSupport"),
                .product(name: "LocalizableStringBundle", package: "LocalizableStringBundle"),
                .product(name: "LocalizableStringBundleUI", package: "LocalizableStringBundle")
            ],
            resources: [
                .process("Resources/Strings")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
