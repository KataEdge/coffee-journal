import SwiftUI

public struct CreateNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CreateNoteViewModel

    public init(repository: CoffeeRepositoryProtocol) {
        _viewModel = State(initialValue: CreateNoteViewModel(repository: repository))
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("カフェ情報")) {
                    TextField("カフェ店舗名 (必須)", text: $viewModel.cafeName)
                    TextField("住所 / エリア (任意)", text: $viewModel.address)
                }

                Section(header: Text("ドリンク情報")) {
                    TextField("ドリンク名 / メニュー名 (必須)", text: $viewModel.drinkName)
                    Picker("抽出方法", selection: $viewModel.brewMethod) {
                        ForEach(viewModel.availableBrewMethods, id: \.self) { method in
                            Text(method).tag(method)
                        }
                    }
                }

                Section(header: Text("豆の詳細 (任意)")) {
                    TextField("ロースター / 焙煎所", text: $viewModel.roaster)
                    TextField("生産国 / 原産地", text: $viewModel.origin)

                    Picker("焙煎度", selection: $viewModel.roastLevel) {
                        Text("指定なし").tag("")
                        Text("浅煎り (Light)").tag("浅煎り")
                        Text("中煎り (Medium)").tag("中煎り")
                        Text("深煎り (Dark)").tag("深煎り")
                    }
                }

                Section(header: Text("味のパラメータ (1 ~ 5)")) {
                    TasteSlider(label: "酸味 (Acidity)", value: $viewModel.acidity)
                    TasteSlider(label: "甘味 (Sweetness)", value: $viewModel.sweetness)
                    TasteSlider(label: "苦味 (Bitterness)", value: $viewModel.bitterness)
                    TasteSlider(label: "コク (Body)", value: $viewModel.body)
                    TasteSlider(label: "香り (Aroma)", value: $viewModel.aroma)

                    TasteRadarChart(
                        taste: TasteParameter(
                            acidity: viewModel.acidity,
                            sweetness: viewModel.sweetness,
                            bitterness: viewModel.bitterness,
                            body: viewModel.body,
                            aroma: viewModel.aroma
                        )
                    )
                    .frame(height: 160)
                    .padding(.vertical, 8)
                }

                Section(header: Text("フレーバータグ")) {
                    FlavorTagView(
                        tags: viewModel.availableFlavorTags,
                        selectedTags: viewModel.selectedFlavorTags,
                        onSelectTag: { tag in
                            viewModel.toggleFlavorTag(tag)
                        }
                    )
                    .padding(.vertical, 4)
                }

                Section(header: Text("カフェメモ・感想")) {
                    TextEditor(text: $viewModel.comment)
                        .frame(minHeight: 100)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("カフェログを記録")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            let success = await viewModel.saveNote()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .bold()
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }
            }
        }
    }
}

struct TasteSlider: View {
    let label: String
    @Binding var value: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.amberAccent)
            }
            Stepper("", value: $value, in: 1...5)
                .labelsHidden()
        }
    }
}

#Preview {
    CreateNoteView(repository: PreviewCoffeeRepository())
}

