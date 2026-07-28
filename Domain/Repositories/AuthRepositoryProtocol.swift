import Foundation

public protocol AuthRepositoryProtocol: Sendable {
    func currentUserProfile() async throws -> UserProfile?
    func signInAnonymously() async throws -> UserProfile
    func signOut() async throws
}
