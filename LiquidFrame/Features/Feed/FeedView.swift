import SwiftUI
import Observation

struct FeedView: View {
    @Bindable var viewModel: FeedViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if viewModel.showsFilterStrip {
                        filterStrip
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    ForEach(viewModel.filteredScenes) { scene in
                        NavigationLink {
                            DetailView(
                                scene: scene,
                                condition: viewModel.effectiveBackground(for: scene),
                                isFocusModeEnabled: viewModel.isFocusModeEnabled
                            )
                        } label: {
                            SceneCardView(
                                scene: scene,
                                condition: viewModel.effectiveBackground(for: scene),
                                isFocusModeEnabled: viewModel.isFocusModeEnabled,
                                reduceMotion: reduceMotion,
                                dynamicTypeSize: dynamicTypeSize
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(scene.isFavorite ? "Remove favorite" : "Save", systemImage: scene.isFavorite ? "heart.slash" : "heart") {
                                viewModel.toggleFavorite(for: scene.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 120)
            }

            if viewModel.isClusterExpanded {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.collapseCluster()
                    }
            }

            clusterView
                .padding(.trailing, 18)
                .padding(.bottom, 22)

#if DEBUG
            if viewModel.showsStateOverlay {
                stateOverlay
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
#endif
        }
        .background(LFPalette.deepGraphite.ignoresSafeArea())
        .navigationTitle("LiquidFrame")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleFocusMode()
                } label: {
                    Image(systemName: viewModel.isFocusModeEnabled ? "viewfinder.circle.fill" : "viewfinder.circle")
                }
                .accessibilityLabel(viewModel.isFocusModeEnabled ? "Disable focus mode" : "Enable focus mode")
            }

#if DEBUG
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showsDebugLab = true
                } label: {
                    Image(systemName: "wrench.and.screwdriver")
                }
                .accessibilityLabel("Open debug lab")
            }
#endif
        }
#if DEBUG
        .sheet(isPresented: $viewModel.showsDebugLab) {
            DebugLabView(viewModel: viewModel)
        }
#endif
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LFFilterScope.allCases) { scope in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.setFilterScope(scope)
                        }
                    } label: {
                        Text(scope.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(viewModel.filterScope == scope ? LFPalette.coolFocus.opacity(0.28) : .white.opacity(0.09))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Feed filters")
    }

    @ViewBuilder
    private var clusterView: some View {
#if DEBUG
        if viewModel.useNaiveCluster {
            NaiveCommandClusterView(
                isExpanded: $viewModel.isClusterExpanded,
                onFilter: viewModel.triggerFilterAction,
                onSave: viewModel.toggleFavoriteForFeatured,
                onFocus: viewModel.toggleFocusMode,
                onShare: {}
            )
            .padding(10)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            productionCluster
        }
#else
        productionCluster
#endif
    }

    private var productionCluster: some View {
        GlassCommandClusterView(
            isExpanded: $viewModel.isClusterExpanded,
            onFilter: viewModel.triggerFilterAction,
            onSave: viewModel.toggleFavoriteForFeatured,
            onFocus: viewModel.toggleFocusMode,
            onShare: {}
        )
    }

#if DEBUG
    private var stateOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug State")
                .font(.caption.bold())
            Text("Filter: \(viewModel.filterScope.rawValue)")
            Text("Focus: \(viewModel.isFocusModeEnabled ? "On" : "Off")")
            Text("Cluster: \(viewModel.isClusterExpanded ? "Expanded" : "Collapsed")")
            if let override = viewModel.backgroundOverride {
                Text("Background override: \(override.title)")
            }
        }
        .font(.caption2.monospaced())
        .padding(10)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
#endif
}

private struct SceneCardView: View {
    let scene: LFScene
    let condition: LFBackgroundCondition
    let isFocusModeEnabled: Bool
    let reduceMotion: Bool
    let dynamicTypeSize: DynamicTypeSize

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SceneBackgroundView(
                accent: scene.accentColor,
                condition: condition,
                allowsMotion: scene.hasMotion,
                isFocusModeEnabled: isFocusModeEnabled,
                reduceMotion: reduceMotion
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(scene.category.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(LFPalette.softIvory.opacity(isFocusModeEnabled ? 0.74 : 0.9))
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                Text(scene.title)
                    .font(titleFont)
                    .foregroundStyle(LFPalette.softIvory)
                    .lineLimit(2)

                Text(scene.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(LFPalette.softIvory.opacity(isFocusModeEnabled ? 0.68 : 0.9))
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label(scene.readingTime, systemImage: "clock")
                    Label(scene.hasMotion ? "Motion" : "Static", systemImage: scene.hasMotion ? "waveform.path.ecg" : "square")
                    if scene.isFavorite {
                        Label("Saved", systemImage: "heart.fill")
                    }
                }
                .font(.caption)
                .foregroundStyle(LFPalette.softIvory.opacity(isFocusModeEnabled ? 0.55 : 0.8))
            }
            .padding(18)
        }
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
    }

    private var cardHeight: CGFloat {
        switch scene.layoutStyle {
        case .hero:
            return 320
        case .compact:
            return 200
        case .split:
            return 250
        case .motion:
            return 280
        }
    }

    private var titleFont: Font {
        switch scene.layoutStyle {
        case .hero:
            return dynamicTypeSize.isAccessibilitySize ? .title2.bold() : .largeTitle.bold()
        case .compact:
            return .title3.bold()
        case .split:
            return .title2.bold()
        case .motion:
            return .title.bold()
        }
    }
}

