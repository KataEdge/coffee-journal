import SwiftUI
import PhotosUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

public struct OnboardingView: View {
    @Bindable var viewModel: AuthViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    public init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background Dark Gradient
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.08, blue: 0.06), Color(red: 0.20, green: 0.14, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Top Header Bar (Skip Button)
                HStack {
                    Spacer()
                    Button("スキップ") {
                        viewModel.skipOnboarding()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.subheadline)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                VStack(spacing: 8) {
                    Text("ようこそ CoffeeJournal へ！")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("プロフィールの初期設定を行ってください（後から変更可能です）")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Avatar Picker Section
                VStack(spacing: 16) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack {
                            if let data = selectedImageData, let platformImage = PlatformImage(data: data) {
                                #if os(macOS)
                                Image(nsImage: platformImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                #else
                                Image(uiImage: platformImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(Circle())
                                #endif
                            } else {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 110, height: 110)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 48))
                                            .foregroundStyle(.orange)
                                    )
                            }

                            Circle()
                                .stroke(Color.orange, lineWidth: 2)
                                .frame(width: 116, height: 116)

                            // Camera Icon Overlay Badge
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.orange, .white)
                                .offset(x: 36, y: 36)
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                                viewModel.selectedAvatarData = data
                            }
                        }
                    }

                    Text("タップしてアバター画像を選択")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Username Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("ユーザー名")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.8))

                    HStack {
                        Image(systemName: "at")
                            .foregroundStyle(.orange)
                        TextField("例: コーヒー太郎", text: $viewModel.onboardingUsername)
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
                .padding(.horizontal, 24)

                // Error Message if any
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Action Submit Button
                Button {
                    Task {
                        await viewModel.completeOnboarding()
                    }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("設定を保存してはじめる")
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
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

#Preview {
    OnboardingView(viewModel: AuthViewModel(authRepository: MockAuthRepository()))
}
