import SwiftUI

public struct TastingNoteDetailView: View {
    public let note: TastingNote

    public init(note: TastingNote) {
        self.note = note
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        RoastLevelBadge(roastLevel: note.roastLevel)
                        Spacer()
                        Text(note.createdAt.formatted(date: .numeric, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text(note.beanName)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)

                    if let roaster = note.roaster {
                        Text(roaster)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }

                    if let origin = note.origin {
                        Label(origin, systemImage: "globe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                        Text("テイスティングメモ")
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
        .navigationTitle("ノート詳細")
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
            note: TastingNote(
                userId: UUID(),
                beanName: "エチオピア イルガチェフェ G1",
                roaster: "Coffee Roasters Tokyo",
                origin: "エチオピア",
                roastLevel: "浅煎り (Light)",
                taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
                flavorNotes: ["フローラル", "ジャスミン", "シトラス", "レモン"],
                comment: "フローラルで華やかな香りと、澄んだ果実味が特徴的。冷めるとよりレモンのような甘酸っぱさが際立つ。"
            )
        )
    }
}
