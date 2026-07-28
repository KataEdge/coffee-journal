import Foundation

public protocol CoffeeRepositoryProtocol: Sendable {
    func fetchTastingNotes() async throws -> [CafeVisitNote]
    func fetchTastingNotes(for userId: UUID) async throws -> [CafeVisitNote]
    func fetchTastingNote(by id: UUID) async throws -> CafeVisitNote?
    func createTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote
    func updateTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote
    func deleteTastingNote(id: UUID) async throws
}
