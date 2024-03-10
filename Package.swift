// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSDevEx",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "iosdevex", targets: ["XCToolBox"]),
        .library(name: "ToolBoxCore", targets: ["ToolBoxCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut", from: "2.3.0"),
        .package(url: "https://github.com/MobileNativeFoundation/XCLogParser", from: "0.2.38")

    ],
    targets: [
        .executableTarget(
            name: "XCToolBox",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "ToolBoxCore"
            ]
        ),
        .target(
            name: "ToolBoxCore",
            dependencies: [
                "Files",
                "ShellOut",
                "XCLogParser"
            ]
        ),
        .testTarget(
            name: "ToolBoxCoreTests",
            dependencies: ["ToolBoxCore"]
        ),
    ]
)
