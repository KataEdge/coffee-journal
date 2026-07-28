import SwiftUI
import Observation

@Observable
public final class TastingNoteListViewModel {
    public var notes: [TastingNote] = []
    public var searchQuery: String = ""
    public var selectedRoastFilter: String? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    private let repository: CoffeeRepositoryProtocol

    public init(repository: CoffeeRepositoryProtocol) {
        self.repository = repository
    }

    public var filteredNotes: [TastingNote] {
        notes.filter { note in
            let matchesSearch = searchQuery.isEmpty ||
                note.beanName.localizedCaseInsensitiveContains(searchQuery) ||
                (note.roaster?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                (note.origin?.localizedCaseInsensitiveContains(searchQuery) ?? false) ||
                note.flavorNotes.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) })

            let matchesRoast = selectedRoastFilter == nil ||
                (note.roastLevel?.localizedCaseInsensitiveContains(selectedRoastFilter!) ?? false)

            return matchesSearch && matchesRoast
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
