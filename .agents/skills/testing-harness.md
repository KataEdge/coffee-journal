# Testing Harness Guidelines

## Unit Testing Principles
- Decouple Views, ViewModels, and UseCases using Protocols.
- Every Repository must have a corresponding Mock implementation under `CoffeeJournalTests/Mocks/`.
- Test UseCases and ViewModels for success paths, error paths, and edge cases.
- Use `async/await` test methods with `XCTest`.

## Mock Creation Rule
- Mocks should support configurable return values or errors.
- Track call counts and passed arguments for assertion verification.
- Example:
  ```swift
  final class MockCoffeeRepository: CoffeeRepositoryProtocol {
      var fetchNotesResult: Result<[TastingNote], Error> = .success([])
      private(set) var fetchNotesCallCount = 0

      func fetchTastingNotes() async throws -> [TastingNote] {
          fetchNotesCallCount += 1
          return try fetchNotesResult.get()
      }
  }
  ```
