import Foundation
import MapKit
import CoreLocation
import Observation

public struct LocationSearchResult: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let latitude: Double?
    public let longitude: Double?
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }

    public var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LocationSearchResult, rhs: LocationSearchResult) -> Bool {
        lhs.id == rhs.id
    }
}

@Observable
public final class LocationSearchService: @unchecked Sendable {
    public var searchResults: [LocationSearchResult] = []
    public var isSearching: Bool = false
    
    public init() {}
    
    @MainActor
    public func searchCafes(query: String, region: MKCoordinateRegion? = nil) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        if let region = region {
            request.region = region
        }
        request.resultTypes = .pointOfInterest
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            searchResults = response.mapItems.compactMap { item in
                guard let name = item.name else { return nil }
                let coord = item.placemark.coordinate
                return LocationSearchResult(
                    title: name,
                    subtitle: item.placemark.title ?? name,
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            }
        } catch {
            searchResults = []
        }
    }
    
    @MainActor
    public func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> (name: String, address: String)? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let name = placemark.name ?? placemark.areasOfInterest?.first ?? "現在地周辺"
                let addressComponents = [
                    placemark.administrativeArea,
                    placemark.locality,
                    placemark.thoroughfare,
                    placemark.subThoroughfare
                ].compactMap { $0 }
                let address = addressComponents.joined()
                
                return (name, address.isEmpty ? name : address)
            }
        } catch {
            return nil
        }
        return nil
    }
}
