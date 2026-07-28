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
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoffeeJournalCore",
            path: ".",
            exclude: [
                "App"
            ],
            sources: [
                "Domain",
                "Core"
            ]
        ),
        .testTarget(
            name: "CoffeeJournalTests",
            dependencies: ["CoffeeJournalCore"],
            path: "CoffeeJournalTests",
            sources: [
                "Mocks",
                "UseCaseTests"
            ]
        ),
    ]
)
