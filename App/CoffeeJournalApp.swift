import SwiftUI
#if canImport(CoffeeJournalCore)
import CoffeeJournalCore
#endif

@main
struct CoffeeJournalApp: App {
    @State private var repository: CoffeeRepositoryProtocol = PreviewCoffeeRepository.sample

    var body: some Scene {
        WindowGroup {
            MainTabView(repository: repository)
        }
    }
}
