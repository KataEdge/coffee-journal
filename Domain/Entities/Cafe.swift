import Foundation

public struct Cafe: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let address: String?
    public let latitude: Double?
    public let longitude: Double?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
    }
}
