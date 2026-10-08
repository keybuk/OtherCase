// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "OtherCase",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "OtherCase",
            targets: ["OtherCase"],
        ),
        .executable(
            name: "OtherCaseClient",
            targets: ["OtherCaseClient"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
    ],
    targets: [
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "OtherCaseMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "OtherCase",
            dependencies: ["OtherCaseMacros"],
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "OtherCaseClient",
            dependencies: ["OtherCase"],
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "OtherCaseTests",
            dependencies: [
                "OtherCaseMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
        ),
    ],
)
