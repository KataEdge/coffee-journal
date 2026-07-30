import Foundation

public struct ProfileDTO: Codable, Sendable {
    public let id: UUID
    public let username: String?
    public let avatarUrl: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case avatarUrl = "avatar_url"
        case updatedAt = "updated_at"
    }

    public init(id: UUID, username: String? = nil, avatarUrl: String? = nil, updatedAt: String? = ISO8601DateFormatter().string(from: Date())) {
        self.id = id
        self.username = username
        self.avatarUrl = avatarUrl
        self.updatedAt = updatedAt
    }

    public init(from domain: UserProfile) {
        self.id = domain.id
        self.username = domain.username
        self.avatarUrl = domain.avatarUrl
        self.updatedAt = ISO8601DateFormatter().string(from: domain.updatedAt)
    }

    public func toDomain() -> UserProfile {
        UserProfile(
            id: id,
            username: username,
            avatarUrl: avatarUrl,
            updatedAt: Date()
        )
    }
}
