import SwiftUI

public struct TastingNoteCard: View {
    public let note: CafeVisitNote

    public init(note: CafeVisitNote) {
        self.note = note
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .foregroundColor(.amberAccent)
                        Text(note.cafeName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }

                    if let address = note.address, !address.isEmpty {
                        Label(address, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Text(note.brewMethod)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.amberAccent.opacity(0.18)))
                    .foregroundColor(.amberAccent)
            }

            HStack(spacing: 6) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(note.drinkName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
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
        note: CafeVisitNote(
            userId: UUID(),
            cafeName: "Blue Bottle Coffee 清澄白河",
            address: "東京都江東区平野1-4-8",
            drinkName: "シングルオリジン ハンドドリップ",
            brewMethod: "ハンドドリップ",
            roaster: "Blue Bottle Coffee",
            origin: "エチオピア",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["フローラル", "ジャスミン", "シトラス"],
            comment: "天井が高く開放的な空間。淹れたてのハンドドリップはジャスミンのような香りが際立つ。"
        )
    )
    .padding()
}
