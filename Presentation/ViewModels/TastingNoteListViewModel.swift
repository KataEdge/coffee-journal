import SwiftUI
import Observation

@Observable
public final class TastingNoteListViewModel {
    public var notes: [CafeVisitNote] = []
    public var searchQuery: String = ""
    public var selectedBrewMethodFilter: String? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    private let repository: CoffeeRepositoryProtocol

    public init(repository: CoffeeRepositoryProtocol) {
        self.repository = repository
    }

    public var filteredNotes: [CafeVisitNote] {
        notes.filter { note in
            let matchesSearch = searchQuery.isEmpty ||
                note.cafeName.localizedCaseInsensitiveContains(searchQuery) ||
                (note.address?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                note.drinkName.localizedCaseInsensitiveContains(searchQuery) ||
                (note.roaster?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                (note.origin?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                (note.comment?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                note.flavorNotes.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) })

            let matchesBrewMethod = selectedBrewMethodFilter == nil ||
                note.brewMethod.localizedCaseInsensitiveContains(selectedBrewMethodFilter!)

            return matchesSearch && matchesBrewMethod
        }
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
    public func deleteNote(id: UUID) async {
        do {
            try await repository.deleteTastingNote(id: id)
            notes.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
