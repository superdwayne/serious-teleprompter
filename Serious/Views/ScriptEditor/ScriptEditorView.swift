import SwiftUI

struct ScriptEditorView: View {
    @Environment(TeleprompterViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    @State private var editingText = ""
    @State private var editingTitle = "Untitled Script"

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Script Editor")
                    .font(.headline)
                Spacer()
                Text("\(wordCount) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TextField("Script Title", text: $editingTitle)
                .textFieldStyle(.roundedBorder)

            TextEditor(text: $editingText)
                .font(.system(size: 14, design: .monospaced))
                .frame(minHeight: 250)
                .scrollContentBackground(.visible)

            HStack {
                Button("Import File...") {
                    importFile()
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Load into Teleprompter") {
                    let script = Script(title: editingTitle, rawText: editingText)
                    viewModel.loadScript(script)
                    openWindow(id: "teleprompter")
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 550, height: 450)
    }

    private var wordCount: Int {
        editingText.split(separator: /\s+/).count
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, .text]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        editingTitle = url.deletingPathExtension().lastPathComponent
        editingText = content
    }
}
