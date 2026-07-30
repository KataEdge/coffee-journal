import Foundation

public enum AppError: Error, LocalizedError, Equatable {
    case networkError(String)
    case databaseError(String)
    case authenticationRequired
    case authenticationError(String)
    case uploadFailed(String)
    case invalidData
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .databaseError(let message):
            return "データベースエラー: \(message)"
        case .authenticationRequired:
            return "ログインが必要です。"
        case .authenticationError(let message):
            return "認証エラー: \(message)"
        case .uploadFailed(let message):
            return "画像アップロードに失敗しました: \(message)"
        case .invalidData:
            return "無効なデータです。"
        case .unknown(let message):
            return "不明なエラーが発生しました: \(message)"
        }
    }
}
