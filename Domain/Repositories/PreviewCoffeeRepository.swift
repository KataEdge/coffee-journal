import Foundation

public final class PreviewCoffeeRepository: CoffeeRepositoryProtocol, @unchecked Sendable {
    public var notes: [CafeVisitNote] = []

    public init(notes: [CafeVisitNote] = []) {
        self.notes = notes
    }

    public static var sample: PreviewCoffeeRepository {
        let sampleNotes = [
            CafeVisitNote(
                id: UUID(),
                userId: UUID(),
                cafeName: "Blue Bottle Coffee 清澄白河フラッグシップカフェ",
                address: "東京都江東区平野1-4-8",
                latitude: 35.6811,
                longitude: 139.7997,
                drinkName: "シングルオリジン ハンドドリップ",
                brewMethod: "ハンドドリップ",
                roaster: "Blue Bottle Coffee",
                origin: "エチオピア",
                roastLevel: "浅煎り",
                taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
                flavorNotes: ["ジャスミン", "シトラス", "ベリー"],
                imageUrls: [],
                comment: "天井が高く開放的な空間。淹れたてのハンドドリップはジャスミンのような香りと果実味が際立つ。",
                createdAt: Date()
            ),
            CafeVisitNote(
                id: UUID(),
                userId: UUID(),
                cafeName: "STREAMER COFFEE COMPANY 渋谷",
                address: "東京都渋谷区渋谷1-20-28",
                latitude: 35.6617,
                longitude: 139.7028,
                drinkName: "ストリーマーラテ",
                brewMethod: "エスプレッソ・ラテ",
                roaster: "STREAMER COFFEE",
                origin: "ブレンド",
                roastLevel: "深煎り",
                taste: TasteParameter(acidity: 1, sweetness: 4, bitterness: 4, body: 5, aroma: 4),
                flavorNotes: ["ダークチョコレート", "キャラメル", "アーモンド"],
                imageUrls: [],
                comment: "繊細なフリーポア・ラテアートが素晴らしい。濃厚なミルクの甘みと深煎りエスプレッソの重厚なコク。",
                createdAt: Date().addingTimeInterval(-86400)
            ),
            CafeVisitNote(
                id: UUID(),
                userId: UUID(),
                cafeName: "FUGLEN TOKYO (フグレン トウキョウ)",
                address: "東京都渋谷区富ヶ谷1-16-11",
                latitude: 35.6685,
                longitude: 139.6914,
                drinkName: "エアロプレス ケニア",
                brewMethod: "ハンドドリップ",
                roaster: "Fuglen Coffee Roasters",
                origin: "ケニア",
                roastLevel: "浅煎り",
                taste: TasteParameter(acidity: 4, sweetness: 5, bitterness: 2, body: 4, aroma: 5),
                flavorNotes: ["カシス", "ブラックベリー", "カカオ"],
                imageUrls: [],
                comment: "北欧ヴィンテージのインテリアが落ち着く空間。明るい酸味とすっきりした甘さが特徴的。",
                createdAt: Date().addingTimeInterval(-172800)
            )
        ]
        return PreviewCoffeeRepository(notes: sampleNotes)
    }

    public func fetchTastingNotes() async throws -> [CafeVisitNote] {
        return notes
    }

    public func fetchTastingNotes(for userId: UUID) async throws -> [CafeVisitNote] {
        return notes.filter { $0.userId == userId }
    }

    public func fetchTastingNote(by id: UUID) async throws -> CafeVisitNote? {
        return notes.first { $0.id == id }
    }

    public func createTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote {
        notes.append(note)
        return note
    }

    public func updateTastingNote(_ note: CafeVisitNote) async throws -> CafeVisitNote {
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
