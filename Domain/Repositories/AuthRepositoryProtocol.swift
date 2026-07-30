import Foundation

public protocol AuthRepositoryProtocol: Sendable {
    /// 現在のログインユーザープロファイルを取得（未ログイン時は nil）
    func currentUserProfile() async throws -> UserProfile?

    /// 匿名（ゲスト）サインイン
    func signInAnonymously() async throws -> UserProfile

    /// メールアドレスとパスワードでサインイン
    func signIn(email: String, password: String) async throws -> UserProfile

    /// メールアドレスとパスワードで新規サインアップ
    func signUp(email: String, password: String) async throws -> UserProfile

    /// ユーザープロファイル（ユーザー名およびアバター画像データ）を更新
    func updateProfile(username: String?, avatarData: Data?) async throws -> UserProfile

    /// サインアウト
    func signOut() async throws
}

