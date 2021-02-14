// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "EPubGen",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "epubgen-tool", targets: ["epubgen-tool"]),
        .library(name: "EPubGen", targets: ["EPubGen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iwasrobbed/Down.git", from: "0.9.4"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "EPubGen",
            dependencies: [
                .product(name: "Down", package: "Down"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            ],
            path: "epubgen",
            exclude: ["EpubPacker/ZipZapEpubPacker.swift"]),
        .target(
            name: "epubgen-tool",
            dependencies: [
                .target(name: "EPubGen")
            ],
            path: "epubgen-tool"),
    ],
    cxxLanguageStandard: .cxx1z
)
