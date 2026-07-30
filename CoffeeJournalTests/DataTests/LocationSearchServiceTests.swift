import XCTest
import CoreLocation
import MapKit
@testable import CoffeeJournalCore

final class LocationSearchServiceTests: XCTestCase {

    func test_locationSearchResult_properties_and_coordinate() {
        let resultWithCoord = LocationSearchResult(
            title: "Blue Bottle Coffee",
            subtitle: "Kiyosumi, Koto-ku",
            latitude: 35.6812,
            longitude: 139.7671
        )

        XCTAssertEqual(resultWithCoord.title, "Blue Bottle Coffee")
        XCTAssertEqual(resultWithCoord.subtitle, "Kiyosumi, Koto-ku")
        XCTAssertNotNil(resultWithCoord.coordinate)
        XCTAssertEqual(resultWithCoord.coordinate?.latitude, 35.6812)
        XCTAssertEqual(resultWithCoord.coordinate?.longitude, 139.7671)

        let resultWithoutCoord = LocationSearchResult(
            title: "Unknown Cafe",
            subtitle: "Somewhere"
        )
        XCTAssertNil(resultWithoutCoord.coordinate)
    }

    func test_locationSearchResult_equality_and_hash() {
        let id = UUID()
        let res1 = LocationSearchResult(id: id, title: "Cafe A", subtitle: "Addr A")
        let res2 = LocationSearchResult(id: id, title: "Cafe A Updated", subtitle: "Addr A Updated")

        XCTAssertEqual(res1, res2)

        var hasher1 = Hasher()
        res1.hash(into: &hasher1)
        var hasher2 = Hasher()
        res2.hash(into: &hasher2)
        XCTAssertEqual(hasher1.finalize(), hasher2.finalize())
    }

    @MainActor
    func test_searchCafes_withEmptyQuery_clearsResultsImmediately() async {
        let service = LocationSearchService()
        service.searchResults = [
            LocationSearchResult(title: "Old Result", subtitle: "Old Subtitle")
        ]

        await service.searchCafes(query: "   ")

        XCTAssertTrue(service.searchResults.isEmpty)
        XCTAssertFalse(service.isSearching)
    }

    @MainActor
    func test_searchCafes_withQuery_and_Region() async {
        let service = LocationSearchService()
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        await service.searchCafes(query: "Cafe", region: region)

        XCTAssertFalse(service.isSearching)
    }

    @MainActor
    func test_reverseGeocode_handlesCoordinateWithoutCrash() async {
        let service = LocationSearchService()
        let coord = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)

        _ = await service.reverseGeocode(coordinate: coord)
    }
}
