import SwiftUI
import Observation

@Observable
public final class CreateNoteViewModel {
    public var beanName: String = ""
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

    public let availableFlavorTags = [
        "フローラル", "ジャスミン", "シトラス", "ベリー", "リンゴ",
        "ナッツ", "アーモンド", "チョコレート", "カラメル", "スパイス", "スモーキー"
    ]

    private let repository: CoffeeRepositoryProtocol
    private let userId: UUID

    public init(repository: CoffeeRepositoryProtocol, userId: UUID = UUID()) {
        self.repository = repository
        self.userId = userId
    }

    public var isValid: Bool {
        !beanName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public func toggleFlavorTag(_ tag: String) {
        if selectedFlavorTags.contains(tag) {
            selectedFlavorTags.remove(tag)
        } else {
            selectedFlavorTags.insert(tag)
        }
    }

    @MainActor
    public func saveNote() async -> Bool {
        guard isValid else {
            errorMessage = "コーヒー豆の名前を入力してください。"
            return false
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

        let note = TastingNote(
            userId: userId,
            beanName: beanName.trimmingCharacters(in: .whitespacesAndNewlines),
            roaster: roaster.isEmpty ? nil : roaster.trimmingCharacters(in: .whitespacesAndNewlines),
            origin: origin.isEmpty ? nil : origin.trimmingCharacters(in: .whitespacesAndNewlines),
            roastLevel: roastLevel,
            taste: taste,
            flavorNotes: Array(selectedFlavorTags),
            comment: comment.isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        do {
            _ = try await repository.createTastingNote(note)
            isSaving = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
            return false
        }
    }
}
