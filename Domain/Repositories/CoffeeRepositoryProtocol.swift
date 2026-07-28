import Foundation

public protocol CoffeeRepositoryProtocol: Sendable {
    func fetchTastingNotes() async throws -> [TastingNote]
    func fetchTastingNotes(for userId: UUID) async throws -> [TastingNote]
    func fetchTastingNote(by id: UUID) async throws -> TastingNote?
    func createTastingNote(_ note: TastingNote) async throws -> TastingNote
    func updateTastingNote(_ note: TastingNote) async throws -> TastingNote
    func deleteTastingNote(id: UUID) async throws
}
