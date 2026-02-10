import SwiftUI

struct ScriptListView: View {
    @Environment(TeleprompterViewModel.self) private var viewModel
    @State private var editorVM = ScriptEditorViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Saved Scripts")
                    .font(.headline)
                Spacer()
            }

            if editorVM.scripts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No saved scripts")
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(editorVM.scripts) { script in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(script.title)
                                    .fontWeight(.medium)
                                Text("\(script.wordCount) words")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("Load") {
                                viewModel.loadScript(script)
                                dismiss()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            editorVM.deleteScript(editorVM.scripts[index])
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            editorVM.loadScripts()
        }
    }
}
