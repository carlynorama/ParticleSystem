// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ParticleSystem",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ParticleSystem",
            targets: ["ParticleSystem"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //.package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        //.package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ParticleSystem",
            //dependencies: [.product(name: "Algorithms", package: "swift-algorithms")]),
            dependencies: []),//dependencies: [.product(name: "Numerics", package: "swift-numerics")]),
        .testTarget(
            name: "ParticleSystemTests",
            dependencies: ["ParticleSystem"]),
    ]
)
