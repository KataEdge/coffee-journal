import Foundation
import CoreLocation
import Observation

@Observable
public final class LocationManager: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    public var userLocation: CLLocationCoordinate2D?
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    public var errorMessage: String?

    private let locationManager = CLLocationManager()

    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
    }

    public func requestAuthorization() {
        #if os(iOS)
        locationManager.requestWhenInUseAuthorization()
        #else
        locationManager.requestAlwaysAuthorization()
        #endif
    }

    public var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedAlways
        #endif
    }

    public func requestLocation() {
        if authorizationStatus == .notDetermined {
            requestAuthorization()
        } else if isAuthorized {
            locationManager.requestLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if self.isAuthorized {
                manager.requestLocation()
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coord = location.coordinate
        Task { @MainActor in
            self.userLocation = coord
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let message = error.localizedDescription
        Task { @MainActor in
            self.errorMessage = message
        }
    }
}
