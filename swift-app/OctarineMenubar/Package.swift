// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OctarineMenubar",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "OctarineMenubar",
            targets: ["OctarineMenubar"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .executableTarget(
            name: "OctarineMenubar",
            dependencies: ["Yams"],
            path: "Sources"
        )
    ]
)