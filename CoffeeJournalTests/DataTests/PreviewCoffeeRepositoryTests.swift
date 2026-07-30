import XCTest
@testable import CoffeeJournalCore

final class PreviewCoffeeRepositoryTests: XCTestCase {

    func test_previewCoffeeRepository_sample_and_fetch() async throws {
        let repo = PreviewCoffeeRepository.sample
        let notes = try await repo.fetchTastingNotes()

        XCTAssertEqual(notes.count, 3)
        XCTAssertEqual(notes.first?.cafeName, "Blue Bottle Coffee 清澄白河フラッグシップカフェ")
    }

    func test_previewCoffeeRepository_fetchForUser() async throws {
        let noteId = UUID()
        let userId = UUID()
        let note = CafeVisitNote(id: noteId, userId: userId, cafeName: "User Cafe", drinkName: "Drip")
        let repo = PreviewCoffeeRepository(notes: [note])

        let userNotes = try await repo.fetchTastingNotes(for: userId)
        XCTAssertEqual(userNotes.count, 1)

        let otherUserNotes = try await repo.fetchTastingNotes(for: UUID())
        XCTAssertTrue(otherUserNotes.isEmpty)
    }

    func test_previewCoffeeRepository_fetchById() async throws {
        let noteId = UUID()
        let note = CafeVisitNote(id: noteId, cafeName: "Cafe ID Test", drinkName: "Latte")
        let repo = PreviewCoffeeRepository(notes: [note])

        let found = try await repo.fetchTastingNote(by: noteId)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.cafeName, "Cafe ID Test")

        let notFound = try await repo.fetchTastingNote(by: UUID())
        XCTAssertNil(notFound)
    }

    func test_previewCoffeeRepository_createUpdateDelete() async throws {
        let repo = PreviewCoffeeRepository()
        let note = CafeVisitNote(cafeName: "New Cafe", drinkName: "New Drink")

        let created = try await repo.createTastingNote(note)
        XCTAssertEqual(created.cafeName, "New Cafe")

        let updatedNote = CafeVisitNote(id: created.id, userId: created.userId, cafeName: "Updated Cafe Name", drinkName: "New Drink")
        let updated = try await repo.updateTastingNote(updatedNote)
        XCTAssertEqual(updated.cafeName, "Updated Cafe Name")

        let nonExistentNote = CafeVisitNote(id: UUID(), cafeName: "Ghost Cafe", drinkName: "Water")
        _ = try await repo.updateTastingNote(nonExistentNote)

        try await repo.deleteTastingNote(id: created.id)
        let emptyNotes = try await repo.fetchTastingNotes()
        XCTAssertTrue(emptyNotes.isEmpty)
    }
}
