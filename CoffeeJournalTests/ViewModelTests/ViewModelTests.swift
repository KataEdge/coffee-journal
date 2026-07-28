import XCTest
@testable import CoffeeJournalCore

final class ViewModelTests: XCTestCase {
    func testTastingNoteListViewModelFiltering() async {
        let note1 = CafeVisitNote(
            userId: UUID(),
            cafeName: "Blue Bottle Coffee 清澄白河",
            address: "東京都江東区平野1-4-8",
            drinkName: "ハンドドリップ エチオピア",
            brewMethod: "ハンドドリップ",
            roaster: "Blue Bottle",
            origin: "Ethiopia",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["Floral", "Citrus"]
        )

        let note2 = CafeVisitNote(
            userId: UUID(),
            cafeName: "STREAMER COFFEE COMPANY 渋谷",
            address: "東京都渋谷区渋谷1-20-28",
            drinkName: "ストリーマーラテ",
            brewMethod: "エスプレッソ・ラテ",
            roaster: "STREAMER COFFEE",
            taste: TasteParameter(acidity: 1, sweetness: 4, bitterness: 4, body: 5, aroma: 4),
            flavorNotes: ["Spicy", "Dark Chocolate"]
        )

        let repo = MockCoffeeRepository(notes: [note1, note2])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        XCTAssertEqual(vm.notes.count, 2)
        XCTAssertEqual(vm.filteredNotes.count, 2)

        // Test Search Filter (by Cafe name)
        vm.searchQuery = "Blue Bottle"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.cafeName, "Blue Bottle Coffee 清澄白河")

        // Test Brew Method Filter
        vm.searchQuery = ""
        vm.selectedBrewMethodFilter = "エスプレッソ・ラテ"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.drinkName, "ストリーマーラテ")
    }

    func testCreateNoteViewModelValidationAndSave() async {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        // Invalid initially (requires cafeName and drinkName)
        XCTAssertFalse(vm.isValid)

        // Set valid cafe and drink
        vm.cafeName = "Fuglen Tokyo"
        vm.address = "渋谷区富ヶ谷"
        vm.drinkName = "エアロプレス ケニア"
        vm.brewMethod = "ハンドドリップ"
        vm.toggleFlavorTag("Nutty")
        XCTAssertTrue(vm.isValid)

        let success = await vm.saveNote()
        XCTAssertTrue(success)

        let savedNotes = try? await repo.fetchTastingNotes()
        XCTAssertEqual(savedNotes?.count, 1)
        XCTAssertEqual(savedNotes?.first?.cafeName, "Fuglen Tokyo")
        XCTAssertEqual(savedNotes?.first?.drinkName, "エアロプレス ケニア")
        XCTAssertTrue(savedNotes?.first?.flavorNotes.contains("Nutty") ?? false)
    }
}
