import SwiftUI

public struct TastingNoteListView: View {
    private let repository: CoffeeRepositoryProtocol
    private let userId: UUID
    @State private var viewModel: TastingNoteListViewModel
    @State private var isShowingCreateSheet = false

    public init(repository: CoffeeRepositoryProtocol, userId: UUID) {
        self.repository = repository
        self.userId = userId
        _viewModel = State(initialValue: TastingNoteListViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Brew Method Filter Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "すべて", isSelected: viewModel.selectedBrewMethodFilter == nil) {
                                viewModel.selectedBrewMethodFilter = nil
                            }
                            FilterChip(title: "ハンドドリップ", isSelected: viewModel.selectedBrewMethodFilter == "ハンドドリップ") {
                                viewModel.selectedBrewMethodFilter = "ハンドドリップ"
                            }
                            FilterChip(title: "エスプレッソ・ラテ", isSelected: viewModel.selectedBrewMethodFilter == "エスプレッソ・ラテ") {
                                viewModel.selectedBrewMethodFilter = "エスプレッソ・ラテ"
                            }
                            FilterChip(title: "水出し", isSelected: viewModel.selectedBrewMethodFilter == "水出し") {
                                viewModel.selectedBrewMethodFilter = "水出し"
                            }
                            FilterChip(title: "フレンチプレス", isSelected: viewModel.selectedBrewMethodFilter == "フレンチプレス") {
                                viewModel.selectedBrewMethodFilter = "フレンチプレス"
                            }
                            FilterChip(title: "サイフォン", isSelected: viewModel.selectedBrewMethodFilter == "サイフォン") {
                                viewModel.selectedBrewMethodFilter = "サイフォン"
                            }
                            FilterChip(title: "エアロプレス", isSelected: viewModel.selectedBrewMethodFilter == "エアロプレス") {
                                viewModel.selectedBrewMethodFilter = "エアロプレス"
                            }
                            FilterChip(title: "その他", isSelected: viewModel.selectedBrewMethodFilter == "その他") {
                                viewModel.selectedBrewMethodFilter = "その他"
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
                            Image(systemName: "building.2.crop.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("カフェ訪問記録がありません")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("右下の + ボタンから新しいカフェログを追加してみましょう")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.filteredNotes) { note in
                                NavigationLink(destination: TastingNoteDetailView(
                                    note: note,
                                    repository: repository,
                                    onNoteUpdated: { updated in
                                        if let index = viewModel.notes.firstIndex(where: { $0.id == updated.id }) {
                                            viewModel.notes[index] = updated
                                        }
                                    },
                                    onNoteDeleted: { deletedId in
                                        viewModel.notes.removeAll { $0.id == deletedId }
                                    }
                                )) {
                                    TastingNoteCard(note: note)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task {
                                            await viewModel.deleteNote(id: note.id)
                                        }
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.fetchNotes()
                        }
                    }
                }
                .searchable(text: $viewModel.searchQuery, prompt: "カフェ名、場所、ドリンク名、メモを検索")

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
            .navigationTitle("Cafe Journal")
            .task {
                await viewModel.fetchNotes()
            }
            .sheet(isPresented: $isShowingCreateSheet) {
                CreateNoteView(repository: repository, userId: userId)
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
    TastingNoteListView(repository: PreviewCoffeeRepository.sample, userId: UUID())
}

