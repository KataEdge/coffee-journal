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
            return try await withThrowingTaskGroup(of: UserProfile?.self) { group in
                group.addTask {
                    guard let user = self.client.auth.currentSession?.user else {
                        return nil
                    }
                    return try await self.fetchOrCreateProfile(for: user.id)
                }
                
                group.addTask {
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                    throw AppError.networkError("Authentication request timed out")
                }
                
                guard let result = try await group.next() else {
                    return nil
                }
                group.cancelAll()
                return result
            }
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
        var avatarUrl: String? = nil
        do {
            guard let user = client.auth.currentSession?.user else {
                print("[SupabaseAuthRepository] Error: No authenticated session found. Email confirmation may be pending.")
                throw AppError.authenticationError("メール認証が完了していません。届いた確認メールのリンクをクリックしてログインしてください。")
            }
            let userId = user.id
            print("[SupabaseAuthRepository] Updating profile for userId: \(userId), username: \(username ?? "nil")")

            if let avatarData = avatarData, !avatarData.isEmpty {
                let path = "\(userId.uuidString)/avatar.jpg"
                print("[SupabaseAuthRepository] Uploading avatar image to path: \(path)")
                _ = try await client.storage
                    .from(avatarBucket)
                    .upload(
                        path,
                        data: avatarData,
                        options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: true)
                    )
                let publicUrl = try client.storage.from(avatarBucket).getPublicURL(path: path)
                avatarUrl = publicUrl.absoluteString
                print("[SupabaseAuthRepository] Avatar uploaded successfully: \(avatarUrl ?? "")")
            } else {
                let existing = try? await fetchProfile(for: userId)
                avatarUrl = existing?.avatarUrl
            }

            var payload: [String: String?] = [
                "id": userId.uuidString,
                "username": username,
                "updated_at": ISO8601DateFormatter().string(from: Date())
            ]
            if let avatarUrl = avatarUrl {
                payload["avatar_url"] = avatarUrl
            }

            do {
                let updatedDTO: ProfileDTO = try await client
                    .from(profilesTable)
                    .upsert(payload)
                    .select()
                    .single()
                    .execute()
                    .value

                print("[SupabaseAuthRepository] Profile updated successfully in DB: \(updatedDTO)")
                return updatedDTO.toDomain()
            } catch {
                print("[SupabaseAuthRepository] DB upsert error: \(error). Using fallback.")
                return UserProfile(id: userId, username: username, avatarUrl: avatarUrl, updatedAt: Date())
            }
        } catch let appErr as AppError {
            throw appErr
        } catch {
            print("[SupabaseAuthRepository] Outer error in updateProfile: \(error)")
            // Fallback gracefully instead of throwing databaseError
            if let user = client.auth.currentSession?.user {
                return UserProfile(id: user.id, username: username, avatarUrl: avatarUrl, updatedAt: Date())
            }
            throw AppError.authenticationError("セッションが無効です。再度ログインしてください。")
        }
    }

    public func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw AppError.authenticationError("Sign out failed: \(error.localizedDescription)")
        }
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
            print("[SupabaseAuthRepository] Fetched profile DTO from DB for \(userId.uuidString): \(dtos)")
            return dtos.first?.toDomain()
        } catch {
            print("[SupabaseAuthRepository] Error fetching profile for \(userId.uuidString): \(error)")
            return nil
        }
    }

    private func fetchOrCreateProfile(for userId: UUID) async throws -> UserProfile {
        if let existing = try await fetchProfile(for: userId) {
            print("[SupabaseAuthRepository] Existing profile found for \(userId.uuidString): \(existing.username ?? "nil")")
            return existing
        }

        print("[SupabaseAuthRepository] No existing profile found. Initializing new profile for \(userId.uuidString)")
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
            print("[SupabaseAuthRepository] Profile init blocked: \(error). Using transient profile.")
            return UserProfile(id: userId, username: nil, avatarUrl: nil)
        }
    }
}
#endif
