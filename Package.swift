// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cl-openssl",
    products: [
        .library(
            name: "cl-openssl",
            targets: ["openssl"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(name: "openssl",
                      // update version in URL path
                      url:"https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12101/openssl-static-xcframework.zip",
                      // Run from package directory:
                      // swift package compute-checksum output/openssl-static-xcframework.zip
                      checksum: "2a2023e200e3472cb6b06ca42a5903e66b567e223d8b540ccb3767fa61abf62f"),
    ]
)
