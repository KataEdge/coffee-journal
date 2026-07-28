import SwiftUI

public struct RoastLevelBadge: View {
    public let roastLevel: String?

    public init(roastLevel: String?) {
        self.roastLevel = roastLevel
    }

    private var badgeColors: (Color, Color) {
        guard let level = roastLevel?.lowercased() else {
            return (Color.gray, Color.secondary)
        }
        if level.contains("light") || level.contains("浅") {
            return (Color(red: 0.92, green: 0.65, blue: 0.40), Color(red: 0.85, green: 0.45, blue: 0.20))
        } else if level.contains("dark") || level.contains("深") {
            return (Color(red: 0.25, green: 0.15, blue: 0.10), Color(red: 0.15, green: 0.08, blue: 0.05))
        } else {
            return (Color(red: 0.65, green: 0.40, blue: 0.25), Color(red: 0.45, green: 0.25, blue: 0.15))
        }
    }

    public var body: some View {
        if let text = roastLevel, !text.isEmpty {
            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(colors: [badgeColors.0, badgeColors.1], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(color: badgeColors.0.opacity(0.3), radius: 3, x: 0, y: 2)
        }
    }
}

#Preview {
    HStack {
        RoastLevelBadge(roastLevel: "浅煎り (Light)")
        RoastLevelBadge(roastLevel: "中煎り (Medium)")
        RoastLevelBadge(roastLevel: "深煎り (Dark)")
    }
    .padding()
}
