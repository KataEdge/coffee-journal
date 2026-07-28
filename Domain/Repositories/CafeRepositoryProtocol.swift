import Foundation

public protocol CafeRepositoryProtocol: Sendable {
    func fetchCafes() async throws -> [Cafe]
    func fetchCafe(by id: UUID) async throws -> Cafe?
    func createCafe(_ cafe: Cafe) async throws -> Cafe
    func searchCafes(query: String) async throws -> [Cafe]
}
