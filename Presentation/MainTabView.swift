import SwiftUI
import PhotosUI

public struct MainTabView: View {
    private let repository: CoffeeRepositoryProtocol
    @Bindable var authViewModel: AuthViewModel
    @AppStorage(AppTheme.storageKey) private var selectedThemeRaw: String = AppTheme.amber.rawValue

    public init(repository: CoffeeRepositoryProtocol, authViewModel: AuthViewModel) {
        self.repository = repository
        self.authViewModel = authViewModel
    }

    public var body: some View {
        TabView {
            TastingNoteListView(repository: repository)
                .tabItem {
                    Label("ログ一覧", systemImage: "list.bullet")
                }

            CoffeeMapView(repository: repository)
                .tabItem {
                    Label("マップ", systemImage: "map")
                }

            AccountView(authViewModel: authViewModel)
                .tabItem {
                    Label("マイページ", systemImage: "person.circle")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .id(selectedThemeRaw)
        .tint(.amberAccent)
    }
}

struct AccountView: View {
    @Bindable var authViewModel: AuthViewModel
    @State private var isShowingEditSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("アカウント情報") {
                    if case .authenticated(let profile) = authViewModel.status {
                        HStack(spacing: 16) {
                            if let avatarUrl = profile.avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.orange)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.username ?? "コーヒーラバー")
                                    .font(.headline)
                                Text("ID: \(profile.id.uuidString.prefix(8))...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("編集") {
                                isShowingEditSheet = true
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if authViewModel.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("サインアウト (ログアウト)")
                                    .bold()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("マイページ")
            .sheet(isPresented: $isShowingEditSheet) {
                if case .authenticated(let profile) = authViewModel.status {
                    ProfileEditSheet(authViewModel: authViewModel, currentProfile: profile)
                }
            }
        }
    }
}

struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var authViewModel: AuthViewModel
    let currentProfile: UserProfile

    @State private var usernameInput: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section("ユーザー名") {
                    TextField("ユーザー名を入力", text: $usernameInput)
                }
            }
            .navigationTitle("プロフィール編集")
            .onAppear {
                usernameInput = currentProfile.username ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await authViewModel.updateProfile(username: usernameInput, avatarData: selectedImageData)
                            dismiss()
                        }
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    MainTabView(repository: PreviewCoffeeRepository.sample, authViewModel: AuthViewModel(authRepository: MockAuthRepository()))
}
