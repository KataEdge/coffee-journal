import SwiftUI

public struct TastingNoteDetailView: View {
    @State private var note: CafeVisitNote
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteConfirm = false
    @Environment(\.dismiss) private var dismiss

    private let repository: CoffeeRepositoryProtocol
    private let onNoteUpdated: (CafeVisitNote) -> Void
    private let onNoteDeleted: (UUID) -> Void

    public init(
        note: CafeVisitNote,
        repository: CoffeeRepositoryProtocol,
        onNoteUpdated: @escaping (CafeVisitNote) -> Void = { _ in },
        onNoteDeleted: @escaping (UUID) -> Void = { _ in }
    ) {
        _note = State(initialValue: note)
        self.repository = repository
        self.onNoteUpdated = onNoteUpdated
        self.onNoteDeleted = onNoteDeleted
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isShowingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            CreateNoteView(repository: repository, existingNote: note) { updated in
                note = updated
                onNoteUpdated(updated)
            }
        }
        .confirmationDialog("このカフェログを削除しますか？", isPresented: $isShowingDeleteConfirm, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                Task {
                    do {
                        try await repository.deleteTastingNote(id: note.id)
                        onNoteDeleted(note.id)
                        dismiss()
                    } catch {
                        // Deletion failures surface as a no-op here; the note remains in the list for retry.
                    }
                }
            }
            Button("キャンセル", role: .cancel) {}
        }
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
                taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
                flavorNotes: ["フローラル", "ジャスミン", "シトラス", "レモン"],
                comment: "天井が高く開放的な空間。淹れたてのハンドドリップはジャスミンのような香りと果実味が際立つ。"
            ),
            repository: PreviewCoffeeRepository.sample
        )
    }
}
