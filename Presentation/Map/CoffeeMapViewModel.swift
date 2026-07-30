import SwiftUI
import MapKit
import Observation

@Observable
public final class CoffeeMapViewModel {
    public var notes: [CafeVisitNote] = []
    public var selectedNote: CafeVisitNote? = nil
    public var position: MapCameraPosition = .userLocation(fallback: .automatic)
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    private let repository: CoffeeRepositoryProtocol
    public let locationManager: LocationManager

    public init(
        repository: CoffeeRepositoryProtocol,
        locationManager: LocationManager = LocationManager()
    ) {
        self.repository = repository
        self.locationManager = locationManager
    }

    public var notesWithLocation: [CafeVisitNote] {
        notes.filter { $0.latitude != nil && $0.longitude != nil }
    }

    @MainActor
    public func fetchNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            notes = try await repository.fetchTastingNotes()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    public func moveToUserLocation() {
        locationManager.requestLocation()
        if let userCoord = locationManager.userLocation {
            withAnimation(.easeInOut) {
                position = .region(
                    MKCoordinateRegion(
                        center: userCoord,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
            }
        } else {
            position = .userLocation(fallback: .automatic)
        }
    }

    public func selectNote(_ note: CafeVisitNote?) {
        selectedNote = note
        if let note = note, let lat = note.latitude, let lon = note.longitude {
            withAnimation(.easeInOut) {
                position = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }
}
