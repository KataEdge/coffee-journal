import Foundation
@testable import CoffeeJournalCore


public final class MockCoffeeRepository: CoffeeRepositoryProtocol, @unchecked Sendable {
    public var notes: [TastingNote] = []
    public var shouldReturnError: Error?

    public init(notes: [TastingNote] = []) {
        self.notes = notes
    }

    public func fetchTastingNotes() async throws -> [TastingNote] {
        if let error = shouldReturnError { throw error }
        return notes
    }

    public func fetchTastingNotes(for userId: UUID) async throws -> [TastingNote] {
        if let error = shouldReturnError { throw error }
        return notes.filter { $0.userId == userId }
    }

    public func fetchTastingNote(by id: UUID) async throws -> TastingNote? {
        if let error = shouldReturnError { throw error }
        return notes.first { $0.id == id }
    }

    public func createTastingNote(_ note: TastingNote) async throws -> TastingNote {
        if let error = shouldReturnError { throw error }
        notes.append(note)
        return note
    }

    public func updateTastingNote(_ note: TastingNote) async throws -> TastingNote {
        if let error = shouldReturnError { throw error }
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            return note
        }
        throw AppError.databaseError("Note not found")
    }

    public func deleteTastingNote(id: UUID) async throws {
        if let error = shouldReturnError { throw error }
        notes.removeAll { $0.id == id }
    }
}
