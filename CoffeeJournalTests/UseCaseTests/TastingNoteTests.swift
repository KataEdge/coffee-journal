import XCTest
@testable import CoffeeJournalCore

final class TastingNoteTests: XCTestCase {
    func testTasteParameterInitializationClampsValues() {
        let taste = TasteParameter(acidity: 10, sweetness: -2, bitterness: 4, body: 5, aroma: 1)
        XCTAssertEqual(taste.acidity, 5)
        XCTAssertEqual(taste.sweetness, 1)
        XCTAssertEqual(taste.bitterness, 4)
        XCTAssertEqual(taste.body, 5)
        XCTAssertEqual(taste.aroma, 1)
    }

    func testMockCoffeeRepositoryCreateAndFetch() async throws {
        let repo = MockCoffeeRepository()
        let note = CafeVisitNote(
            userId: UUID(),
            cafeName: "Blue Bottle Coffee 清澄白河",
            address: "東京都江東区平野1-4-8",
            drinkName: "シングルオリジン ハンドドリップ",
            brewMethod: "ハンドドリップ",
            roaster: "Blue Bottle Coffee",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5)
        )

        let created = try await repo.createTastingNote(note)
        XCTAssertEqual(created.cafeName, "Blue Bottle Coffee 清澄白河")
        XCTAssertEqual(created.drinkName, "シングルオリジン ハンドドリップ")

        let notes = try await repo.fetchTastingNotes()
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.id, note.id)
    }
}
