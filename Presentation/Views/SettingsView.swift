import SwiftUI

public struct SettingsView: View {
    @AppStorage(AppTheme.storageKey) private var selectedThemeRaw: String = AppTheme.amber.rawValue

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section(header: Text("テーマカラー")) {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            selectedThemeRaw = theme.rawValue
                        } label: {
                            HStack {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 28, height: 28)

                                Text(theme.displayName)
                                    .foregroundColor(.primary)

                                Spacer()

                                if selectedThemeRaw == theme.rawValue {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.color)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
}