struct SceneBackgroundView: View {
    let accent: Color
    let condition: LFBackgroundCondition
    let allowsMotion: Bool
    let isFocusModeEnabled: Bool
    var reduceMotion = false

    @State private var animate = false

    var body: some View {
        ZStack {
            baseGradient
            detailLayer

            if allowsMotion && !reduceMotion && !isFocusModeEnabled {
                MovingGlowOverlay(animate: animate, accent: accent)
                    .transition(.opacity)
            }
        }
        .saturation(isFocusModeEnabled ? 0.72 : 1.0)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }

    private var baseGradient: LinearGradient {
        switch condition {
        case .quiet:
            return LinearGradient(colors: [LFPalette.charcoal, LFPalette.deepGraphite], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .bright:
            return LinearGradient(colors: [Color.white.opacity(0.9), LFPalette.mutedAmber.opacity(0.4), LFPalette.charcoal.opacity(0.5)], startPoint: .top, endPoint: .bottom)
        case .dark:
            return LinearGradient(colors: [Color.black, LFPalette.charcoal, LFPalette.deepGraphite], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .saturated:
            return LinearGradient(colors: [accent.opacity(0.9), LFPalette.mutedRose.opacity(0.78), LFPalette.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .busy:
            return LinearGradient(colors: [LFPalette.charcoal, accent.opacity(0.6), LFPalette.deepGraphite], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .moving:
            return LinearGradient(colors: [LFPalette.deepGraphite, accent.opacity(0.7), LFPalette.charcoal], startPoint: .top, endPoint: .bottom)
        case .mixedLight:
            return LinearGradient(colors: [Color.white.opacity(0.7), LFPalette.charcoal, accent.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .editorialNeutral:
            return LinearGradient(colors: [LFPalette.deepGraphite, LFPalette.charcoal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    @ViewBuilder
    private var detailLayer: some View {
        switch condition {
        case .busy:
            BusyPatternLayer(accent: accent)
        case .bright:
            Circle()
                .fill(accent.opacity(0.12))
                .blur(radius: 26)
                .offset(x: -70, y: -40)
        case .moving:
            Rectangle()
                .fill(.white.opacity(0.06))
                .blur(radius: 20)
                .offset(x: animate ? 25 : -25)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: animate)
        default:
            EmptyView()
        }
    }
}

private struct BusyPatternLayer: View {
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Canvas { context, _ in
                for row in stride(from: 0.0, to: size.height, by: 20) {
                    for col in stride(from: 0.0, to: size.width, by: 26) {
                        let rect = CGRect(x: col, y: row, width: 10, height: 10)
                        context.fill(
                            Path(roundedRect: rect, cornerRadius: 2),
                            with: .color(accent.opacity(((row + col).truncatingRemainder(dividingBy: 80) / 200) + 0.12))
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct MovingGlowOverlay: View {
    let animate: Bool
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                Circle()
                    .fill(accent.opacity(0.26))
                    .frame(width: width * 0.55)
                    .blur(radius: 24)
                    .offset(
                        x: animate ? width * 0.22 : -width * 0.12,
                        y: animate ? -height * 0.14 : height * 0.1
                    )

                Circle()
                    .fill(.white.opacity(0.16))
                    .frame(width: width * 0.42)
                    .blur(radius: 20)
                    .offset(
                        x: animate ? -width * 0.18 : width * 0.14,
                        y: animate ? height * 0.2 : -height * 0.18
                    )
            }
        }
    }
}

#Preview("Feed - Dark") {
    NavigationStack {
        FeedView(viewModel: FeedViewModel())
    }
    .preferredColorScheme(.dark)
}

#Preview("Feed - Focus") {
    NavigationStack {
        let vm = FeedViewModel()
        vm.isFocusModeEnabled = true
        return FeedView(viewModel: vm)
    }
    .preferredColorScheme(.dark)
}
