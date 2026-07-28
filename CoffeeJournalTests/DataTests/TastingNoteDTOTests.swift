import XCTest
@testable import CoffeeJournalCore

final class TastingNoteDTOTests: XCTestCase {

    func test_tastingNoteDTO_toDomain_conversion() {
        // Given
        let id = UUID()
        let userId = UUID()
        let dto = TastingNoteDTO(
            id: id,
            userId: userId,
            cafeId: nil,
            cafeName: "Blue Bottle Coffee",
            address: "東京都港区南青山",
            latitude: 35.665,
            longitude: 139.712,
            beanName: "エチオピア イルガチェフェ",
            brewMethod: "ハンドドリップ",
            roaster: "Blue Bottle",
            origin: "Ethiopia",
            roastLevel: "浅煎り",
            acidity: 4,
            sweetness: 4,
            bitterness: 2,
            body: 3,
            aroma: 5,
            flavorNotes: ["フローラル", "シトラス"],
            imageUrls: ["https://example.com/photo.jpg"],
            comment: "華やかな香りとフルーティーな味わい。",
            createdAt: Date(timeIntervalSince1970: 1600000000)
        )

        // When
        let domain = dto.toDomain()

        // Then
        XCTAssertEqual(domain.id, id)
        XCTAssertEqual(domain.userId, userId)
        XCTAssertEqual(domain.cafeName, "Blue Bottle Coffee")
        XCTAssertEqual(domain.address, "東京都港区南青山")
        XCTAssertEqual(domain.latitude, 35.665)
        XCTAssertEqual(domain.longitude, 139.712)
        XCTAssertEqual(domain.drinkName, "エチオピア イルガチェフェ")
        XCTAssertEqual(domain.brewMethod, "ハンドドリップ")
        XCTAssertEqual(domain.roaster, "Blue Bottle")
        XCTAssertEqual(domain.origin, "Ethiopia")
        XCTAssertEqual(domain.roastLevel, "浅煎り")
        XCTAssertEqual(domain.taste.acidity, 4)
        XCTAssertEqual(domain.taste.sweetness, 4)
        XCTAssertEqual(domain.taste.bitterness, 2)
        XCTAssertEqual(domain.taste.body, 3)
        XCTAssertEqual(domain.taste.aroma, 5)
        XCTAssertEqual(domain.flavorNotes, ["フローラル", "シトラス"])
        XCTAssertEqual(domain.imageUrls, ["https://example.com/photo.jpg"])
        XCTAssertEqual(domain.comment, "華やかな香りとフルーティーな味わい。")
    }

    func test_tastingNoteDTO_fromDomain_conversion() {
        // Given
        let id = UUID()
        let userId = UUID()
        let taste = TasteParameter(acidity: 5, sweetness: 3, bitterness: 2, body: 4, aroma: 5)
        let domain = CafeVisitNote(
            id: id,
            userId: userId,
            cafeName: "Fuglen Tokyo",
            address: "東京都渋谷区富ヶ谷",
            latitude: 35.669,
            longitude: 139.691,
            drinkName: "エアロプレス シングルオリジン",
            brewMethod: "エアロプレス",
            roaster: "Fuglen",
            origin: "Kenya",
            roastLevel: "浅煎り",
            taste: taste,
            flavorNotes: ["ベリー", "カシス"],
            imageUrls: ["https://example.com/fuglen.jpg"],
            comment: "爽やかな酸味が印象的。",
            createdAt: Date(timeIntervalSince1970: 1700000000)
        )

        // When
        let dto = TastingNoteDTO(from: domain)

        // Then
        XCTAssertEqual(dto.id, id)
        XCTAssertEqual(dto.userId, userId)
        XCTAssertEqual(dto.cafeName, "Fuglen Tokyo")
        XCTAssertEqual(dto.address, "東京都渋谷区富ヶ谷")
        XCTAssertEqual(dto.latitude, 35.669)
        XCTAssertEqual(dto.longitude, 139.691)
        XCTAssertEqual(dto.beanName, "エアロプレス シングルオリジン")
        XCTAssertEqual(dto.brewMethod, "エアロプレス")
        XCTAssertEqual(dto.roaster, "Fuglen")
        XCTAssertEqual(dto.origin, "Kenya")
        XCTAssertEqual(dto.roastLevel, "浅煎り")
        XCTAssertEqual(dto.acidity, 5)
        XCTAssertEqual(dto.sweetness, 3)
        XCTAssertEqual(dto.bitterness, 2)
        XCTAssertEqual(dto.body, 4)
        XCTAssertEqual(dto.aroma, 5)
        XCTAssertEqual(dto.flavorNotes, ["ベリー", "カシス"])
        XCTAssertEqual(dto.imageUrls, ["https://example.com/fuglen.jpg"])
        XCTAssertEqual(dto.comment, "爽やかな酸味が印象的。")
    }

    func test_tastingNoteDTO_json_encoding_decoding() throws {
        // Given
        let dto = TastingNoteDTO(
            id: UUID(),
            userId: UUID(),
            cafeName: "テストカフェ",
            beanName: "テストビーンズ",
            acidity: 3,
            sweetness: 3,
            bitterness: 3,
            body: 3,
            aroma: 3
        )
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // When
        let data = try encoder.encode(dto)
        let decodedDTO = try decoder.decode(TastingNoteDTO.self, from: data)

        // Then
        XCTAssertEqual(dto.id, decodedDTO.id)
        XCTAssertEqual(dto.userId, decodedDTO.userId)
        XCTAssertEqual(dto.cafeName, decodedDTO.cafeName)
        XCTAssertEqual(dto.beanName, decodedDTO.beanName)
    }
}
