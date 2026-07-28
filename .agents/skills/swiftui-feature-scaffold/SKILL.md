---
name: swiftui-feature-scaffold
description: Scaffolds or updates end-to-end features for CoffeeJournal across Domain (Entities & Repositories), Presentation (@Observable ViewModels & SwiftUI Views), and Test layers (Mocks & XCTest suites).
---

# SwiftUI Feature Scaffold Guidelines (CoffeeJournal)

When creating or extending a feature in CoffeeJournal, follow this end-to-end scaffolding process to maintain clean architecture, high visual quality, and test coverage.

---

## Scaffolding Steps

### 1. Domain Layer (`Domain/`)
- **Entity**: Define immutable structs in `Domain/Entities/<EntityName>.swift` with `Identifiable` and `Codable` conformance.
- **Repository Protocol**: Define the data access interface in `Domain/Repositories/<EntityName>RepositoryProtocol.swift` using Swift `async/await`.

### 2. Presentation Layer (`Presentation/`)
- **ViewModel**: Create `@Observable` ViewModels in `Presentation/ViewModels/<FeatureName>ViewModel.swift`.
  - Inject dependencies via initializer protocols (`repository: <EntityName>RepositoryProtocol`).
  - Keep logic decoupled from SwiftUI views.
- **SwiftUI View**: Create modular views in `Presentation/Views/<FeatureName>View.swift`.
  - Apply adaptive colors, glassmorphism (`.background(.ultraThinMaterial)`), and smooth animations.
  - Provide a `#Preview` macro using Mock data implementations.
- **Components**: Export reusable UI widgets to `Presentation/Components/`.

### 3. Test Layer (`CoffeeJournalTests/`)
- **Mock Repository**: Implement configurable mocks under `CoffeeJournalTests/Mocks/Mock<EntityName>Repository.swift`.
  - Support success/failure `Result` states and track call counts.
- **Unit Test**: Create test suites under `CoffeeJournalTests/ViewModelTests/<FeatureName>ViewModelTests.swift` or `UseCaseTests/`.
  - Validate state changes, async operations, search/filtering, and error handling.

---

## Quick Reference Templates

### Domain Entity & Repository Protocol
```swift
// Domain/Entities/CoffeeBean.swift
import Foundation

public struct CoffeeBean: Identifiable, Equatable, Sendable, Codable {
    public let id: UUID
    public var name: String
    public var origin: String
    
    public init(id: UUID = UUID(), name: String, origin: String) {
        self.id = id
        self.name = name
        self.origin = origin
    }
}

// Domain/Repositories/CoffeeBeanRepositoryProtocol.swift
import Foundation

public protocol CoffeeBeanRepositoryProtocol: Sendable {
    func fetchBeans() async throws -> [CoffeeBean]
    func addBean(_ bean: CoffeeBean) async throws
}
```

### Presentation ViewModel & View
```swift
// Presentation/ViewModels/CoffeeBeanListViewModel.swift
import Foundation

@Observable
public final class CoffeeBeanListViewModel {
    public var beans: [CoffeeBean] = []
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let repository: CoffeeBeanRepositoryProtocol
    
    public init(repository: CoffeeBeanRepositoryProtocol) {
        self.repository = repository
    }
    
    public func loadBeans() async {
        isLoading = true
        defer { isLoading = false }
        do {
            beans = try await repository.fetchBeans()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// Presentation/Views/CoffeeBeanListView.swift
import SwiftUI

public struct CoffeeBeanListView: View {
    @State private var viewModel: CoffeeBeanListViewModel
    
    public init(viewModel: CoffeeBeanListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            List(viewModel.beans) { bean in
                VStack(alignment: .leading) {
                    Text(bean.name).font(.headline)
                    Text(bean.origin).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Coffee Beans")
            .task {
                await viewModel.loadBeans()
            }
        }
    }
}

#Preview {
    CoffeeBeanListView(viewModel: CoffeeBeanListViewModel(repository: MockCoffeeBeanRepository()))
}
```

### Mock & Unit Test
```swift
// CoffeeJournalTests/Mocks/MockCoffeeBeanRepository.swift
import Foundation
@testable import CoffeeJournalCore

final class MockCoffeeBeanRepository: CoffeeBeanRepositoryProtocol {
    var beansResult: Result<[CoffeeBean], Error> = .success([])
    private(set) var fetchBeansCallCount = 0
    
    func fetchBeans() async throws -> [CoffeeBean] {
        fetchBeansCallCount += 1
        return try beansResult.get()
    }
    
    func addBean(_ bean: CoffeeBean) async throws {}
}

// CoffeeJournalTests/ViewModelTests/CoffeeBeanListViewModelTests.swift
import XCTest
@testable import CoffeeJournalCore

final class CoffeeBeanListViewModelTests: XCTestCase {
    func testLoadBeansSuccess() async {
        let mockBean = CoffeeBean(name: "Geisha", origin: "Panama")
        let repo = MockCoffeeBeanRepository()
        repo.beansResult = .success([mockBean])
        
        let vm = CoffeeBeanListViewModel(repository: repo)
        await vm.loadBeans()
        
        XCTAssertEqual(vm.beans.count, 1)
        XCTAssertEqual(vm.beans.first?.name, "Geisha")
        XCTAssertEqual(repo.fetchBeansCallCount, 1)
    }
}
```
