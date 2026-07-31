import Foundation
import SwiftUI

public enum AuthStatus: Equatable, Sendable {
    case unauthenticated
    case authenticating
    case authenticated(UserProfile)
    case onboardingRequired(UserProfile)
}

@Observable
public final class AuthViewModel {
    public var status: AuthStatus = .unauthenticated
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    // Auth Input Fields
    public var email: String = ""
    public var password: String = ""
    public var isSignUpMode: Bool = false
    
    // Onboarding Input Fields
    public var onboardingUsername: String = ""
    public var selectedAvatarData: Data? = nil

    private let authRepository: AuthRepositoryProtocol

    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    @MainActor
    public func checkAuthStatus() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let profile = try await authRepository.currentUserProfile() {
                // If profile has username, directly authenticate. If not, only prompt onboarding once.
                if let username = profile.username, !username.isEmpty {
                    self.status = .authenticated(profile)
                } else {
                    self.status = .onboardingRequired(profile)
                }
            } else {
                self.status = .unauthenticated
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.status = .unauthenticated
        }
    }

    @MainActor
    public func submitAuth() async {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty, !password.isEmpty else {
            errorMessage = "メールアドレスとパスワードを入力してください。"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profile: UserProfile
            if isSignUpMode {
                profile = try await authRepository.signUp(email: email, password: password)
                self.status = .onboardingRequired(profile)
            } else {
                profile = try await authRepository.signIn(email: email, password: password)
                // Existing users with username go directly to authenticated
                if let username = profile.username, !username.isEmpty {
                    self.status = .authenticated(profile)
                } else {
                    self.status = .onboardingRequired(profile)
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func signInAnonymously() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profile = try await authRepository.signInAnonymously()
            if let username = profile.username, !username.isEmpty {
                self.status = .authenticated(profile)
            } else {
                self.status = .onboardingRequired(profile)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func signInWithOAuth(provider: SocialAuthProvider) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profile = try await authRepository.signInWithOAuth(provider: provider)
            if let username = profile.username, !username.isEmpty {
                self.status = .authenticated(profile)
            } else {
                self.status = .onboardingRequired(profile)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func updateProfile(username: String, avatarData: Data?) async {
        guard case .authenticated(let currentProfile) = status else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let nameToSave = username.trimmingCharacters(in: .whitespaces).isEmpty 
            ? (currentProfile.username ?? "コーヒーラバー") 
            : username.trimmingCharacters(in: .whitespaces)

        do {
            let updated = try await authRepository.updateProfile(
                username: nameToSave,
                avatarData: avatarData
            )
            self.status = .authenticated(updated)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func completeOnboarding() async {
        guard case .onboardingRequired(let currentProfile) = status else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let nameToSave = onboardingUsername.trimmingCharacters(in: .whitespaces).isEmpty 
            ? (currentProfile.username ?? "コーヒーラバー") 
            : onboardingUsername.trimmingCharacters(in: .whitespaces)

        do {
            let updated = try await authRepository.updateProfile(
                username: nameToSave,
                avatarData: selectedAvatarData
            )
            self.status = .authenticated(updated)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    @MainActor
    public func skipOnboarding() {
        if case .onboardingRequired(let currentProfile) = status {
            let defaultName = currentProfile.username ?? "コーヒーラバー"
            Task {
                _ = try? await authRepository.updateProfile(username: defaultName, avatarData: nil)
            }
            self.status = .authenticated(UserProfile(id: currentProfile.id, username: defaultName, avatarUrl: currentProfile.avatarUrl))
        }
    }

    @MainActor
    public func signOut() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepository.signOut()
            self.status = .unauthenticated
            self.email = ""
            self.password = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
