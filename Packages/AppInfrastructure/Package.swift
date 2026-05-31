// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppInfrastructure",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "AppNetworking", targets: ["AppNetworking"]),
        .library(name: "AppErrors", targets: ["AppErrors"]),
        .library(name: "AppLocalization", targets: ["AppLocalization"]),
        .library(name: "AppConfiguration", targets: ["AppConfiguration"]),
        .library(name: "AppLogging", targets: ["AppLogging"])
    ],
    targets: [
        .target(name: "AppErrors"),
        .target(name: "AppLogging"),
        .target(name: "AppConfiguration", dependencies: ["AppLogging"]),
        .target(name: "AppLocalization"),
        .target(name: "AppNetworking", dependencies: ["AppErrors", "AppLogging", "AppConfiguration"])
    ]
)
