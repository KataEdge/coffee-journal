import XCTest
@testable import CoffeeJournalCore

final class MockAuthRepositoryTests: XCTestCase {

    func test_mockAuthRepository_updateProfileErrorWhenNoProfile() async {
        let repo = MockAuthRepository(currentProfile: nil)

        do {
            _ = try await repo.updateProfile(username: "Test", avatarData: nil)
            XCTFail("Should throw error when currentProfile is nil")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_mockAuthRepository_allFailureBranches() async {
        let repo = MockAuthRepository()
        repo.shouldFail = true

        do {
            _ = try await repo.currentUserProfile()
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            _ = try await repo.signInAnonymously()
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            _ = try await repo.signIn(email: "a@b.com", password: "p")
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            _ = try await repo.signUp(email: "a@b.com", password: "p")
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            _ = try await repo.updateProfile(username: "a", avatarData: nil)
        } catch {
            XCTAssertTrue(error is AppError)
        }

        do {
            try await repo.signOut()
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_mockAuthRepository_customError_isThrownInsteadOfDefault() async {
        let repo = MockAuthRepository()
        repo.shouldFail = true
        let customError = NSError(domain: "test", code: 42, userInfo: [NSLocalizedDescriptionKey: "Custom failure"])
        repo.customError = customError

        do {
            _ = try await repo.signIn(email: "a@b.com", password: "p")
            XCTFail("Should throw the configured custom error")
        } catch {
            XCTAssertEqual((error as NSError).code, 42)
        }
    }
}
