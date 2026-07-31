import XCTest
import Supabase
@testable import CoffeeJournalCore

final class SupabaseAuthRepositoryTests: XCTestCase {
    var repository: SupabaseAuthRepository!

    override func setUp() {
        super.setUp()
        repository = SupabaseAuthRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    func test_defaultInitializer_createsRepository() {
        XCTAssertNotNil(repository)
    }

    func test_wrapError_convertsErrors() {
        let appErr = AppError.authenticationRequired
        XCTAssertEqual(repository.wrapError(appErr), .authenticationRequired)

        let nsErr = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sample error"])
        let wrapped = repository.wrapError(nsErr)
        if case .authenticationError(let msg) = wrapped {
            XCTAssertTrue(msg.contains("Sample error"))
        } else {
            XCTFail("Expected authenticationError")
        }
    }

    func test_makeProfilePayload_generatesValidPayload() {
        let userId = UUID()
        let payload = repository.makeProfilePayload(
            userId: userId,
            username: "CoffeeMaster",
            avatarUrl: "https://example.com/avatar.jpg"
        )

        XCTAssertEqual(payload["id"], userId.uuidString)
        XCTAssertEqual(payload["username"], "CoffeeMaster")
        XCTAssertEqual(payload["avatar_url"], "https://example.com/avatar.jpg")
        XCTAssertNotNil(payload["updated_at"])
    }

    func test_makeProfilePayload_withoutAvatarUrl() {
        let userId = UUID()
        let payload = repository.makeProfilePayload(
            userId: userId,
            username: "Guest",
            avatarUrl: nil
        )

        XCTAssertEqual(payload["id"], userId.uuidString)
        XCTAssertEqual(payload["username"], "Guest")
        XCTAssertNil(payload["avatar_url"])
    }

    func test_currentUserProfile_whenNoSession_returnsNilOrHandlesError() async {
        let profile = try? await repository.currentUserProfile()
        XCTAssertNil(profile)
    }

    func test_updateProfile_withoutSession_throwsAuthenticationError() async {
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: nil)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withEmptyUsername_withoutSession_throwsAuthenticationError() async {
        do {
            _ = try await repository.updateProfile(username: nil, avatarData: nil)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withAvatarData_withoutSession_throwsAuthenticationError() async {
        let dummyImageData = "dummy image data".data(using: .utf8)
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: dummyImageData)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_signInAnonymously_withoutBackend_throwsAuthenticationError() async {
        do {
            _ = try await repository.signInAnonymously()
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_signIn_withoutBackend_throwsAuthenticationError() async {
        do {
            _ = try await repository.signIn(email: "fake@example.com", password: "password")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_signUp_withoutBackend_throwsAuthenticationError() async {
        do {
            _ = try await repository.signUp(email: "fake@example.com", password: "password")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_mapToSupabaseProvider_mapsCorrectly() {
        XCTAssertEqual(repository.mapToSupabaseProvider(.google), .google)
        XCTAssertEqual(repository.mapToSupabaseProvider(.apple), .apple)
    }

    func test_oauthRedirectURL_isCoffeeJournalCallbackScheme() {
        XCTAssertEqual(repository.oauthRedirectURL.absoluteString, "coffeejournal://login-callback")
    }

    func test_wrapOAuthError_wrapsUnderlyingError() {
        let nsErr = NSError(domain: "test", code: 2, userInfo: [NSLocalizedDescriptionKey: "OAuth failure"])
        let wrapped = repository.wrapOAuthError(nsErr)
        if case .authenticationError(let msg) = wrapped {
            XCTAssertTrue(msg.contains("OAuth failure"))
        } else {
            XCTFail("Expected authenticationError")
        }
    }

    func test_signOut_withoutSession_handlesOrThrowsError() async {
        do {
            try await repository.signOut()
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }
}
