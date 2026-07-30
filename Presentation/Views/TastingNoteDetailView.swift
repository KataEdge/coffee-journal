import SwiftUI

public struct TastingNoteDetailView: View {
    public let note: CafeVisitNote

    public init(note: CafeVisitNote) {
        self.note = note
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section (Cafe info & Drink info)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(note.brewMethod)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.amberAccent.opacity(0.18)))
                            .foregroundColor(.amberAccent)

                        Spacer()

                        Text(note.createdAt.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(note.cafeName)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)

                    if let address = note.address, !address.isEmpty {
                        Label(address, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "cup.and.saucer.fill")
                            .foregroundColor(.amberAccent)
                        Text(note.drinkName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 4)

                    if note.roaster != nil || note.origin != nil || note.roastLevel != nil {
                        HStack(spacing: 12) {
                            if let roaster = note.roaster, !roaster.isEmpty {
                                Label(roaster, systemImage: "building.2")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let origin = note.origin, !origin.isEmpty {
                                Label(origin, systemImage: "globe")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if let roastLevel = note.roastLevel, !roastLevel.isEmpty {
                                Label(roastLevel, systemImage: "flame")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Taste Radar Chart Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("味のパラメータ")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TasteRadarChart(taste: note.taste)
                        .frame(height: 220)

                    HStack(spacing: 12) {
                        TasteScoreItem(label: "酸味", score: note.taste.acidity)
                        TasteScoreItem(label: "甘味", score: note.taste.sweetness)
                        TasteScoreItem(label: "苦味", score: note.taste.bitterness)
                        TasteScoreItem(label: "コク", score: note.taste.body)
                        TasteScoreItem(label: "香り", score: note.taste.aroma)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal)

                // Flavor Notes
                if !note.flavorNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("フレーバーノート")
                            .font(.headline)
                            .foregroundColor(.primary)

                        FlavorTagView(tags: note.flavorNotes, selectedTags: Set(note.flavorNotes))
                    }
                    .padding(.horizontal)
                }

                // Comments
                if let comment = note.comment, !comment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("カフェメモ・感想")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(comment)
                            .font(.body)
                            .lineSpacing(6)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.secondary.opacity(0.08))
                            )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("カフェログ詳細")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


struct TasteScoreItem: View {
    let label: String
    let score: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("\(score)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.amberAccent)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        TastingNoteDetailView(
            note: CafeVisitNote(
                userId: UUID(),
                cafeName: "Blue Bottle Coffee 清澄白河",
                address: "東京都江東区平野1-4-8",
                drinkName: "シングルオリジン ハンドドリップ",
                brewMethod: "ハンドドリップ",
                roaster: "Blue Bottle Coffee",
                origin: "エチオピア",
                roastLevel: "浅煎り",
                taste: TasteParameter(acidity: 9, sweetness: 7, bitterness: 3, body: 5, aroma: 9),
                flavorNotes: ["フローラル", "ジャスミン", "シトラス", "レモン"],
                comment: "天井が高く開放的な空間。淹れたてのハンドドリップはジャスミンのような香りと果実味が際立つ。"
            )
        )
    }
}
