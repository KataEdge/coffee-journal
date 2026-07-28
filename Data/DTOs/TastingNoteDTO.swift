import Foundation

public struct TastingNoteDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let cafeId: UUID?
    public let cafeName: String?
    public let address: String?
    public let latitude: Double?
    public let longitude: Double?
    public let beanName: String
    public let brewMethod: String?
    public let roaster: String?
    public let origin: String?
    public let roastLevel: String?
    public let acidity: Int
    public let sweetness: Int
    public let bitterness: Int
    public let body: Int
    public let aroma: Int
    public let flavorNotes: [String]
    public let imageUrls: [String]
    public let comment: String?
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case cafeId = "cafe_id"
        case cafeName = "cafe_name"
        case address
        case latitude
        case longitude
        case beanName = "bean_name"
        case brewMethod = "brew_method"
        case roaster
        case origin
        case roastLevel = "roast_level"
        case acidity
        case sweetness
        case bitterness
        case body
        case aroma
        case flavorNotes = "flavor_notes"
        case imageUrls = "image_urls"
        case comment
        case createdAt = "created_at"
    }

    public init(
        id: UUID = UUID(),
        userId: UUID,
        cafeId: UUID? = nil,
        cafeName: String? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        beanName: String,
        brewMethod: String? = nil,
        roaster: String? = nil,
        origin: String? = nil,
        roastLevel: String? = nil,
        acidity: Int,
        sweetness: Int,
        bitterness: Int,
        body: Int,
        aroma: Int,
        flavorNotes: [String] = [],
        imageUrls: [String] = [],
        comment: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.cafeId = cafeId
        self.cafeName = cafeName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.beanName = beanName
        self.brewMethod = brewMethod
        self.roaster = roaster
        self.origin = origin
        self.roastLevel = roastLevel
        self.acidity = acidity
        self.sweetness = sweetness
        self.bitterness = bitterness
        self.body = body
        self.aroma = aroma
        self.flavorNotes = flavorNotes
        self.imageUrls = imageUrls
        self.comment = comment
        self.createdAt = createdAt
    }

    public init(from entity: CafeVisitNote) {
        self.id = entity.id
        self.userId = entity.userId
        self.cafeId = nil
        self.cafeName = entity.cafeName
        self.address = entity.address
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.beanName = entity.drinkName
        self.brewMethod = entity.brewMethod
        self.roaster = entity.roaster
        self.origin = entity.origin
        self.roastLevel = entity.roastLevel
        self.acidity = entity.taste.acidity
        self.sweetness = entity.taste.sweetness
        self.bitterness = entity.taste.bitterness
        self.body = entity.taste.body
        self.aroma = entity.taste.aroma
        self.flavorNotes = entity.flavorNotes
        self.imageUrls = entity.imageUrls
        self.comment = entity.comment
        self.createdAt = entity.createdAt
    }

    public func toDomain() -> CafeVisitNote {
        let taste = TasteParameter(
            acidity: acidity,
            sweetness: sweetness,
            bitterness: bitterness,
            body: body,
            aroma: aroma
        )
        return CafeVisitNote(
            id: id,
            userId: userId,
            cafeName: cafeName ?? "未知のカフェ",
            address: address,
            latitude: latitude,
            longitude: longitude,
            drinkName: beanName,
            brewMethod: brewMethod ?? "ハンドドリップ",
            roaster: roaster,
            origin: origin,
            roastLevel: roastLevel,
            taste: taste,
            flavorNotes: flavorNotes,
            imageUrls: imageUrls,
            comment: comment,
            createdAt: createdAt
        )
    }
}
