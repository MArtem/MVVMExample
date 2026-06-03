// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppInfrastructure",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(name: "AppNetworking", targets: ["AppNetworking"]),
        .library(name: "AppErrors", targets: ["AppErrors"]),
        .library(name: "AppLocalization", targets: ["AppLocalization"]),
        .library(name: "AppConfiguration", targets: ["AppConfiguration"]),
        .library(name: "AppLogging", targets: ["AppLogging"]),
        .library(name: "AppImageLoading", targets: ["AppImageLoading"])
    ],
    targets: [
        .target(name: "AppErrors"),
        .target(name: "AppLogging"),
        .target(name: "AppConfiguration", dependencies: ["AppLogging"]),
        .target(name: "AppLocalization", dependencies: ["AppErrors"]),
        .target(name: "AppNetworking", dependencies: ["AppErrors", "AppLogging", "AppConfiguration"]),
        .target(name: "AppImageLoading", dependencies: ["AppErrors"]),
        .testTarget(name: "AppConfigurationTests", dependencies: ["AppConfiguration"]),
        .testTarget(name: "AppNetworkingTests", dependencies: ["AppNetworking", "AppErrors", "AppConfiguration", "AppLogging"]),
        .testTarget(name: "AppLocalizationTests", dependencies: ["AppLocalization", "AppErrors"]),
        .testTarget(name: "AppImageLoadingTests", dependencies: ["AppImageLoading", "AppErrors"])
    ]
)
