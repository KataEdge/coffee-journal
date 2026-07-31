import Foundation

public final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    public var currentProfile: UserProfile?
    public var shouldFail: Bool = false
    public var customError: Error?
    public var oauthProfileUsername: String? = "OAuth User"

    public init(currentProfile: UserProfile? = nil) {
        self.currentProfile = currentProfile
    }

    public func currentUserProfile() async throws -> UserProfile? {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Failed to fetch user profile.")
        }
        return currentProfile
    }

    public func signInAnonymously() async throws -> UserProfile {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Anonymous sign in failed.")
        }
        let profile = UserProfile(id: UUID(), username: "Guest User", avatarUrl: nil)
        self.currentProfile = profile
        return profile
    }

    public func signIn(email: String, password: String) async throws -> UserProfile {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Invalid credentials.")
        }
        let profile = UserProfile(id: UUID(), username: email.components(separatedBy: "@").first ?? "User", avatarUrl: nil)
        self.currentProfile = profile
        return profile
    }

    public func signUp(email: String, password: String) async throws -> UserProfile {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Sign up failed.")
        }
        let profile = UserProfile(id: UUID(), username: nil, avatarUrl: nil)
        self.currentProfile = profile
        return profile
    }

    public func signInWithOAuth(provider: SocialAuthProvider) async throws -> UserProfile {
        if shouldFail {
            throw customError ?? AppError.authenticationError("OAuth sign in failed.")
        }
        let profile = UserProfile(id: UUID(), username: oauthProfileUsername, avatarUrl: nil)
        self.currentProfile = profile
        return profile
    }

    public func updateProfile(username: String?, avatarData: Data?) async throws -> UserProfile {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Update profile failed.")
        }
        guard let current = currentProfile else {
            throw AppError.authenticationError("No authenticated user.")
        }
        
        var newAvatarUrl = current.avatarUrl
        if let avatarData = avatarData, !avatarData.isEmpty {
            // Mock URL for uploaded image
            newAvatarUrl = "https://example.com/avatars/\(current.id.uuidString).jpg"
        }

        let updated = UserProfile(
            id: current.id,
            username: username ?? current.username,
            avatarUrl: newAvatarUrl,
            updatedAt: Date()
        )
        self.currentProfile = updated
        return updated
    }

    public func signOut() async throws {
        if shouldFail {
            throw customError ?? AppError.authenticationError("Sign out failed.")
        }
        self.currentProfile = nil
    }
}
