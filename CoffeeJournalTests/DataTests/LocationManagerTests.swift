import XCTest
import CoreLocation
@testable import CoffeeJournalCore

final class LocationManagerTests: XCTestCase {

    func test_locationManager_initialization() {
        let manager = LocationManager()
        XCTAssertNil(manager.userLocation)
        XCTAssertNil(manager.errorMessage)
    }

    func test_locationManager_requestAuthorization_and_requestLocation() {
        let manager = LocationManager()
        manager.requestAuthorization()
        manager.requestLocation()

        manager.authorizationStatus = .authorizedAlways
        manager.requestLocation()
    }

    func test_locationManager_delegate_didUpdateLocations() async {
        let manager = LocationManager()
        let dummyLocation = CLLocation(latitude: 35.6812, longitude: 139.7671)

        manager.locationManager(CLLocationManager(), didUpdateLocations: [dummyLocation])

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNotNil(manager.userLocation)
        XCTAssertEqual(manager.userLocation?.latitude, 35.6812)
        XCTAssertEqual(manager.userLocation?.longitude, 139.7671)
    }

    func test_locationManager_delegate_didFailWithError() async {
        let manager = LocationManager()
        let dummyError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location error"])

        manager.locationManager(CLLocationManager(), didFailWithError: dummyError)

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNotNil(manager.errorMessage)
        XCTAssertEqual(manager.errorMessage, "Location error")
    }

    func test_locationManager_delegate_locationManagerDidChangeAuthorization() async {
        let manager = LocationManager()
        let clManager = CLLocationManager()

        manager.locationManagerDidChangeAuthorization(clManager)

        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertNotNil(manager.authorizationStatus)
    }
}
