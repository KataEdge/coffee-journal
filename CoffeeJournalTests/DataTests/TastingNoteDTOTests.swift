import XCTest
@testable import CoffeeJournalCore

final class TastingNoteDTOTests: XCTestCase {

    func test_tastingNoteDTO_fromDomain_conversion() {
        let note = CafeVisitNote(
            cafeName: "Test Cafe",
            drinkName: "Test Drink",
            brewMethod: "ハンドドリップ",
            taste: TasteParameter()
        )

        let dto = TastingNoteDTO(from: note)
        XCTAssertEqual(dto.id, note.id)
        XCTAssertEqual(dto.cafeName, "Test Cafe")
        XCTAssertEqual(dto.beanName, "Test Drink")
    }

    func test_tastingNoteDTO_toDomain_conversion() {
        let dto = TastingNoteDTO(
            userId: UUID(),
            cafeName: "DTO Cafe",
            beanName: "DTO Bean",
            acidity: 5,
            sweetness: 5,
            bitterness: 5,
            body: 5,
            aroma: 5
        )

        let domain = dto.toDomain()
        XCTAssertEqual(domain.cafeName, "DTO Cafe")
        XCTAssertEqual(domain.drinkName, "DTO Bean")
        XCTAssertEqual(domain.brewMethod, "ハンドドリップ")
    }

    func test_tastingNoteDTO_toDomain_nilFallback() {
        let dto = TastingNoteDTO(
            userId: UUID(),
            cafeName: nil,
            beanName: "DTO Bean",
            brewMethod: nil,
            acidity: 5,
            sweetness: 5,
            bitterness: 5,
            body: 5,
            aroma: 5
        )

        let domain = dto.toDomain()
        XCTAssertEqual(domain.cafeName, "未知のカフェ")
        XCTAssertEqual(domain.brewMethod, "ハンドドリップ")
    }

    func test_tastingNoteDTO_json_encoding_decoding() throws {
        let dto = TastingNoteDTO(
            userId: UUID(),
            cafeName: "JSON Cafe",
            beanName: "JSON Bean",
            acidity: 3,
            sweetness: 4,
            bitterness: 2,
            body: 3,
            aroma: 4
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(dto)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(TastingNoteDTO.self, from: data)

        XCTAssertEqual(decoded.id, dto.id)
        XCTAssertEqual(decoded.cafeName, dto.cafeName)
    }
}
