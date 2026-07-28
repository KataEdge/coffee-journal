import Foundation

public final class PreviewCoffeeRepository: CoffeeRepositoryProtocol, @unchecked Sendable {
    public var notes: [TastingNote] = []

    public init(notes: [TastingNote] = []) {
        self.notes = notes
    }

    public static var sample: PreviewCoffeeRepository {
        let sampleNotes = [
            TastingNote(
                id: UUID(),
                userId: UUID(),
                cafeId: nil,
                beanName: "イルガチェフェ G1 ナチュラル",
                roaster: "FUJIYAMA COFFEE ROASTERS",
                origin: "エチオピア",
                roastLevel: "浅煎り",
                taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
                flavorNotes: ["フローラル", "ジャスミン", "シトラス", "ベリー"],
                imageUrls: [],
                comment: "華やかなジャスミンのアロマとイチゴのような爽やかな甘酸っぱさが広がる素晴らしい浅煎りコーヒー。",
                createdAt: Date()
            ),
            TastingNote(
                id: UUID(),
                userId: UUID(),
                cafeId: nil,
                beanName: "マンデリン アチェ ベラト カトウ",
                roaster: "LIGHT UP COFFEE",
                origin: "インドネシア",
                roastLevel: "深煎り",
                taste: TasteParameter(acidity: 2, sweetness: 3, bitterness: 5, body: 5, aroma: 4),
                flavorNotes: ["スパイス", "スモーキー", "チョコレート"],
                imageUrls: [],
                comment: "重厚なコクとハーブのような深いスパイシーさ。ミルクとの相性も抜群の深煎り。",
                createdAt: Date().addingTimeInterval(-86400)
            ),
            TastingNote(
                id: UUID(),
                userId: UUID(),
                cafeId: nil,
                beanName: "エル・パライソ 農園",
                roaster: "KOTO COFFEE",
                origin: "コロンビア",
                roastLevel: "中煎り",
                taste: TasteParameter(acidity: 4, sweetness: 5, bitterness: 2, body: 4, aroma: 5),
                flavorNotes: ["ライチ", "ピーチ", "カラメル"],
                imageUrls: [],
                comment: "アナエロビック発酵によるライチやピーチのような強烈なフルーツアロマとジューシーな甘み。",
                createdAt: Date().addingTimeInterval(-172800)
            )
        ]
        return PreviewCoffeeRepository(notes: sampleNotes)
    }

    public func fetchTastingNotes() async throws -> [TastingNote] {
        return notes
    }

    public func fetchTastingNotes(for userId: UUID) async throws -> [TastingNote] {
        return notes.filter { $0.userId == userId }
    }

    public func fetchTastingNote(by id: UUID) async throws -> TastingNote? {
        return notes.first { $0.id == id }
    }

    public func createTastingNote(_ note: TastingNote) async throws -> TastingNote {
        notes.append(note)
        return note
    }

    public func updateTastingNote(_ note: TastingNote) async throws -> TastingNote {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            return note
        }
        return note
    }

    public func deleteTastingNote(id: UUID) async throws {
        notes.removeAll { $0.id == id }
    }
}
