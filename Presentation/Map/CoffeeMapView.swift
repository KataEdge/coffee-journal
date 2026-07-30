import SwiftUI
import MapKit
import CoreLocation

public struct CoffeeMapView: View {
    private let repository: CoffeeRepositoryProtocol
    @State private var viewModel: CoffeeMapViewModel

    public init(repository: CoffeeRepositoryProtocol) {
        self.repository = repository
        _viewModel = State(initialValue: CoffeeMapViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Map(position: $viewModel.position) {
                    UserAnnotation()

                    ForEach(viewModel.notesWithLocation) { note in
                        Annotation(
                            note.cafeName,
                            coordinate: CLLocationCoordinate2D(latitude: note.latitude!, longitude: note.longitude!)
                        ) {
                            Button {
                                viewModel.selectNote(note)
                            } label: {
                                MapAnnotationPin(
                                    title: note.cafeName,
                                    isSelected: viewModel.selectedNote?.id == note.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }

                // Upper right current location button
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.moveToUserLocation()
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .foregroundColor(.amberAccent)
                                .padding(12)
                                .background(.thinMaterial)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                    Spacer()
                }

                // Empty State Overlay when no locations are pinned
                if !viewModel.isLoading && viewModel.notesWithLocation.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "map")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("位置情報つきの記録がありません")
                            .font(.headline)
                        Text("新規記録を作成する際にカフェの位置情報を登録すると、マップ上に表示されます。")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(24)
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 8)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Bottom card for selected note preview
                if let selectedNote = viewModel.selectedNote {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                viewModel.selectNote(nil)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.trailing, 24)

                        NavigationLink(destination: TastingNoteDetailView(note: selectedNote)) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedNote.cafeName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(selectedNote.drinkName)
                                        .font(.subheadline)
                                        .foregroundColor(.amberAccent)
                                    if let address = selectedNote.address {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .background(.regularMaterial)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.amberAccent.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("カフェマップ")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task {
                await viewModel.fetchNotes()
            }
            .refreshable {
                await viewModel.fetchNotes()
            }
        }
    }
}

struct MapAnnotationPin: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.amberAccent : Color.amberAccent.opacity(0.85))
                    .frame(width: isSelected ? 40 : 32, height: isSelected ? 40 : 32)
                    .shadow(color: isSelected ? Color.amberAccent.opacity(0.6) : .black.opacity(0.2), radius: isSelected ? 8 : 4)

                Image(systemName: "cup.and.saucer.fill")
                    .font(isSelected ? .system(size: 18, weight: .bold) : .system(size: 14))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.thinMaterial)
                .cornerRadius(4)
                .shadow(radius: 2)
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    CoffeeMapView(repository: PreviewCoffeeRepository.sample)
}
