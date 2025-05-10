// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Candle",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "Candle",
            targets: ["CandlePublic"]
        )
    ],
    targets: [
        .target(
            name: "CandlePublic",
            dependencies: [
                "Atomics", "CNIOAtomics", "CNIOBoringSSL", "CNIOBoringSSLShims", "CNIODarwin",
                "CNIOLLHTTP", "CNIOLinux", "CNIOSHA1", "CNIOWASI", "CNIOWindows", "Candle",
                "DequeModule", "HTTPTypes", "InternalCollectionsUtilities", "NIO",
                "NIOConcurrencyHelpers", "NIOCore", "NIOEmbedded", "NIOFoundationCompat",
                "NIOHTTP1", "NIOPosix", "NIOSSL", "NIOTLS", "NIOTransportServices", "NIOWebSocket",
                "OpenAPIRuntime", "OpenAPIURLSession", "SwiftSecurity", "_AtomicsShims",
                "_NIOBase64", "_NIODataStructures",
            ],
            linkerSettings: [
                .linkedFramework("Network")
            ]
        ),
        .binaryTarget(name: "Atomics", path: "./XCFrameworks/Atomics.xcframework"),
        .binaryTarget(name: "CNIOAtomics", path: "./XCFrameworks/CNIOAtomics.xcframework"),
        .binaryTarget(name: "CNIOBoringSSL", path: "./XCFrameworks/CNIOBoringSSL.xcframework"),
        .binaryTarget(
            name: "CNIOBoringSSLShims", path: "./XCFrameworks/CNIOBoringSSLShims.xcframework"),
        .binaryTarget(name: "CNIODarwin", path: "./XCFrameworks/CNIODarwin.xcframework"),
        .binaryTarget(name: "CNIOLLHTTP", path: "./XCFrameworks/CNIOLLHTTP.xcframework"),
        .binaryTarget(name: "CNIOLinux", path: "./XCFrameworks/CNIOLinux.xcframework"),
        .binaryTarget(name: "CNIOSHA1", path: "./XCFrameworks/CNIOSHA1.xcframework"),
        .binaryTarget(name: "CNIOWASI", path: "./XCFrameworks/CNIOWASI.xcframework"),
        .binaryTarget(name: "CNIOWindows", path: "./XCFrameworks/CNIOWindows.xcframework"),
        .binaryTarget(name: "Candle", path: "./XCFrameworks/Candle.xcframework"),
        .binaryTarget(name: "DequeModule", path: "./XCFrameworks/DequeModule.xcframework"),
        .binaryTarget(name: "HTTPTypes", path: "./XCFrameworks/HTTPTypes.xcframework"),
        .binaryTarget(
            name: "InternalCollectionsUtilities",
            path: "./XCFrameworks/InternalCollectionsUtilities.xcframework"),
        .binaryTarget(name: "NIO", path: "./XCFrameworks/NIO.xcframework"),
        .binaryTarget(
            name: "NIOConcurrencyHelpers", path: "./XCFrameworks/NIOConcurrencyHelpers.xcframework"),
        .binaryTarget(name: "NIOCore", path: "./XCFrameworks/NIOCore.xcframework"),
        .binaryTarget(name: "NIOEmbedded", path: "./XCFrameworks/NIOEmbedded.xcframework"),
        .binaryTarget(
            name: "NIOFoundationCompat", path: "./XCFrameworks/NIOFoundationCompat.xcframework"),
        .binaryTarget(name: "NIOHTTP1", path: "./XCFrameworks/NIOHTTP1.xcframework"),
        .binaryTarget(name: "NIOPosix", path: "./XCFrameworks/NIOPosix.xcframework"),
        .binaryTarget(name: "NIOSSL", path: "./XCFrameworks/NIOSSL.xcframework"),
        .binaryTarget(name: "NIOTLS", path: "./XCFrameworks/NIOTLS.xcframework"),
        .binaryTarget(
            name: "NIOTransportServices", path: "./XCFrameworks/NIOTransportServices.xcframework"),
        .binaryTarget(name: "NIOWebSocket", path: "./XCFrameworks/NIOWebSocket.xcframework"),
        .binaryTarget(name: "OpenAPIRuntime", path: "./XCFrameworks/OpenAPIRuntime.xcframework"),
        .binaryTarget(
            name: "OpenAPIURLSession", path: "./XCFrameworks/OpenAPIURLSession.xcframework"),
        .binaryTarget(name: "SwiftSecurity", path: "./XCFrameworks/SwiftSecurity.xcframework"),
        .binaryTarget(name: "_AtomicsShims", path: "./XCFrameworks/_AtomicsShims.xcframework"),
        .binaryTarget(name: "_NIOBase64", path: "./XCFrameworks/_NIOBase64.xcframework"),
        .binaryTarget(
            name: "_NIODataStructures", path: "./XCFrameworks/_NIODataStructures.xcframework"),
    ]
)
