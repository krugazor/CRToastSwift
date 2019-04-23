// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// With a lil help from https://badootech.badoo.com/swift-package-manager-builds-ios-frameworks-updated-xcode-10-2-beta-19b3e6741bda

import PackageDescription

let package = Package(
    name: "CRToastSwift",
	platforms: [ .iOS(.v12) ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CRToastSwift",
            targets: ["CRToastSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CRToastSwift",
            dependencies: []),
        .testTarget(
            name: "CRToastSwiftTests",
            dependencies: ["CRToastSwift"]),
    ]
)
