import SwiftUI

public struct TastingNoteCard: View {
    public let note: TastingNote

    public init(note: TastingNote) {
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.beanName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    if let roaster = note.roaster, !roaster.isEmpty {
                        Text(roaster)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                RoastLevelBadge(roastLevel: note.roastLevel)
            }

            if let origin = note.origin, !origin.isEmpty {
                Label(origin, systemImage: "globe")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 16) {
                TasteRadarChart(taste: note.taste)
                    .frame(width: 130, height: 110)

                VStack(alignment: .leading, spacing: 8) {
                    if !note.flavorNotes.isEmpty {
                        FlavorTagView(tags: Array(note.flavorNotes.prefix(3)))
                    }

                    if let comment = note.comment, !comment.isEmpty {
                        Text(comment)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    TastingNoteCard(
        note: TastingNote(
            userId: UUID(),
            beanName: "エチオピア イルガチェフェ",
            roaster: "Blue Bottle Coffee",
            origin: "エチオピア シダモ",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["フローラル", "ジャスミン", "シトラス"],
            comment: "とても華やかな香りで、すっきりとした酸味が心地よい。"
        )
    )
    .padding()
}
