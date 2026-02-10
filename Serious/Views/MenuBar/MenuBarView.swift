import SwiftUI

struct MenuBarView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(TeleprompterViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider().padding(.vertical, 4)
            controlsSection
            Divider().padding(.vertical, 4)
            actionsSection
        }
        .padding(12)
        .frame(width: 280)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Serious")
                    .font(.headline)
                if let script = viewModel.currentScript {
                    Text(script.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No script loaded")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Circle()
                .fill(viewModel.isTracking ? .green : .gray)
                .frame(width: 8, height: 8)
        }
    }

    private var controlsSection: some View {
        VStack(spacing: 8) {
            Toggle("Voice Tracking", isOn: Bindable(viewModel).isTracking)
                .toggleStyle(.switch)

            QuickControlsView()
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 4) {
            Button {
                openWindow(id: "teleprompter")
            } label: {
                Label("Show Teleprompter", systemImage: "text.scroll")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button {
                openSettings()
            } label: {
                Label("Settings...", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Divider().padding(.vertical, 4)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Serious", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
    }
}
