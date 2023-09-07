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
                      url:"https://github.com/cossacklabs/openssl-apple/releases/download/1.1.12201/openssl-static-xcframework.zip",
                      // Run from package directory:
                      // swift package compute-checksum output/openssl-static-xcframework.zip
                      checksum: "a3363e4297428d2497c481791f6ac3c17c118b6829ee6246781efe0a3593ae16"),
    ]
)
