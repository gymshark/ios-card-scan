// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharkCardScan",
    platforms: [ .iOS(.v13)],
    products: [
        .library(
            name: "SharkCardScan",
            targets: ["SharkCardScan"]),
    ],
    dependencies: [
        .package(
            name: "SharkUtils",
          url: "https://github.com/gymshark/ios-shark-utils.git",
            .exact("1.0.5")),
    ],
    targets: [
        .target(
            name: "SharkCardScan",
            dependencies: ["SharkUtils"],
            path: "Sources",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "SharkCardScanTests",
            dependencies: ["SharkCardScan"]),
    ]
)
