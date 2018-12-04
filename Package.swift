// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "vaporApp",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/validation.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/multipart.git", from: "3.0.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", from: "1.1.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "0.6.2"),
        .package(url: "https://github.com/LiveUI/MailCore.git", from: "0.2.2"),
        .package(url: "https://github.com/MihaelIsaev/FluentQuery.git", from: "0.4.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "Logging", "Validation", "Authentication", "Multipart", "SwiftyBeaverVapor", "FCM", "MailCore", "FluentQuery"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
