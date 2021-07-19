// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharkCardScan",
    platforms: [ .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SharkCardScan",
            targets: ["SharkCardScan"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"), dependencies: [
        .package(   
            name: "SharkUtils",
          url: "https://github.com/gymshark/ios-shark-utils.git",
            .exact("1.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SharkCardScan",
            dependencies: ["SharkUtils"]),
        .testTarget(
            name: "SharkCardScanTests",
            dependencies: ["SharkCardScan"]),
    ]
)
