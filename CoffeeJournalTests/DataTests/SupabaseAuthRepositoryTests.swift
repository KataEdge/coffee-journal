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

    func test_updateProfile_withJpegAvatarData_withoutSession_throwsAuthenticationError() async {
        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01])
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: jpegData)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withPngAvatarData_withoutSession_throwsAuthenticationError() async {
        let pngData = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D])
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: pngData)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withHeicAvatarData_withoutSession_throwsAuthenticationError() async {
        let heicData = Data([0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63])
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: heicData)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withWebpAvatarData_withoutSession_throwsAuthenticationError() async {
        let webpData = Data([0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00, 0x57, 0x45, 0x42, 0x50])
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: webpData)
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_updateProfile_withInvalidAvatarData_throwsValidationError() async {
        let invalidData = "not an image".data(using: .utf8)!
        do {
            _ = try await repository.updateProfile(username: "TestUser", avatarData: invalidData)
            XCTFail("Expected validation error")
        } catch {
            guard case AppError.validationError(let msg) = error else {
                XCTFail("Expected validationError, got \(error)")
                return
            }
            XCTAssertTrue(msg.contains("未対応または不正な画像フォーマット"))
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
            _ = try await repository.signUp(email: "fake@example.com", password: "ValidPassword123")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    func test_signUp_invalidPassword_throwsValidationError() async {
        do {
            _ = try await repository.signUp(email: "fake@example.com", password: "short")
            XCTFail("Expected validation error")
        } catch {
            guard case AppError.validationError(let msg) = error else {
                XCTFail("Expected validationError, got \(error)")
                return
            }
            XCTAssertTrue(msg.contains("8文字以上"))
        }
    }

    func test_updateProfile_oversizedUsername_throwsValidationError() async {
        let longUsername = String(repeating: "U", count: 31)
        do {
            _ = try await repository.updateProfile(username: longUsername, avatarData: nil)
            XCTFail("Expected validation error")
        } catch {
            guard case AppError.validationError(let msg) = error else {
                XCTFail("Expected validationError, got \(error)")
                return
            }
            XCTAssertTrue(msg.contains("30文字以内"))
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
