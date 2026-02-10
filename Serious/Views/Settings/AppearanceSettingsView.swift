import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var s = settings

        Form {
            Section("Text") {
                Slider(value: .init(
                    get: { Double(s.fontSize) },
                    set: { s.fontSize = CGFloat($0) }
                ), in: 16...60, step: 1) {
                    Text("Font Size: \(Int(settings.fontSize))pt")
                }
            }

            Section("Window") {
                Slider(value: $s.windowOpacity, in: 0.3...1.0) {
                    Text("Background Opacity: \(Int(settings.windowOpacity * 100))%")
                }

                Slider(value: .init(
                    get: { Double(s.windowWidth) },
                    set: { s.windowWidth = CGFloat($0) }
                ), in: 300...1200, step: 10) {
                    Text("Window Width: \(Int(settings.windowWidth))px")
                }
            }

            Section("Scroll") {
                Slider(value: $s.scrollSpeed, in: 0.25...3.0, step: 0.25) {
                    Text("Speed: \(String(format: "%.2fx", settings.scrollSpeed))")
                }
            }
        }
        .padding()
    }
}
