import SwiftUI
import Speech

struct OnboardingView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    var body: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case 0:
                welcomeStep
            case 1:
                PermissionRequestView(
                    icon: "mic.fill",
                    title: "Microphone Access",
                    description: "Serious listens to your voice to follow along with your script. Audio is processed on-device and never leaves your Mac.",
                    onRequest: requestMicPermission
                )
            case 2:
                PermissionRequestView(
                    icon: "waveform",
                    title: "Speech Recognition",
                    description: "On-device speech recognition converts your voice to text so the teleprompter can match your reading position.",
                    onRequest: requestSpeechPermission
                )
            case 3:
                readyStep
            default:
                EmptyView()
            }
        }
        .frame(width: 420, height: 320)
        .padding(30)
    }

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.scroll")
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text("Welcome to Serious")
                .font(.title)
                .fontWeight(.bold)

            Text("A teleprompter that sits near your camera and follows your voice, so you maintain natural eye contact.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Get Started") {
                withAnimation { currentStep = 1 }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var readyStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("You're All Set!")
                .font(.title)
                .fontWeight(.bold)

            Text("Load a script from the menu bar, start voice tracking, and begin reading. Serious will follow along.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Start Using Serious") {
                settings.hasCompletedOnboarding = true
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private func requestMicPermission() {
        AVCaptureDevice.requestAccess(for: .audio) { _ in
            Task { @MainActor in
                withAnimation { currentStep = 2 }
            }
        }
    }

    private func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { _ in
            Task { @MainActor in
                withAnimation { currentStep = 3 }
            }
        }
    }
}
