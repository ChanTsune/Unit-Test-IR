// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "utir-swift",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // (SwiftSyntax)[https://github.com/apple/swift-syntax]
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50300.0")),
        // (SwiftFormat)[https://github.com/apple/swift-format]
        .package(name: "swift-format", url: "https://github.com/apple/swift-format.git", .exact("0.50300.0")),
        // (Yams)[https://github.com/jpsim/Yams]
        .package(name: "Yams", url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/ChanTsune/SwiftyPyString.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "utir-swift",
            dependencies: [
                "SwiftSyntax",
                .product(name: "SwiftSyntaxBuilder", package: "SwiftSyntax"),
                "Yams",
                .product(name: "SwiftFormat", package: "swift-format"),
                "SwiftyPyString",
            ]
        ),
        .testTarget(
            name: "utir-swiftTests",
            dependencies: ["utir-swift"]
        ),
    ]
)
