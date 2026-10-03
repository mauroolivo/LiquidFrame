import SwiftUI

struct GlassCommandClusterView: View {
    @Binding var isExpanded: Bool
    let onFilter: () -> Void
    let onSave: () -> Void
    let onFocus: () -> Void
    let onShare: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if isExpanded {
                VStack(alignment: .trailing, spacing: 10) {
                    actionButton("Filter", systemImage: "line.3.horizontal.decrease.circle", action: onFilter)
                    actionButton("Save", systemImage: "heart.fill", action: onSave)
                    actionButton("Focus", systemImage: "viewfinder", action: onFocus)
                    actionButton("Share", systemImage: "square.and.arrow.up", action: onShare)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "xmark" : "slider.horizontal.3")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 52, height: 52)
                    .background(clusterBackground)
            }
            .accessibilityLabel(isExpanded ? "Close quick actions" : "Open quick actions")
            .accessibilityHint("Toggles floating command cluster")
        }
        .padding(12)
        .background(clusterBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(contrast == .increased ? 0.42 : 0.2), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.24), radius: 16, y: 8)
        .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isExpanded)
    }

    private var clusterBackground: some ShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color.black.opacity(0.82))
        }
        return AnyShapeStyle(.ultraThinMaterial)
    }

    private func actionButton(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(clusterBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

struct NaiveCommandClusterView: View {
    @Binding var isExpanded: Bool
    let onFilter: () -> Void
    let onSave: () -> Void
    let onFocus: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            if isExpanded {
                Button("Filter", systemImage: "line.3.horizontal.decrease.circle", action: onFilter)
                Button("Save", systemImage: "heart.fill", action: onSave)
                Button("Focus", systemImage: "viewfinder", action: onFocus)
                Button("Share", systemImage: "square.and.arrow.up", action: onShare)
            }

            Button(isExpanded ? "Close" : "Actions") {
                isExpanded.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .labelStyle(.titleAndIcon)
    }
}
