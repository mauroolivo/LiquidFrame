import SwiftUI
import Observation

@MainActor
@Observable
final class FeedViewModel {
    private(set) var scenes: [LFScene]
    var filterScope: LFFilterScope = .all
    var isFocusModeEnabled = false
    var isClusterExpanded = false
    var showsFilterStrip = false
    var backgroundOverride: LFBackgroundCondition?

#if DEBUG
    var showsDebugLab = false
    var useNaiveCluster = false
    var showsStateOverlay = false
#endif

    init(scenes: [LFScene]? = nil) {
        self.scenes = scenes ?? LFSampleScenes.all
    }

    var filteredScenes: [LFScene] {
        scenes.filter { scene in
            switch filterScope {
            case .all:
                true
            case .motion:
                scene.hasMotion
            case .saved:
                scene.isFavorite
            }
        }
    }

    var featuredScene: LFScene? {
        filteredScenes.first
    }

    func effectiveBackground(for scene: LFScene) -> LFBackgroundCondition {
        backgroundOverride ?? scene.backgroundStyle
    }

    func toggleFavorite(for sceneID: UUID) {
        guard let index = scenes.firstIndex(where: { $0.id == sceneID }) else {
            return
        }
        scenes[index].isFavorite.toggle()
    }

    func toggleFavoriteForFeatured() {
        guard let featuredID = featuredScene?.id else {
            return
        }
        toggleFavorite(for: featuredID)
    }

    func toggleClusterExpanded() {
        withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
            isClusterExpanded.toggle()
        }
    }

    func collapseCluster() {
        guard isClusterExpanded else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            isClusterExpanded = false
        }
    }

    func triggerFilterAction() {
        if showsFilterStrip {
            cycleFilter()
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                showsFilterStrip = true
            }
        }
    }

    func cycleFilter() {
        let scopes = LFFilterScope.allCases
        guard let currentIndex = scopes.firstIndex(of: filterScope) else { return }
        filterScope = scopes[(currentIndex + 1) % scopes.count]
    }

    func setFilterScope(_ scope: LFFilterScope) {
        filterScope = scope
    }

    func toggleFocusMode() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isFocusModeEnabled.toggle()
        }
    }
}
