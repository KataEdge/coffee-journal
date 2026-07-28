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
    dependencies: [],
    targets: [
        .target(
            name: "CoffeeJournalCore",
            path: ".",
            exclude: [
                "App",
                "CoffeeJournalTests"
            ],
            sources: [
                "Domain",
                "Presentation",
                "Core"
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
