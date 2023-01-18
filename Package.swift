// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "JSKit",
            targets: ["JSKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/js-play/JavaScriptCoreExt.git", revision: "1e6355e865c2fbbdcc6d96e0eb2419cee1fcded9")
    ],
    targets: [
        .target(
            name: "JSKit",
            dependencies: [.product(name: "JavaScriptCoreExt", package: "JavaScriptCoreExt")]),
        .testTarget(
            name: "JSKitTests",
            dependencies: ["JSKit"]),
    ]
)
