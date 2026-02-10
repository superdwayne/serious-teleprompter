import SwiftUI

struct QuickControlsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var s = settings

        VStack(spacing: 6) {
            LabeledSlider(label: "Speed", value: $s.scrollSpeed, range: 0.25...3.0, icon: "gauge.medium")
            LabeledSlider(label: "Size", value: .init(
                get: { Double(s.fontSize) },
                set: { s.fontSize = CGFloat($0) }
            ), range: 16...60, icon: "textformat.size")
            LabeledSlider(label: "Opacity", value: $s.windowOpacity, range: 0.3...1.0, icon: "circle.lefthalf.filled")
        }
    }
}

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .frame(width: 16)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption)
                .frame(width: 48, alignment: .leading)
            Slider(value: $value, in: range)
        }
    }
}
