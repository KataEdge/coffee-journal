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

    func testSignInSuccess() async {
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

    func testCompleteOnboarding() async {
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

    func testSignOut() async {
        let profile = UserProfile(id: UUID(), username: "User")
        viewModel.status = .authenticated(profile)
        mockRepository.currentProfile = profile

        await viewModel.signOut()

        XCTAssertEqual(viewModel.status, .unauthenticated)
        XCTAssertNil(mockRepository.currentProfile)
    }
}
