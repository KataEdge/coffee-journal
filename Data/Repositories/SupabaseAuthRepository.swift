#if canImport(Supabase)
import Foundation
import Supabase

public final class SupabaseAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    private let client: SupabaseClient
    private let profilesTable = "profiles"
    private let avatarBucket = "avatars"

    public init(client: SupabaseClient) {
        self.client = client
    }

    public convenience init() {
        let url = URL(string: AppConfig.supabaseURL) ?? URL(string: "https://placeholder.supabase.co")!
        let client = SupabaseClient(supabaseURL: url, supabaseKey: AppConfig.supabaseAnonKey)
        self.init(client: client)
    }

    public func currentUserProfile() async throws -> UserProfile? {
        do {
            guard let user = self.client.auth.currentSession?.user else {
                return nil
            }
            return try await self.fetchOrCreateProfile(for: user.id)
        } catch {
            return nil
        }
    }

    public func signInAnonymously() async throws -> UserProfile {
        do {
            let session = try await client.auth.signInAnonymously()
            return try await fetchOrCreateProfile(for: session.user.id)
        } catch {
            throw AppError.authenticationError("Anonymous sign in failed: \(error.localizedDescription)")
        }
    }

    public func signIn(email: String, password: String) async throws -> UserProfile {
        do {
            let session = try await client.auth.signIn(email: email, password: password)
            return try await fetchOrCreateProfile(for: session.user.id)
        } catch {
            throw AppError.authenticationError("Sign in failed: \(error.localizedDescription)")
        }
    }

    public func signUp(email: String, password: String) async throws -> UserProfile {
        do {
            let response = try await client.auth.signUp(email: email, password: password)
            let userId = response.user.id
            if client.auth.currentSession != nil {
                return try await fetchOrCreateProfile(for: userId)
            }
            return UserProfile(id: userId, username: nil, avatarUrl: nil)
        } catch {
            throw AppError.authenticationError("登録エラー: \(error.localizedDescription)")
        }
    }

    public func updateProfile(username: String?, avatarData: Data?) async throws -> UserProfile {
        do {
            guard let user = client.auth.currentSession?.user else {
                throw AppError.authenticationError("メール認証が完了していません。届いた確認メールのリンクをクリックしてログインしてください。")
            }
            let userId = user.id

            var avatarUrl: String? = nil
            if let avatarData = avatarData, !avatarData.isEmpty {
                let path = "\(userId.uuidString)/avatar.jpg"
                _ = try await client.storage
                    .from(avatarBucket)
                    .upload(
                        path,
                        data: avatarData,
                        options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: true)
                    )
                let publicUrl = try client.storage.from(avatarBucket).getPublicURL(path: path)
                avatarUrl = publicUrl.absoluteString
            } else {
                let existing = try? await fetchProfile(for: userId)
                avatarUrl = existing?.avatarUrl
            }

            let payload = makeProfilePayload(userId: userId, username: username, avatarUrl: avatarUrl)

            let updatedDTO: ProfileDTO = try await client
                .from(profilesTable)
                .upsert(payload)
                .select()
                .single()
                .execute()
                .value

            return updatedDTO.toDomain()
        } catch let appErr as AppError {
            throw appErr
        } catch {
            // Previously this fell back to a client-side-only UserProfile that looked
            // like a successful save, so a rejected write (e.g. an RLS or unique-
            // constraint violation) silently never reached the database — the UI
            // showed the new username until the next login re-fetched the old row.
            throw AppError.databaseError("プロフィールの更新に失敗しました: \(error.localizedDescription)")
        }
    }

    public func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw AppError.authenticationError("Sign out failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Internal Testable Pure Functions

    internal func wrapError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        return AppError.authenticationError(error.localizedDescription)
    }

    internal func makeProfilePayload(userId: UUID, username: String?, avatarUrl: String?) -> [String: String?] {
        var payload: [String: String?] = [
            "id": userId.uuidString,
            "username": username,
            "updated_at": ISO8601DateFormatter().string(from: Date())
        ]
        if let avatarUrl = avatarUrl {
            payload["avatar_url"] = avatarUrl
        }
        return payload
    }

    // MARK: - Private Helpers

    private func fetchProfile(for userId: UUID) async throws -> UserProfile? {
        do {
            let dtos: [ProfileDTO] = try await client
                .from(profilesTable)
                .select()
                .eq("id", value: userId.uuidString)
                .limit(1)
                .execute()
                .value
            return dtos.first?.toDomain()
        } catch {
            return nil
        }
    }

    private func fetchOrCreateProfile(for userId: UUID) async throws -> UserProfile {
        if let existing = try await fetchProfile(for: userId) {
            return existing
        }

        let newProfileDTO = ProfileDTO(id: userId, username: nil, avatarUrl: nil)
        do {
            let insertedDTO: ProfileDTO = try await client
                .from(profilesTable)
                .upsert(newProfileDTO, onConflict: "id")
                .select()
                .single()
                .execute()
                .value
            return insertedDTO.toDomain()
        } catch {
            return UserProfile(id: userId, username: nil, avatarUrl: nil)
        }
    }
}
#endif
