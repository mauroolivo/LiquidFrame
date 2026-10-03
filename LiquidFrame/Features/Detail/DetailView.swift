import SwiftUI

struct DetailView: View {
    let scene: LFScene
    let condition: LFBackgroundCondition
    let isFocusModeEnabled: Bool
    let transitionNamespace: Namespace.ID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                SceneBackgroundView(
                    accent: scene.accentColor,
                    condition: condition,
                    allowsMotion: scene.hasMotion,
                    isFocusModeEnabled: isFocusModeEnabled,
                    reduceMotion: reduceMotion
                )
                .ignoresSafeArea()

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.78)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                heroTextOverlay
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: max(proxy.size.height * 0.55, 360))

                        contentPanel
                    }
                }
            }
            .navigationTransition(.zoom(sourceID: scene.id, in: transitionNamespace))
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Bookmark", systemImage: "bookmark") {}
                    Button("Share", systemImage: "square.and.arrow.up") {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private var heroTextOverlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scene.category.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(LFPalette.softIvory.opacity(0.95))

            Text(scene.title)
                .font(.largeTitle.bold())
                .foregroundStyle(LFPalette.softIvory)
                .shadow(color: .black.opacity(0.65), radius: 8, y: 3)

            Text(scene.subtitle)
                .font(.headline)
                .foregroundStyle(LFPalette.softIvory.opacity(0.95))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 26)
    }

    private var contentPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Label("\(scene.readingTime) read", systemImage: "clock")
                Label(scene.dominantTone, systemImage: "paintpalette")
            }
            .font(.subheadline)
            .foregroundStyle(LFPalette.softIvory.opacity(0.9))

            Text(scene.bodyCopy)
                .font(.body)
                .foregroundStyle(LFPalette.softIvory)

            Text("This detail screen uses a full-bleed stage to test continuity and floating controls over variable backgrounds.")
                .font(.callout)
                .foregroundStyle(LFPalette.softIvory.opacity(0.75))
                .padding(.top, 8)
        }
        .padding(16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.thinMaterial)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.20),
                                Color.white.opacity(0.06),
                                Color.clear,
                                Color.black.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.screen)
            }
        }
        .padding(.horizontal, 10)
    }

}

#Preview {
    DetailPreviewHost()
        .preferredColorScheme(.dark)
}

private struct DetailPreviewHost: View {
    @Namespace private var transitionNamespace

    var body: some View {
        NavigationStack {
            DetailView(
                scene: LFSampleScenes.all[0],
                condition: .quiet,
                isFocusModeEnabled: false,
                transitionNamespace: transitionNamespace
            )
        }
    }
}
