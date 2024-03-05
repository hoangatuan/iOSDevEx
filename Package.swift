// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSDevEx",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "iosdevex", targets: ["iOSDevEx"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "iOSDevEx"
        ),
    ]
)
