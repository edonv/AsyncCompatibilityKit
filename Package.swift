// swift-tools-version:5.7

/**
*  AsyncCompatibilityKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import PackageDescription

let package = Package(
    name: "AsyncCompatibilityKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AsyncCompatibilityKit",
            targets: ["AsyncCompatibilityKit"]
        )
    ],
    targets: [
        .target(
            name: "AsyncCompatibilityKit",
            resources: [.copy("../PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "AsyncCompatibilityKitTests",
            dependencies: ["AsyncCompatibilityKit"],
            path: "Tests"
        )
    ]
)
