import PackageDescription

let package = Package(
    name: "VideoPlayerView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "VideoPlayerView",
            targets: ["VideoPlayerView"]),
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "VideoPlayerView",
            dependencies: [],
            path: "VideoPlayerView")
    ]
)
