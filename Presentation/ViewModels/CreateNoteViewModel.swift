import SwiftUI
import Observation
import CoreLocation

@Observable
public final class CreateNoteViewModel {
    public var cafeName: String = ""
    public var address: String = ""
    public var latitude: Double? = nil
    public var longitude: Double? = nil
    public var drinkName: String = ""
    public var brewMethod: String = "ハンドドリップ"
    public var roaster: String = ""
    public var origin: String = ""
    public var roastLevel: String = "中煎り"
    public var acidity: Int = 3
    public var sweetness: Int = 3
    public var bitterness: Int = 3
    public var body: Int = 3
    public var aroma: Int = 3
    public var selectedFlavorTags: Set<String> = []
    public var comment: String = ""
    public var isSaving: Bool = false
    public var errorMessage: String? = nil

    public let locationManager: LocationManager
    public let locationSearchService: LocationSearchService

    public let availableBrewMethods = [
        "ハンドドリップ", "エスプレッソ・ラテ", "水出し", "フレンチプレス", "サイフォン", "エアロプレス", "その他"
    ]

    public let availableFlavorTags = [
        "フローラル", "ジャスミン", "シトラス", "ベリー", "リンゴ",
        "ナッツ", "アーモンド", "チョコレート", "キャラメル", "スパイス", "スモーキー"
    ]

    private let repository: CoffeeRepositoryProtocol
    private let userId: UUID
    private let editingNote: CafeVisitNote?

    public var isEditing: Bool { editingNote != nil }

    public init(
        repository: CoffeeRepositoryProtocol,
        userId: UUID = UUID(),
        existingNote: CafeVisitNote? = nil,
        locationManager: LocationManager = LocationManager(),
        locationSearchService: LocationSearchService = LocationSearchService()
    ) {
        self.repository = repository
        self.userId = userId
        self.editingNote = existingNote
        self.locationManager = locationManager
        self.locationSearchService = locationSearchService

        if let existingNote {
            self.cafeName = existingNote.cafeName
            self.address = existingNote.address ?? ""
            self.latitude = existingNote.latitude
            self.longitude = existingNote.longitude
            self.drinkName = existingNote.drinkName
            self.brewMethod = existingNote.brewMethod
            self.roaster = existingNote.roaster ?? ""
            self.origin = existingNote.origin ?? ""
            self.roastLevel = existingNote.roastLevel ?? ""
            self.acidity = existingNote.taste.acidity
            self.sweetness = existingNote.taste.sweetness
            self.bitterness = existingNote.taste.bitterness
            self.body = existingNote.taste.body
            self.aroma = existingNote.taste.aroma
            self.selectedFlavorTags = Set(existingNote.flavorNotes)
            self.comment = existingNote.comment ?? ""
        }
    }

    public var isValid: Bool {
        !cafeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !drinkName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func toggleFlavorTag(_ tag: String) {
        if selectedFlavorTags.contains(tag) {
            selectedFlavorTags.remove(tag)
        } else {
            selectedFlavorTags.insert(tag)
        }
    }

    @MainActor
    public func searchLocationCandidates() async {
        await locationSearchService.searchCafes(query: cafeName)
    }

    @MainActor
    public func selectSearchResult(_ result: LocationSearchResult) {
        self.cafeName = result.title
        self.address = result.subtitle
        self.latitude = result.latitude
        self.longitude = result.longitude
        self.locationSearchService.searchResults = []
    }

    @MainActor
    public func fetchCurrentLocation() async {
        locationManager.requestLocation()
        if let userCoord = locationManager.userLocation {
            self.latitude = userCoord.latitude
            self.longitude = userCoord.longitude

            if let geocoded = await locationSearchService.reverseGeocode(coordinate: userCoord) {
                if cafeName.isEmpty {
                    cafeName = geocoded.name
                }
                if address.isEmpty {
                    address = geocoded.address
                }
            }
        }
    }

    @MainActor
    public func saveNote() async -> CafeVisitNote? {
        guard isValid else {
            errorMessage = "カフェ店名とドリンク名を入力してください。"
            return nil
        }

        isSaving = true
        errorMessage = nil

        let taste = TasteParameter(
            acidity: acidity,
            sweetness: sweetness,
            bitterness: bitterness,
            body: body,
            aroma: aroma
        )

        let note = CafeVisitNote(
            id: editingNote?.id ?? UUID(),
            userId: editingNote?.userId ?? userId,
            cafeName: cafeName.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.isEmpty ? nil : address.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: latitude,
            longitude: longitude,
            drinkName: drinkName.trimmingCharacters(in: .whitespacesAndNewlines),
            brewMethod: brewMethod,
            roaster: roaster.isEmpty ? nil : roaster.trimmingCharacters(in: .whitespacesAndNewlines),
            origin: origin.isEmpty ? nil : origin.trimmingCharacters(in: .whitespacesAndNewlines),
            roastLevel: roastLevel.isEmpty ? nil : roastLevel,
            taste: taste,
            flavorNotes: Array(selectedFlavorTags),
            imageUrls: editingNote?.imageUrls ?? [],
            comment: comment.isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: editingNote?.createdAt ?? Date()
        )

        do {
            let saved = isEditing
                ? try await repository.updateTastingNote(note)
                : try await repository.createTastingNote(note)
            isSaving = false
            return saved
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return nil
        }
    }
}
