import SwiftUI

struct DetailGlassCapsuleView: View {
    let title: String
    let systemImage: String

    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(LFPalette.softIvory)
            Spacer(minLength: 0)
        }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .stage6InteractiveGlassSurface()
            .overlay {
                Capsule()
                    .strokeBorder(.white.opacity(contrast == .increased ? 0.42 : 0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 16, y: 8)
            .accessibilityHidden(true)
    }
}

private extension View {
    @ViewBuilder
    func stage6InteractiveGlassSurface() -> some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        if #available(iOS 18, *) {
            self
                .glassEffect()
                .clipShape(shape)
        } else {
            self
                .background(Material.regular)
                .clipShape(shape)
        }
    }
}
