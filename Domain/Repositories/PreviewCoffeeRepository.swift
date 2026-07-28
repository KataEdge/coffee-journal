import Foundation

public final class PreviewCoffeeRepository: CoffeeRepositoryProtocol, @unchecked Sendable {
    public var notes: [TastingNote] = []

    public init(notes: [TastingNote] = []) {
        self.notes = notes
    }

    public func fetchTastingNotes() async throws -> [TastingNote] {
        return notes
    }

    public func fetchTastingNotes(for userId: UUID) async throws -> [TastingNote] {
        return notes.filter { $0.userId == userId }
    }

    public func fetchTastingNote(by id: UUID) async throws -> TastingNote? {
        return notes.first { $0.id == id }
    }

    public func createTastingNote(_ note: TastingNote) async throws -> TastingNote {
        notes.append(note)
        return note
    }

    public func updateTastingNote(_ note: TastingNote) async throws -> TastingNote {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            return note
        }
        return note
    }

    public func deleteTastingNote(id: UUID) async throws {
        notes.removeAll { $0.id == id }
    }
}
