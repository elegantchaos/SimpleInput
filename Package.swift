// swift-tools-version:5.7

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/09/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "SimpleInput",
    platforms: [
        .macCatalyst(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SimpleInput",
            targets: ["SimpleInput"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "SimpleInput",
            dependencies: []),
    ]
)
