import SwiftUI

struct ScrollIndicatorView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))

                Capsule()
                    .fill(.white.opacity(0.75))
                    .frame(width: max(6, geometry.size.width * progress))
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }
}
