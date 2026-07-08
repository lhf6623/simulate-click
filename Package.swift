// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SimulateClick",
    platforms: [.macOS(.v13)],
    targets: [
        .target(
            name: "SimulateClickCore",
            path: "Sources/SimulateClickCore"
        ),
        .executableTarget(
            name: "SimulateClickApp",
            dependencies: ["SimulateClickCore"],
            path: "Sources/SimulateClickApp"
        ),
        .testTarget(
            name: "SimulateClickCoreTests",
            dependencies: ["SimulateClickCore"],
            path: "Tests/SimulateClickCoreTests"
        ),
    ]
)
