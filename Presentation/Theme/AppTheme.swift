import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable, Sendable {
    case amber
    case forest
    case ocean
    case berry
    case slate

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .amber: return "アンバー"
        case .forest: return "フォレスト"
        case .ocean: return "オーシャン"
        case .berry: return "ベリー"
        case .slate: return "スレート"
        }
    }

    public var color: Color {
        switch self {
        case .amber: return Color(red: 0.85, green: 0.55, blue: 0.25)
        case .forest: return Color(red: 0.29, green: 0.49, blue: 0.28)
        case .ocean: return Color(red: 0.20, green: 0.47, blue: 0.62)
        case .berry: return Color(red: 0.62, green: 0.24, blue: 0.38)
        case .slate: return Color(red: 0.35, green: 0.38, blue: 0.43)
        }
    }

    public static let storageKey = "selectedAppTheme"

    public static var current: AppTheme {
        AppTheme(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .amber
    }
}

public extension Color {
    static var amberAccent: Color {
        AppTheme.current.color
    }
}
