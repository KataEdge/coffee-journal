import XCTest
@testable import CoffeeJournalCore

final class ProfileDTOTests: XCTestCase {

    func test_profileDTO_initialization_and_toDomain() {
        let id = UUID()
        let dto = ProfileDTO(
            id: id,
            username: "testuser",
            avatarUrl: "https://example.com/avatar.png",
            updatedAt: "2026-07-30T12:00:00Z"
        )

        XCTAssertEqual(dto.id, id)
        XCTAssertEqual(dto.username, "testuser")
        XCTAssertEqual(dto.avatarUrl, "https://example.com/avatar.png")
        XCTAssertEqual(dto.updatedAt, "2026-07-30T12:00:00Z")

        let domain = dto.toDomain()
        XCTAssertEqual(domain.id, id)
        XCTAssertEqual(domain.username, "testuser")
        XCTAssertEqual(domain.avatarUrl, "https://example.com/avatar.png")
    }

    func test_profileDTO_fromDomain_conversion() {
        let id = UUID()
        let domain = UserProfile(
            id: id,
            username: "coffeelover",
            avatarUrl: "https://example.com/coffee.jpg",
            updatedAt: Date()
        )

        let dto = ProfileDTO(from: domain)
        XCTAssertEqual(dto.id, id)
        XCTAssertEqual(dto.username, "coffeelover")
        XCTAssertEqual(dto.avatarUrl, "https://example.com/coffee.jpg")
        XCTAssertNotNil(dto.updatedAt)
    }

    func test_profileDTO_json_encoding_decoding() throws {
        let id = UUID()
        let originalDTO = ProfileDTO(
            id: id,
            username: "barista",
            avatarUrl: "https://example.com/barista.jpg"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDTO)

        let decoder = JSONDecoder()
        let decodedDTO = try decoder.decode(ProfileDTO.self, from: data)

        XCTAssertEqual(decodedDTO.id, originalDTO.id)
        XCTAssertEqual(decodedDTO.username, originalDTO.username)
        XCTAssertEqual(decodedDTO.avatarUrl, originalDTO.avatarUrl)
    }
}
