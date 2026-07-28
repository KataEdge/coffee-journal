import Foundation

public struct CafeVisitNote: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let cafeName: String
    public let address: String?
    public let latitude: Double?
    public let longitude: Double?
    public let drinkName: String
    public let brewMethod: String
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
        userId: UUID = UUID(),
        cafeName: String,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        drinkName: String,
        brewMethod: String = "ハンドドリップ",
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
        self.cafeName = cafeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.drinkName = drinkName
        self.brewMethod = brewMethod
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
