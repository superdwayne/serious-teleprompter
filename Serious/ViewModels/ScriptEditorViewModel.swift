import Foundation
import AppKit

@Observable
@MainActor
final class ScriptEditorViewModel {
    var scripts: [Script] = []
    var editingText: String = ""
    var editingTitle: String = "Untitled Script"

    private let fileManager = FileManager.default

    var scriptsDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport
            .appendingPathComponent(Constants.appSupportSubdirectory)
            .appendingPathComponent(Constants.scriptsDirectoryName)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    func loadScripts() {
        guard let files = try? fileManager.contentsOfDirectory(at: scriptsDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        scripts = files
            .filter { $0.pathExtension == "json" }
            .compactMap { url -> Script? in
                guard let data = try? Data(contentsOf: url),
                      let script = try? JSONDecoder().decode(Script.self, from: data) else {
                    return nil
                }
                return script
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func saveScript(_ script: Script) {
        let url = scriptsDirectory.appendingPathComponent("\(script.id.uuidString).json")
        guard let data = try? JSONEncoder().encode(script) else { return }
        try? data.write(to: url)
        loadScripts()
    }

    func deleteScript(_ script: Script) {
        let url = scriptsDirectory.appendingPathComponent("\(script.id.uuidString).json")
        try? fileManager.removeItem(at: url)
        loadScripts()
    }

    func createScriptFromText() -> Script {
        let script = Script(title: editingTitle, rawText: editingText)
        saveScript(script)
        return script
    }

    func importFile() -> Script? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, .text]
        panel.allowsMultipleSelection = false

        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return nil }

        let title = url.deletingPathExtension().lastPathComponent
        let script = Script(title: title, rawText: content)
        saveScript(script)
        return script
    }
}
