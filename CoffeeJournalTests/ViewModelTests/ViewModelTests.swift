import XCTest
@testable import CoffeeJournalCore

final class ViewModelTests: XCTestCase {
    func testTastingNoteListViewModelFiltering() async {
        let note1 = TastingNote(
            userId: UUID(),
            beanName: "Ethiopia Yirgacheffe",
            roaster: "Blue Bottle",
            origin: "Ethiopia",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["Floral", "Citrus"]
        )

        let note2 = TastingNote(
            userId: UUID(),
            beanName: "Mandheling Sumatra",
            roaster: "Obscura Coffee",
            origin: "Indonesia",
            roastLevel: "深煎り",
            taste: TasteParameter(acidity: 1, sweetness: 2, bitterness: 5, body: 5, aroma: 3),
            flavorNotes: ["Spicy", "Dark Chocolate"]
        )

        let repo = MockCoffeeRepository(notes: [note1, note2])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        XCTAssertEqual(vm.notes.count, 2)
        XCTAssertEqual(vm.filteredNotes.count, 2)

        // Test Search Filter
        vm.searchQuery = "Ethiopia"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.beanName, "Ethiopia Yirgacheffe")

        // Test Roast Filter
        vm.searchQuery = ""
        vm.selectedRoastFilter = "深煎り"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.beanName, "Mandheling Sumatra")
    }

    func testCreateNoteViewModelValidationAndSave() async {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        // Invalid initially
        XCTAssertFalse(vm.isValid)

        // Set valid name
        vm.beanName = "Guatemala Antigua"
        vm.roaster = "Single O"
        vm.roastLevel = "中煎り"
        vm.toggleFlavorTag("Nutty")
        XCTAssertTrue(vm.isValid)

        let success = await vm.saveNote()
        XCTAssertTrue(success)

        let savedNotes = try? await repo.fetchTastingNotes()
        XCTAssertEqual(savedNotes?.count, 1)
        XCTAssertEqual(savedNotes?.first?.beanName, "Guatemala Antigua")
        XCTAssertTrue(savedNotes?.first?.flavorNotes.contains("Nutty") ?? false)
    }
}
