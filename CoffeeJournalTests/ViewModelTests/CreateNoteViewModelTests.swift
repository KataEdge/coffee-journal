import XCTest
import CoreLocation
@testable import CoffeeJournalCore

final class CreateNoteViewModelTests: XCTestCase {

    func testCreateNoteViewModel_initialState_and_editingState() {
        let repo = MockCoffeeRepository()
        let vmNew = CreateNoteViewModel(repository: repo)

        XCTAssertFalse(vmNew.isEditing)
        XCTAssertFalse(vmNew.isValid)
        XCTAssertEqual(vmNew.brewMethod, "ハンドドリップ")
        XCTAssertEqual(vmNew.roastLevel, "中煎り")
        XCTAssertEqual(vmNew.acidity, 5)
        XCTAssertEqual(vmNew.sweetness, 5)
        XCTAssertEqual(vmNew.bitterness, 5)
        XCTAssertEqual(vmNew.body, 5)
        XCTAssertEqual(vmNew.aroma, 5)
        XCTAssertEqual(vmNew.availableBrewMethods.count, 7)
        XCTAssertEqual(vmNew.availableFlavorTags.count, 11)
        XCTAssertNotNil(vmNew.locationManager)
        XCTAssertNotNil(vmNew.locationSearchService)

        let existingNote = CafeVisitNote(
            userId: UUID(),
            cafeName: "Fuglen Tokyo",
            address: "Tomigaya, Shibuya",
            latitude: 35.666,
            longitude: 139.69,
            drinkName: "Filter Coffee",
            brewMethod: "ハンドドリップ",
            roaster: "Fuglen",
            origin: "Norway",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 4, sweetness: 3, bitterness: 1, body: 2, aroma: 5),
            flavorNotes: ["Floral", "Citrus"],
            comment: "Great experience"
        )

        let vmEdit = CreateNoteViewModel(repository: repo, existingNote: existingNote)
        XCTAssertTrue(vmEdit.isEditing)
        XCTAssertTrue(vmEdit.isValid)
        XCTAssertEqual(vmEdit.cafeName, "Fuglen Tokyo")
        XCTAssertEqual(vmEdit.drinkName, "Filter Coffee")
        XCTAssertEqual(vmEdit.address, "Tomigaya, Shibuya")
        XCTAssertEqual(vmEdit.roaster, "Fuglen")
        XCTAssertEqual(vmEdit.origin, "Norway")
        XCTAssertEqual(vmEdit.roastLevel, "浅煎り")
        XCTAssertEqual(vmEdit.acidity, 4)
        XCTAssertTrue(vmEdit.selectedFlavorTags.contains("Floral"))
        XCTAssertEqual(vmEdit.comment, "Great experience")
    }

    func testCreateNoteViewModel_toggleFlavorTag() {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        XCTAssertFalse(vm.selectedFlavorTags.contains("Berry"))

        vm.toggleFlavorTag("Berry")
        XCTAssertTrue(vm.selectedFlavorTags.contains("Berry"))

        vm.toggleFlavorTag("Berry")
        XCTAssertFalse(vm.selectedFlavorTags.contains("Berry"))
    }

    @MainActor
    func testCreateNoteViewModel_selectSearchResult() {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        let result = LocationSearchResult(
            title: "Blue Bottle Coffee",
            subtitle: "Kiyosumi, Koto-ku",
            latitude: 35.68,
            longitude: 139.76
        )

        vm.selectSearchResult(result)

        XCTAssertEqual(vm.cafeName, "Blue Bottle Coffee")
        XCTAssertEqual(vm.address, "Kiyosumi, Koto-ku")
        XCTAssertEqual(vm.latitude, 35.68)
        XCTAssertEqual(vm.longitude, 139.76)
        XCTAssertTrue(vm.locationSearchService.searchResults.isEmpty)
    }

    func testCreateNoteViewModel_saveInvalid_returnsNil_setsErrorMessage() async {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        vm.cafeName = ""
        vm.drinkName = ""

        let saved = await vm.saveNote()
        XCTAssertNil(saved)
        XCTAssertEqual(vm.errorMessage, "カフェ店名とドリンク名を入力してください。")
    }

    func testCreateNoteViewModel_saveExistingNote_updatesRepository() async {
        let repo = MockCoffeeRepository()
        let noteId = UUID()
        let existingNote = CafeVisitNote(
            id: noteId,
            userId: UUID(),
            cafeName: "Old Cafe",
            drinkName: "Old Drink",
            brewMethod: "ハンドドリップ",
            taste: TasteParameter()
        )

        _ = try? await repo.createTastingNote(existingNote)

        let vm = CreateNoteViewModel(repository: repo, existingNote: existingNote)
        vm.cafeName = "Updated Cafe"
        vm.drinkName = "Updated Drink"
        vm.address = ""
        vm.roaster = ""
        vm.origin = ""
        vm.roastLevel = ""
        vm.comment = ""

        let saved = await vm.saveNote()
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.id, noteId)
        XCTAssertEqual(saved?.cafeName, "Updated Cafe")

        let fetched = try? await repo.fetchTastingNotes()
        XCTAssertEqual(fetched?.count, 1)
        XCTAssertEqual(fetched?.first?.cafeName, "Updated Cafe")
        XCTAssertNil(fetched?.first?.address)
        XCTAssertNil(fetched?.first?.roaster)
        XCTAssertNil(fetched?.first?.origin)
        XCTAssertNil(fetched?.first?.roastLevel)
        XCTAssertNil(fetched?.first?.comment)
    }

    func testCreateNoteViewModel_saveRepositoryError_setsErrorMessage() async {
        let repo = MockCoffeeRepository()
        repo.shouldFail = true

        let vm = CreateNoteViewModel(repository: repo)
        vm.cafeName = "Test Cafe"
        vm.drinkName = "Test Drink"

        let saved = await vm.saveNote()
        XCTAssertNil(saved)
        XCTAssertNotNil(vm.errorMessage)
    }

    @MainActor
    func testCreateNoteViewModel_searchCandidates_and_fetchCurrentLocation() async {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)

        vm.cafeName = "Fuglen"
        await vm.searchLocationCandidates()

        await vm.fetchCurrentLocation()
    }

    @MainActor
    func testCreateNoteViewModel_fetchCurrentLocation_withKnownCoordinate_fillsCafeNameAndAddress() async {
        let repo = MockCoffeeRepository()
        let vm = CreateNoteViewModel(repository: repo)
        vm.cafeName = ""
        vm.address = ""
        vm.locationManager.userLocation = CLLocationCoordinate2D(latitude: 35.6812, longitude: 139.7671)

        await vm.fetchCurrentLocation()

        XCTAssertEqual(vm.latitude, 35.6812)
        XCTAssertEqual(vm.longitude, 139.7671)
    }
}
