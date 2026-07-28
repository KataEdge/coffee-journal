import Foundation

public struct TastingNote: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let cafeId: UUID?
    public let beanName: String
    public let roaster: String?
    public let origin: String?
    public let roastLevel: String?
    public let taste: TasteParameter
    public let flavorNotes: [String]
    public let imageUrls: [String]
    public let comment: String?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        userId: UUID,
        cafeId: UUID? = nil,
        beanName: String,
        roaster: String? = nil,
        origin: String? = nil,
        roastLevel: String? = nil,
        taste: TasteParameter = TasteParameter(),
        flavorNotes: [String] = [],
        imageUrls: [String] = [],
        comment: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.cafeId = cafeId
        self.beanName = beanName
        self.roaster = roaster
        self.origin = origin
        self.roastLevel = roastLevel
        self.taste = taste
        self.flavorNotes = flavorNotes
        self.imageUrls = imageUrls
        self.comment = comment
        self.createdAt = createdAt
    }
}
