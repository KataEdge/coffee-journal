import Foundation

public struct UserProfile: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let username: String?
    public let avatarUrl: String?
    public let updatedAt: Date

    public init(id: UUID, username: String? = nil, avatarUrl: String? = nil, updatedAt: Date = Date()) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.updatedAt = updatedAt
    }
}
