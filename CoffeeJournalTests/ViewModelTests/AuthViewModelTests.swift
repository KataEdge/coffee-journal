import XCTest
@testable import CoffeeJournalCore

final class AuthViewModelTests: XCTestCase {
    private var mockRepository: MockAuthRepository!
    private var viewModel: AuthViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockAuthRepository()
        viewModel = AuthViewModel(authRepository: mockRepository)
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }

    func testInitialStateIsUnauthenticated() {
        XCTAssertEqual(viewModel.status, .unauthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testCheckAuthStatusNoUser() async {
        mockRepository.currentProfile = nil
        await viewModel.checkAuthStatus()
        XCTAssertEqual(viewModel.status, .unauthenticated)
    }

    func testCheckAuthStatusWithUserWithoutUsername() async {
        let profile = UserProfile(id: UUID(), username: nil, avatarUrl: nil)
        mockRepository.currentProfile = profile
        await viewModel.checkAuthStatus()
        XCTAssertEqual(viewModel.status, .onboardingRequired(profile))
    }

    func testCheckAuthStatusWithUserWithUsername() async {
        let profile = UserProfile(id: UUID(), username: "CoffeeLover", avatarUrl: "https://example.com/avatar.jpg")
        mockRepository.currentProfile = profile
        await viewModel.checkAuthStatus()
        XCTAssertEqual(viewModel.status, .authenticated(profile))
    }

    func testCheckAuthStatusError() async {
        mockRepository.shouldFail = true
        await viewModel.checkAuthStatus()
        XCTAssertEqual(viewModel.status, .unauthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSubmitAuthEmptyValidation() async {
        viewModel.email = "   "
        viewModel.password = ""
        await viewModel.submitAuth()
        XCTAssertEqual(viewModel.errorMessage, "メールアドレスとパスワードを入力してください。")
    }

    func testSignInAnonymouslySuccess() async {
        await viewModel.signInAnonymously()
        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "Guest User")
        } else if case .onboardingRequired(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "Guest User")
        } else {
            XCTFail("Expected authenticated or onboardingRequired status after anonymous sign in")
        }
    }

    func testSignInAnonymouslyFailure() async {
        mockRepository.shouldFail = true
        await viewModel.signInAnonymously()
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSignInWithOAuthSuccessExistingUser() async {
        mockRepository.oauthProfileUsername = "Google User"

        await viewModel.signInWithOAuth(provider: .google)

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "Google User")
        } else {
            XCTFail("Expected authenticated status after OAuth sign in with existing username")
        }
    }

    func testSignInWithOAuthSuccessNewUserRequiresOnboarding() async {
        mockRepository.oauthProfileUsername = nil

        await viewModel.signInWithOAuth(provider: .apple)

        if case .onboardingRequired(let profile) = viewModel.status {
            XCTAssertNil(profile.username)
        } else {
            XCTFail("Expected onboardingRequired status when OAuth profile has no username")
        }
    }

    func testSignInWithOAuthFailure() async {
        mockRepository.shouldFail = true

        await viewModel.signInWithOAuth(provider: .google)

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSignInSuccessExistingUser() async {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.isSignUpMode = false

        await viewModel.submitAuth()

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "test")
        } else {
            XCTFail("Expected authenticated status after sign in")
        }
    }

    func testSignInSuccessWithoutUsernameRequiresOnboarding() async {
        viewModel.email = "@example.com"
        viewModel.password = "password123"
        viewModel.isSignUpMode = false

        await viewModel.submitAuth()

        if case .onboardingRequired(let profile) = viewModel.status {
            XCTAssertTrue(profile.username?.isEmpty ?? true)
        } else {
            XCTFail("Expected onboardingRequired status when signed-in profile has no username")
        }
    }

    func testSignInFailure() async {
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        viewModel.isSignUpMode = false
        mockRepository.shouldFail = true

        await viewModel.submitAuth()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testSignUpSuccess() async {
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.isSignUpMode = true

        await viewModel.submitAuth()

        if case .onboardingRequired = viewModel.status {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected onboardingRequired status after sign up")
        }
    }

    func testSignUpFailure() async {
        viewModel.email = "newuser@example.com"
        viewModel.password = "password123"
        viewModel.isSignUpMode = true
        mockRepository.shouldFail = true

        await viewModel.submitAuth()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testUpdateProfileSuccess() async {
        let initialProfile = UserProfile(id: UUID(), username: "OldName")
        viewModel.status = .authenticated(initialProfile)
        mockRepository.currentProfile = initialProfile

        let dummyData = "image".data(using: .utf8)
        await viewModel.updateProfile(username: "NewName", avatarData: dummyData)

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "NewName")
            XCTAssertNotNil(profile.avatarUrl)
        } else {
            XCTFail("Expected authenticated status")
        }
    }

    func testUpdateProfileEmptyUsernameFallback() async {
        let initialProfile = UserProfile(id: UUID(), username: "OriginalName")
        viewModel.status = .authenticated(initialProfile)
        mockRepository.currentProfile = initialProfile

        await viewModel.updateProfile(username: "   ", avatarData: nil)

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "OriginalName")
        } else {
            XCTFail("Expected authenticated status")
        }
    }

    func testUpdateProfileNilUsernameFallbackToDefault() async {
        let initialProfile = UserProfile(id: UUID(), username: nil)
        viewModel.status = .authenticated(initialProfile)
        mockRepository.currentProfile = initialProfile

        await viewModel.updateProfile(username: "   ", avatarData: nil)

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "コーヒーラバー")
        } else {
            XCTFail("Expected authenticated status with default name")
        }
    }

    func testUpdateProfileFailure() async {
        let initialProfile = UserProfile(id: UUID(), username: "OldName")
        viewModel.status = .authenticated(initialProfile)
        mockRepository.currentProfile = initialProfile
        mockRepository.shouldFail = true

        await viewModel.updateProfile(username: "NewName", avatarData: nil)

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testUpdateProfileWhenNotAuthenticatedDoesNothing() async {
        viewModel.status = .unauthenticated
        await viewModel.updateProfile(username: "NewName", avatarData: nil)
        XCTAssertEqual(viewModel.status, .unauthenticated)
    }

    func testCompleteOnboardingSuccess() async {
        let initialProfile = UserProfile(id: UUID(), username: nil)
        viewModel.status = .onboardingRequired(initialProfile)
        mockRepository.currentProfile = initialProfile
        viewModel.onboardingUsername = "TaroCoffee"

        await viewModel.completeOnboarding()

        if case .authenticated(let updatedProfile) = viewModel.status {
            XCTAssertEqual(updatedProfile.username, "TaroCoffee")
        } else {
            XCTFail("Expected authenticated status after completing onboarding")
        }
    }

    func testCompleteOnboardingEmptyUsernameFallback() async {
        let initialProfile = UserProfile(id: UUID(), username: nil)
        viewModel.status = .onboardingRequired(initialProfile)
        mockRepository.currentProfile = initialProfile
        viewModel.onboardingUsername = "   "

        await viewModel.completeOnboarding()

        if case .authenticated(let updatedProfile) = viewModel.status {
            XCTAssertEqual(updatedProfile.username, "コーヒーラバー")
        } else {
            XCTFail("Expected authenticated status after completing onboarding")
        }
    }

    func testCompleteOnboardingFailure() async {
        let initialProfile = UserProfile(id: UUID(), username: nil)
        viewModel.status = .onboardingRequired(initialProfile)
        mockRepository.currentProfile = initialProfile
        mockRepository.shouldFail = true

        await viewModel.completeOnboarding()

        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testCompleteOnboardingWhenNotRequiredDoesNothing() async {
        viewModel.status = .unauthenticated
        await viewModel.completeOnboarding()
        XCTAssertEqual(viewModel.status, .unauthenticated)
    }

    @MainActor
    func testSkipOnboarding() async {
        let initialProfile = UserProfile(id: UUID(), username: nil)
        viewModel.status = .onboardingRequired(initialProfile)
        mockRepository.currentProfile = initialProfile

        viewModel.skipOnboarding()

        if case .authenticated(let profile) = viewModel.status {
            XCTAssertEqual(profile.username, "コーヒーラバー")
        } else {
            XCTFail("Expected authenticated status after skipping onboarding")
        }
    }

    func testSignOutSuccess() async {
        let profile = UserProfile(id: UUID(), username: "User")
        viewModel.status = .authenticated(profile)
        mockRepository.currentProfile = profile

        await viewModel.signOut()

        XCTAssertEqual(viewModel.status, .unauthenticated)
        XCTAssertNil(mockRepository.currentProfile)
    }

    func testSignOutFailure() async {
        let profile = UserProfile(id: UUID(), username: "User")
        viewModel.status = .authenticated(profile)
        mockRepository.currentProfile = profile
        mockRepository.shouldFail = true

        await viewModel.signOut()

        XCTAssertNotNil(viewModel.errorMessage)
    }
}
