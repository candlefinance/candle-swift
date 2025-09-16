// swift-tools-version: 6.0
import Foundation
import PackageDescription

let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let xcFrameworksDirectory = packageDirectory.appendingPathComponent(
    "XCFrameworks",
    isDirectory: true
)

let xcFrameworkPaths: [URL]
do {
    xcFrameworkPaths = try FileManager.default.contentsOfDirectory(
        at: xcFrameworksDirectory,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
    )
} catch {
    fatalError(
        "Failed to read contents of XCFrameworks directory at path: \(xcFrameworksDirectory.path)"
    )
}

let xcFrameworkNames = xcFrameworkPaths.map { $0.deletingPathExtension().lastPathComponent }
    .sorted()

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
