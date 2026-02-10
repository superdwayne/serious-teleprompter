import SwiftUI

@main
struct SeriousApp: App {
    @State private var appSettings = AppSettings()
    @State private var teleprompterViewModel = TeleprompterViewModel()

    init() {
        _teleprompterViewModel.wrappedValue.configure(settings: _appSettings.wrappedValue)
    }

    var body: some Scene {
        MenuBarExtra("Serious", systemImage: "scroll") {
            MenuBarContent()
                .environment(appSettings)
                .environment(teleprompterViewModel)
        }

        Window("Teleprompter", id: "teleprompter") {
            TeleprompterView()
                .environment(appSettings)
                .environment(teleprompterViewModel)
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)

        Window("Script Editor", id: "script-editor") {
            ScriptEditorView()
                .environment(appSettings)
                .environment(teleprompterViewModel)
        }
        .defaultLaunchBehavior(.suppressed)

        Settings {
            SettingsView()
                .environment(appSettings)
        }
    }
}

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @Environment(TeleprompterViewModel.self) private var viewModel

    var body: some View {
        Button("Show Teleprompter") {
            openWindow(id: "teleprompter")
        }
        .keyboardShortcut("t", modifiers: [.command, .shift])

        Divider()

        Button("Paste / Edit Script...") {
            openWindow(id: "script-editor")
        }

        Button("Import Text File...") {
            importFile()
        }

        Button("Load Sample Script") {
            viewModel.loadSampleScript()
            openWindow(id: "teleprompter")
        }

        if viewModel.currentScript != nil {
            Divider()

            Button(viewModel.isTracking ? "Stop Voice Tracking" : "Start Voice Tracking") {
                viewModel.isTracking.toggle()
            }
            .keyboardShortcut(" ", modifiers: [.command, .shift])

            Button("Reset to Beginning") {
                viewModel.resetToBeginning()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
        }

        Divider()

        Button("Settings...") {
            openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit Serious") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, .text]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        let title = url.deletingPathExtension().lastPathComponent
        let script = Script(title: title, rawText: content)
        viewModel.loadScript(script)
        openWindow(id: "teleprompter")
    }
}
