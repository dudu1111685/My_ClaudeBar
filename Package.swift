// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ClaudeBar",
    platforms: [
        .linux,
    ],
    products: [
        .executable(name: "claudebar", targets: ["ClaudeBar"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Infrastructure", targets: ["Infrastructure"]),
    ],
    dependencies: [
        // GTK4 Swift bindings
        .package(url: "https://github.com/rhx/SwiftGtk", branch: "main"),
        .package(url: "https://github.com/Kolos65/Mockable.git", from: "0.5.0"),
    ],
    targets: [
        // MARK: - Domain Layer (Rich domain models, business logic, ports)
        // Uses domain-driven terminology: UsageQuota, AIProvider, QuotaMonitor
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Mockable", package: "Mockable"),
            ],
            path: "Sources/Domain",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),

        // MARK: - Infrastructure Layer (Technical implementations)
        // Uses technical terminology: PTYCommandRunner, JSONParser, FileSystem
        .target(
            name: "Infrastructure",
            dependencies: [
                "Domain",
                .product(name: "Mockable", package: "Mockable"),
            ],
            path: "Sources/Infrastructure",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),

        // MARK: - Main Application (GTK4 UI)
        // GTK4 views directly use rich domain models - no ViewModel layer
        .executableTarget(
            name: "ClaudeBar",
            dependencies: [
                "Domain",
                "Infrastructure",
                .product(name: "Gtk", package: "SwiftGtk"),
            ],
            path: "Sources/App",
            exclude: [
                "Info.plist",
                "entitlements.plist",
                "AppIcon.icns",
            ],
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ],
            linkerSettings: [
                .linkedLibrary("gtk-4"),
                .linkedLibrary("glib-2.0"),
                .linkedLibrary("gobject-2.0"),
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "DomainTests",
            dependencies: [
                "Domain",
                .product(name: "Mockable", package: "Mockable"),
            ],
            path: "Tests/DomainTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("Testing"),
                .define("MOCKING"),
            ]
        ),
        .testTarget(
            name: "InfrastructureTests",
            dependencies: [
                "Infrastructure",
                "Domain",
                .product(name: "Mockable", package: "Mockable"),
            ],
            path: "Tests/InfrastructureTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("Testing"),
                .define("MOCKING"),
            ]
        ),
    ]
)
