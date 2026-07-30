import SwiftUI
#if canImport(CoffeeJournalCore)
import CoffeeJournalCore
#endif
#if canImport(Supabase)
import Supabase
#endif

@main
struct CoffeeJournalApp: App {
    @State private var repository: CoffeeRepositoryProtocol
    @State private var authViewModel: AuthViewModel

    init() {
        #if canImport(Supabase)
        if AppConfig.useProductionEnvironment {
            let url = URL(string: AppConfig.supabaseURL) ?? URL(string: "https://placeholder.supabase.co")!
            let sharedClient = SupabaseClient(supabaseURL: url, supabaseKey: AppConfig.supabaseAnonKey)
            let supabaseCoffeeRepo = SupabaseCoffeeRepository(client: sharedClient)
            let supabaseAuthRepo = SupabaseAuthRepository(client: sharedClient)
            _repository = State(initialValue: supabaseCoffeeRepo)
            _authViewModel = State(initialValue: AuthViewModel(authRepository: supabaseAuthRepo))
            return
        }
        #endif

        _repository = State(initialValue: PreviewCoffeeRepository.sample)
        _authViewModel = State(initialValue: AuthViewModel(authRepository: MockAuthRepository()))
    }

    var body: some Scene {
        WindowGroup {
            RootView(repository: repository, authViewModel: authViewModel)
        }
    }
}

struct RootView: View {
    let repository: CoffeeRepositoryProtocol
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.status {
            case .unauthenticated:
                AuthView(viewModel: authViewModel)
            case .onboardingRequired:
                OnboardingView(viewModel: authViewModel)
            case .authenticated:
                MainTabView(repository: repository, authViewModel: authViewModel)
            case .authenticating:
                ZStack {
                    Color(red: 0.12, green: 0.08, blue: 0.05).ignoresSafeArea()
                    ProgressView()
                        .tint(.orange)
                }
            }
        }
        .task {
            await authViewModel.checkAuthStatus()
        }
    }
}
