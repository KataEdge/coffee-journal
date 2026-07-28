import SwiftUI

public struct TastingNoteListView: View {
    @State private var viewModel: TastingNoteListViewModel
    @State private var isShowingCreateSheet = false

    public init(repository: CoffeeRepositoryProtocol) {
        _viewModel = State(initialValue: TastingNoteListViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Roast Level Filter Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "すべて", isSelected: viewModel.selectedRoastFilter == nil) {
                                viewModel.selectedRoastFilter = nil
                            }
                            FilterChip(title: "浅煎り", isSelected: viewModel.selectedRoastFilter == "浅煎り") {
                                viewModel.selectedRoastFilter = "浅煎り"
                            }
                            FilterChip(title: "中煎り", isSelected: viewModel.selectedRoastFilter == "中煎り") {
                                viewModel.selectedRoastFilter = "中煎り"
                            }
                            FilterChip(title: "深煎り", isSelected: viewModel.selectedRoastFilter == "深煎り") {
                                viewModel.selectedRoastFilter = "深煎り"
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }

                    // Main List or Empty State
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if viewModel.filteredNotes.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cup.and.saucer")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("テイスティングノートがありません")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("右下の + ボタンから記録を追加してみましょう")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredNotes) { note in
                                    NavigationLink(destination: TastingNoteDetailView(note: note)) {
                                        TastingNoteCard(note: note)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                        .refreshable {
                            await viewModel.fetchNotes()
                        }
                    }
                }
                .searchable(text: $viewModel.searchQuery, prompt: "豆の名前、焙煎所、フレーバーを検索")

                // Floating Action Button (FAB)
                Button {
                    isShowingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(LinearGradient(colors: [Color.amberAccent, Color(red: 0.75, green: 0.45, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        )
                        .shadow(color: Color.amberAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .padding(24)
            }
            .navigationTitle("Coffee Journal")
            .task {
                await viewModel.fetchNotes()
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                CreateNoteView(repository: PreviewCoffeeRepository())
                    .onDisappear {
                        Task {
                            await viewModel.fetchNotes()
                        }
                    }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.amberAccent : Color.secondary.opacity(0.12))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let mockRepo = PreviewCoffeeRepository(notes: [
        TastingNote(
            userId: UUID(),
            beanName: "エチオピア イルガチェフェ",
            roaster: "Light Up Coffee",
            origin: "エチオピア",
            roastLevel: "浅煎り",
            taste: TasteParameter(acidity: 5, sweetness: 4, bitterness: 2, body: 3, aroma: 5),
            flavorNotes: ["フローラル", "シトラス"],
            comment: "華やかな香りとフルーティーな酸味。"
        ),
        TastingNote(
            userId: UUID(),
            beanName: "マンデリン アチェ",
            roaster: "Kuroneko Coffee",
            origin: "インドネシア",
            roastLevel: "深煎り",
            taste: TasteParameter(acidity: 1, sweetness: 3, bitterness: 5, body: 5, aroma: 4),
            flavorNotes: ["スパイス", "スモーキー", "アーモンド"],
            comment: "重厚なコクとスパイシーな余韻。"
        )
    ])
    TastingNoteListView(repository: mockRepo)
}

