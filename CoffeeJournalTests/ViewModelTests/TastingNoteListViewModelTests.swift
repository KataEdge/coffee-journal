import XCTest
@testable import CoffeeJournalCore

final class TastingNoteListViewModelTests: XCTestCase {

    func testTastingNoteListViewModel_filteringByAllFields() async {
        let note1 = CafeVisitNote(
            userId: UUID(),
            cafeName: "Fuglen Tokyo",
            address: "Shibuya Tomigaya",
            drinkName: "Latte",
            brewMethod: "エスプレッソ・ラテ",
            roaster: "Fuglen Roasters",
            origin: "Ethiopia Yirgacheffe",
            taste: TasteParameter(),
            flavorNotes: ["Jasmine", "Citrus"],
            comment: "Amazing floral aroma"
        )

        let note2 = CafeVisitNote(
            userId: UUID(),
            cafeName: "Onibus Coffee",
            address: "Meguro Nakameguro",
            drinkName: "Drip Coffee",
            brewMethod: "ハンドドリップ",
            roaster: "Onibus Roaster",
            origin: "Colombia Huila",
            taste: TasteParameter(),
            flavorNotes: ["Chocolate", "Caramel"],
            comment: "Sweet aftertaste"
        )

        let repo = MockCoffeeRepository(notes: [note1, note2])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        XCTAssertEqual(vm.notes.count, 2)
        XCTAssertEqual(vm.filteredNotes.count, 2)

        // Filter by Address
        vm.searchQuery = "Tomigaya"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.cafeName, "Fuglen Tokyo")

        // Filter by Roaster
        vm.searchQuery = "Onibus Roaster"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.cafeName, "Onibus Coffee")

        // Filter by Origin
        vm.searchQuery = "Ethiopia"
        XCTAssertEqual(vm.filteredNotes.count, 1)

        // Filter by Flavor Note
        vm.searchQuery = "Chocolate"
        XCTAssertEqual(vm.filteredNotes.count, 1)

        // Filter by Comment
        vm.searchQuery = "floral"
        XCTAssertEqual(vm.filteredNotes.count, 1)

        // Filter by Brew Method
        vm.searchQuery = ""
        vm.selectedBrewMethodFilter = "ハンドドリップ"
        XCTAssertEqual(vm.filteredNotes.count, 1)
        XCTAssertEqual(vm.filteredNotes.first?.cafeName, "Onibus Coffee")
    }

    func testTastingNoteListViewModel_filteringWithNilOptionalFields() async {
        let noteWithNils = CafeVisitNote(
            userId: UUID(),
            cafeName: "Simple Cafe",
            address: nil,
            drinkName: "Simple Drink",
            brewMethod: "水出し",
            roaster: nil,
            origin: nil,
            taste: TasteParameter(),
            flavorNotes: [],
            comment: nil
        )

        let repo = MockCoffeeRepository(notes: [noteWithNils])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        vm.searchQuery = "NonExistentTerm"
        XCTAssertEqual(vm.filteredNotes.count, 0)
    }

    func testTastingNoteListViewModel_fetchNotesFailure_setsErrorMessage() async {
        let repo = MockCoffeeRepository()
        repo.shouldFail = true
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()

        XCTAssertTrue(vm.notes.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }

    func testTastingNoteListViewModel_deleteNote_success_removesFromNotes() async {
        let noteId = UUID()
        let note = CafeVisitNote(
            id: noteId,
            userId: UUID(),
            cafeName: "Test Cafe",
            drinkName: "Test Drink",
            brewMethod: "ハンドドリップ",
            taste: TasteParameter()
        )

        let repo = MockCoffeeRepository(notes: [note])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        XCTAssertEqual(vm.notes.count, 1)

        await vm.deleteNote(id: noteId)
        XCTAssertEqual(vm.notes.count, 0)
        XCTAssertNil(vm.errorMessage)
    }

    func testTastingNoteListViewModel_deleteNote_failure_setsErrorMessage() async {
        let noteId = UUID()
        let note = CafeVisitNote(
            id: noteId,
            userId: UUID(),
            cafeName: "Test Cafe",
            drinkName: "Test Drink",
            brewMethod: "ハンドドリップ",
            taste: TasteParameter()
        )

        let repo = MockCoffeeRepository(notes: [note])
        let vm = TastingNoteListViewModel(repository: repo)

        await vm.fetchNotes()
        XCTAssertEqual(vm.notes.count, 1)

        repo.shouldFail = true
        await vm.deleteNote(id: noteId)

        XCTAssertEqual(vm.notes.count, 1)
        XCTAssertNotNil(vm.errorMessage)
    }
}
