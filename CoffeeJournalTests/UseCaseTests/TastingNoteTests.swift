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
        let note = TastingNote(
            userId: UUID(),
            beanName: "Ethiopia Yirgacheffe",
            roaster: "Coffee Roasters",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5)
        )

        let created = try await repo.createTastingNote(note)
        XCTAssertEqual(created.beanName, "Ethiopia Yirgacheffe")

        let notes = try await repo.fetchTastingNotes()
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.id, note.id)
    }
}
