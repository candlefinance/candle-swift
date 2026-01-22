// swift-tools-version: 6.0
import Foundation
import PackageDescription

let xcFrameworkNames: [String] = [
    "Candle", "Candle_AtomicsShims", "Candle_CWASI", "Candle_NIOBase64", "Candle_NIODataStructures",
    "Candle_NumericsShims", "CandleAlgorithms", "CandleAsyncAlgorithms", "CandleAsyncHTTPClient",
    "CandleAtomics", "CandleCachedAsyncImage", "CandleCAsyncHTTPClient", "CandleCCryptoBoringSSL",
    "CandleCCryptoBoringSSLShims", "CandleCNIOAtomics", "CandleCNIOBoringSSL",
    "CandleCNIOBoringSSLShims", "CandleCNIODarwin", "CandleCNIOExtrasZlib", "CandleCNIOLinux",
    "CandleCNIOLLHTTP", "CandleCNIOSHA1", "CandleCNIOWASI", "CandleCNIOWindows",
    "CandleConcurrencyHelpers", "CandleCoreMetrics", "CandleCrypto", "CandleCryptoBoringWrapper",
    "CandleDequeModule", "CandleHTTPTypes", "CandleInstrumentation",
    "CandleInternalCollectionsUtilities", "CandleLogging", "CandleMetrics", "CandleNIO",
    "CandleNIOConcurrencyHelpers", "CandleNIOCore", "CandleNIOEmbedded",
    "CandleNIOFoundationCompat", "CandleNIOHPACK", "CandleNIOHTTP1", "CandleNIOHTTP2",
    "CandleNIOHTTPCompression", "CandleNIOPosix", "CandleNIOSOCKS", "CandleNIOSSL", "CandleNIOTLS",
    "CandleNIOTransportServices", "CandleNIOWebSocket", "CandleOpenAPIRuntime",
    "CandleOpenAPIURLSession", "CandleOrderedCollections", "CandleOTel", "CandleRealModule",
    "CandleServiceContextModule", "CandleServiceLifecycle", "CandleSFSafeSymbols",
    "CandleSwiftProtobuf", "CandleTracing", "CandleUnixSignals", "CandleW3CTraceContext",
]

let package = Package(
    name: "Candle",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Candle", targets: ["CandlePublic"])],
    targets: [
        .target(
            name: "CandlePublic",
            dependencies: xcFrameworkNames.map { Target.Dependency.target(name: $0) },
            linkerSettings: [.linkedFramework("Network")]
        )
    ]
        + xcFrameworkNames.map { name in
            Target.binaryTarget(name: name, path: "./XCFrameworks/\(name).xcframework")
        }
)
