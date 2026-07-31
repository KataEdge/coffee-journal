import SwiftUI

public struct AuthView: View {
    @Bindable var viewModel: AuthViewModel

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.08, blue: 0.05), Color(red: 0.25, green: 0.16, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // App Branding Header
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .amberAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 4)

                    Text("CoffeeJournal")
                        .font(.largeTitle.bold())
                        .fontDesign(.serif)
                        .foregroundStyle(.white)

                    Text("あなたの珈琲体験を記録し、シェアしよう")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Auth Card Container (Glassmorphism)
                VStack(spacing: 20) {
                    // Segmented Control for Sign In / Sign Up
                    Picker("Mode", selection: $viewModel.isSignUpMode) {
                        Text("ログイン").tag(false)
                        Text("アカウント登録").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 8)

                    // Error Message Banner
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(8)
                    }

                    // Email Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("メールアドレス")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.orange)
                            TextField("example@coffee.com", text: $viewModel.email)
                                .textFieldStyle(.plain)
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                #endif
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Password Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("パスワード")
                            .font(.caption.bold())
                            .foregroundStyle(.white.opacity(0.8))
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.orange)
                            SecureField("8文字以上で入力", text: $viewModel.password)
                                .textFieldStyle(.plain)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }

                    // Submit Button
                    Button {
                        Task {
                            await viewModel.submitAuth()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(viewModel.isSignUpMode ? "新規アカウント作成" : "ログイン")
                                    .font(.headline.bold())
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, Color(red: 0.85, green: 0.45, blue: 0.15)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)

                // Social / Guest Sign-In Divider & Buttons
                VStack(spacing: 12) {
                    HStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                        Text("または")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 30)

                    // Apple provider is implemented (AuthViewModel/SupabaseAuthRepository) but hidden
                    // until Sign in with Apple is configured on the Apple Developer / Supabase side.
                    Button {
                        Task {
                            await viewModel.signInWithOAuth(provider: .google)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "g.circle.fill")
                            Text("Googleでサインイン")
                                .font(.subheadline.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal, 20)

                    Button {
                        Task {
                            await viewModel.signInAnonymously()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill.questionmark")
                            Text("ゲストとして利用を開始")
                                .font(.subheadline.bold())
                        }
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isLoading)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(authRepository: MockAuthRepository()))
}
