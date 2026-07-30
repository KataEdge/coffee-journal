// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CoffeeJournal",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoffeeJournalCore",
            targets: ["CoffeeJournalCore"]
        ),
        .executable(
            name: "CoffeeJournalApp",
            targets: ["CoffeeJournalApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", exact: "2.24.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.4.2")
    ],
    targets: [
        .target(
            name: "CoffeeJournalCore",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: ".",
            exclude: [
                "App",
                "CoffeeJournalTests",
                "Secrets.sample.plist",
                "scripts",
                ".githooks",
                "build"
            ],
            sources: [
                "Domain",
                "Presentation",
                "Core",
                "Data"
            ]
        ),
        .executableTarget(
            name: "CoffeeJournalApp",
            dependencies: ["CoffeeJournalCore"],
            path: "App"
        ),
        .testTarget(
            name: "CoffeeJournalTests",
            dependencies: ["CoffeeJournalCore"],
            path: "CoffeeJournalTests"
        ),
    ]
)
