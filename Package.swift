// swift-tools-version: 6.0
import Foundation
import PackageDescription

let xcFrameworkNames: [String] = [
    "_AtomicsShims", "_CWASI", "_NIOBase64", "_NIODataStructures", "_NumericsShims", "Algorithms",
    "AsyncAlgorithms", "AsyncHTTPClient", "Atomics", "Candle", "CandleSwiftProtobuf",
    "CAsyncHTTPClient", "CCryptoBoringSSL", "CCryptoBoringSSLShims", "CNIOAtomics", "CNIOBoringSSL",
    "CNIOBoringSSLShims", "CNIODarwin", "CNIOExtrasZlib", "CNIOLinux", "CNIOLLHTTP", "CNIOSHA1",
    "CNIOWASI", "CNIOWindows", "ConcurrencyHelpers", "CoreMetrics", "Crypto", "CryptoBoringWrapper",
    "DequeModule", "HTTPTypes", "Instrumentation", "InternalCollectionsUtilities", "Logging",
    "Metrics", "NIO", "NIOConcurrencyHelpers", "NIOCore", "NIOEmbedded", "NIOFoundationCompat",
    "NIOHPACK", "NIOHTTP1", "NIOHTTP2", "NIOHTTPCompression", "NIOPosix", "NIOSOCKS", "NIOSSL",
    "NIOTLS", "NIOTransportServices", "NIOWebSocket", "OpenAPIRuntime", "OpenAPIURLSession",
    "OrderedCollections", "OTel", "RealModule", "ServiceContextModule", "ServiceLifecycle",
    "Tracing", "UnixSignals", "W3CTraceContext",
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
