import XCTest
@testable import CoffeeJournalCore

final class CoffeeMapViewModelTests: XCTestCase {
    func testNotesWithLocationFiltering() async {
        let noteWithLoc = CafeVisitNote(
            cafeName: "Map Cafe",
            latitude: 35.6811,
            longitude: 139.7997,
            drinkName: "Latte"
        )
        let noteWithoutLoc = CafeVisitNote(
            cafeName: "No Location Cafe",
            latitude: nil,
            longitude: nil,
            drinkName: "Drip"
        )
        let repository = PreviewCoffeeRepository(notes: [noteWithLoc, noteWithoutLoc])
        let viewModel = CoffeeMapViewModel(repository: repository)

        await viewModel.fetchNotes()

        XCTAssertEqual(viewModel.notes.count, 2)
        XCTAssertEqual(viewModel.notesWithLocation.count, 1)
        XCTAssertEqual(viewModel.notesWithLocation.first?.cafeName, "Map Cafe")
    }

    func testSelectNoteUpdatesSelectedNoteState() {
        let note = CafeVisitNote(
            cafeName: "Map Cafe",
            latitude: 35.6811,
            longitude: 139.7997,
            drinkName: "Latte"
        )
        let repository = PreviewCoffeeRepository(notes: [note])
        let viewModel = CoffeeMapViewModel(repository: repository)

        XCTAssertNil(viewModel.selectedNote)

        viewModel.selectNote(note)
        XCTAssertEqual(viewModel.selectedNote?.id, note.id)

        viewModel.selectNote(nil)
        XCTAssertNil(viewModel.selectedNote)
    }
}
