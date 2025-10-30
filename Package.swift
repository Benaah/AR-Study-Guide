// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ARStudyGuide",
    platforms: [
        .iOS(.v15)  // Updated for Object Capture API
    ],
    products: [
        .executable(name: "ARStudyGuide", targets: ["ARStudyGuide"]),
    ],
    dependencies: [
        // Add any dependencies here
    ],
    targets: [
        .executableTarget(
            name: "ARStudyGuide",
            dependencies: []
        ),
        .testTarget(
            name: "ARStudyGuideTests",
            dependencies: ["ARStudyGuide"]
        ),
    ]
)