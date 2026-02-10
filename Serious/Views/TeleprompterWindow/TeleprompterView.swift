import SwiftUI

struct TeleprompterView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(TeleprompterViewModel.self) private var viewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constants.windowCornerRadius)
                .fill(.black.opacity(settings.windowOpacity))

            if let script = viewModel.currentScript {
                VStack(spacing: 0) {
                    trackingIndicator
                    ScriptTextView(script: script)
                    ScrollIndicatorView(progress: viewModel.scrollState.progress)
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "text.scroll")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("No script loaded")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("Open the menu bar to load a script")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                    Button("Load Sample Script") {
                        viewModel.loadSampleScript()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .padding(.top, 4)
                }
            }
        }
        .frame(width: settings.windowWidth, height: Constants.defaultWindowHeight)
        .background(WindowAccessor())
    }

    @ViewBuilder
    private var trackingIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 7, height: 7)
            Text(indicatorLabel)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            if let error = viewModel.trackingError {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundStyle(.red.opacity(0.8))
                    .lineLimit(1)
            }
        }
        .padding(.bottom, 4)
    }

    private var indicatorColor: Color {
        if !viewModel.isTracking { return .gray.opacity(0.5) }
        if viewModel.scrollState.isPaused { return .orange }
        return .green
    }

    private var indicatorLabel: String {
        if !viewModel.isTracking { return "Idle" }
        if viewModel.scrollState.isPaused { return "Paused" }
        return "Tracking"
    }
}
