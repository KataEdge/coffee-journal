import XCTest
@testable import CoffeeJournalCore

final class CafeTests: XCTestCase {

    func test_cafe_initialization_defaults_and_custom_values() {
        let id = UUID()
        let now = Date()
        let cafe = Cafe(
            id: id,
            name: "Blue Bottle Coffee",
            address: "Kiyosumi Shirakawa, Tokyo",
            latitude: 35.6812,
            longitude: 139.7671,
            createdAt: now
        )

        XCTAssertEqual(cafe.id, id)
        XCTAssertEqual(cafe.name, "Blue Bottle Coffee")
        XCTAssertEqual(cafe.address, "Kiyosumi Shirakawa, Tokyo")
        XCTAssertEqual(cafe.latitude, 35.6812)
        XCTAssertEqual(cafe.longitude, 139.7671)
        XCTAssertEqual(cafe.createdAt, now)
    }

    func test_cafe_codable() throws {
        let cafe = Cafe(name: "Fuglen Tokyo", address: "Yoyogi, Tokyo")

        let encoder = JSONEncoder()
        let data = try encoder.encode(cafe)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Cafe.self, from: data)

        XCTAssertEqual(decoded.id, cafe.id)
        XCTAssertEqual(decoded.name, cafe.name)
        XCTAssertEqual(decoded.address, cafe.address)
    }
}
