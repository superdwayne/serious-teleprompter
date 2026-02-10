import SwiftUI

struct ShortcutsSettingsView: View {
    var body: some View {
        Form {
            Section("Global Shortcuts") {
                shortcutRow("Toggle Teleprompter", shortcut: "Cmd + Shift + T")
                shortcutRow("Play / Pause", shortcut: "Cmd + Shift + Space")
                shortcutRow("Increase Speed", shortcut: "Cmd + Shift + Up")
                shortcutRow("Decrease Speed", shortcut: "Cmd + Shift + Down")
                shortcutRow("Reset to Beginning", shortcut: "Cmd + Shift + R")
            }

            Text("These shortcuts work even when Serious is in the background.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func shortcutRow(_ action: String, shortcut: String) -> some View {
        HStack {
            Text(action)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
        }
    }
}
