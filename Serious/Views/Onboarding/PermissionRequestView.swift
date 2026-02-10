import SwiftUI

struct PermissionRequestView: View {
    let icon: String
    let title: String
    let description: String
    let onRequest: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.accent)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(description)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Grant Permission") {
                onRequest()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
