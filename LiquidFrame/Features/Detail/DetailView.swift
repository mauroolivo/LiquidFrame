import SwiftUI

struct DetailView: View {
    let scene: LFScene
    let condition: LFBackgroundCondition
    let isFocusModeEnabled: Bool
    let transitionNamespace: Namespace.ID

    @State private var panelOffset: CGFloat = 0
    @GestureState private var panelDragTranslation: CGFloat = 0

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
                        let initialTopSpacing = max(proxy.size.height * 0.55, 360)
                        let topSafeAnchor = proxy.safeAreaInsets.top + 8
                        let maxUpwardOffset = max(0, initialTopSpacing - topSafeAnchor)

                        Color.clear
                            .frame(height: initialTopSpacing)

                        contentPanel(
                            maxDownwardOffset: proxy.size.height * 0.18,
                            maxUpwardOffset: maxUpwardOffset
                        )
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

    private func contentPanel(maxDownwardOffset: CGFloat, maxUpwardOffset: CGFloat) -> some View {
        let liveTranslation = clampedPanelOffset(
            panelOffset + panelDragTranslation,
            maxDownwardOffset: maxDownwardOffset,
            maxUpwardOffset: maxUpwardOffset
        )

        return VStack(spacing: 10) {
            DetailGlassCapsuleView(title: scene.category.uppercased(), systemImage: "sparkles")
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Capsule()
                        .fill(.white.opacity(contrast == .increased ? 0.5 : 0.3))
                        .frame(width: 44, height: 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 2)

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
            .background(controlBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(contrast == .increased ? 0.42 : 0.2), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 16, y: 8)
        }
        .padding(.horizontal, 10)
        .offset(y: liveTranslation)
        .highPriorityGesture(
            dragGesture(maxDownwardOffset: maxDownwardOffset, maxUpwardOffset: maxUpwardOffset)
        )
    }

    private func dragGesture(maxDownwardOffset: CGFloat, maxUpwardOffset: CGFloat) -> some Gesture {
        DragGesture()
            .updating($panelDragTranslation) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let proposedOffset = panelOffset + value.translation.height
                let clampedOffset = clampedPanelOffset(
                    proposedOffset,
                    maxDownwardOffset: maxDownwardOffset,
                    maxUpwardOffset: maxUpwardOffset
                )

                panelOffset = clampedOffset
            }
    }

    private func clampedPanelOffset(
        _ offset: CGFloat,
        maxDownwardOffset: CGFloat,
        maxUpwardOffset: CGFloat
    ) -> CGFloat {
        let upperBound = max(0, maxDownwardOffset)
        let lowerBound = -max(0, maxUpwardOffset)
        return min(max(offset, lowerBound), upperBound)
    }

    private var controlBackground: some ShapeStyle {
        if reduceTransparency {
            return AnyShapeStyle(Color.black.opacity(0.82))
        }

        return AnyShapeStyle(.ultraThinMaterial)
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
