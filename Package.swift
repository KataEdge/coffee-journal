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
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
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
                "CoffeeJournalTests"
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
