import SwiftUI

public struct MainTabView: View {
    private let repository: CoffeeRepositoryProtocol

    public init(repository: CoffeeRepositoryProtocol) {
        self.repository = repository
    }

    public var body: some View {
        TabView {
            TastingNoteListView(repository: repository)
                .tabItem {
                    Label("ログ一覧", systemImage: "list.bullet")
                }

            CoffeeMapView(repository: repository)
                .tabItem {
                    Label("マップ", systemImage: "map")
                }
        }
        .tint(.amberAccent)
    }
}

#Preview {
    MainTabView(repository: PreviewCoffeeRepository.sample)
}
