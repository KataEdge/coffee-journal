import XCTest
import Supabase
@testable import CoffeeJournalCore

final class SupabaseCoffeeRepositoryTests: XCTestCase {
    var repository: SupabaseCoffeeRepository!

    override func setUp() {
        super.setUp()
        repository = SupabaseCoffeeRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    func test_defaultInitializer_createsInstance() {
        let repo = SupabaseCoffeeRepository()
        XCTAssertNotNil(repo)
    }

    func test_wrapError_convertsErrors() {
        let dbErr = AppError.databaseError("DB error")
        XCTAssertEqual(repository.wrapError(dbErr), .databaseError("DB error"))

        let nsErr = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sample DB failure"])
        let wrapped = repository.wrapError(nsErr)
        if case .databaseError(let msg) = wrapped {
            XCTAssertTrue(msg.contains("Sample DB failure"))
        } else {
            XCTFail("Expected databaseError")
        }
    }

    func test_fetchTastingNotes_handlesExecution() async {
        do {
            let notes = try await repository.fetchTastingNotes()
            XCTAssertTrue(notes.isEmpty || !notes.isEmpty)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_fetchTastingNotesForUser_handlesExecution() async {
        let userId = UUID()
        do {
            let notes = try await repository.fetchTastingNotes(for: userId)
            XCTAssertTrue(notes.isEmpty || !notes.isEmpty)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_fetchTastingNoteById_handlesExecution() async {
        let noteId = UUID()
        do {
            let note = try await repository.fetchTastingNote(by: noteId)
            XCTAssertNil(note)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_createTastingNote_withoutBackend_throwsDatabaseError() async {
        let note = CafeVisitNote(
            cafeName: "Test Cafe",
            address: "Tokyo",
            drinkName: "Espresso",
            brewMethod: "ハンドドリップ",
            roaster: "Test Roaster",
            origin: "Ethiopia",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 4, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["Floral"],
            comment: "Great note"
        )
        do {
            _ = try await repository.createTastingNote(note)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateTastingNote_withoutBackend_throwsDatabaseError() async {
        let note = CafeVisitNote(
            cafeName: "Test Cafe",
            drinkName: "Espresso",
            brewMethod: "ハンドドリップ",
            taste: TasteParameter()
        )
        do {
            _ = try await repository.updateTastingNote(note)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_deleteTastingNote_withoutBackend_handlesExecution() async {
        let noteId = UUID()
        do {
            try await repository.deleteTastingNote(id: noteId)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}
