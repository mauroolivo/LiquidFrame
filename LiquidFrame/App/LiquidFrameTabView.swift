import SwiftUI

private enum LiquidFrameTab: Hashable {
    case home
    case control
}

struct LiquidFrameTabView: View {
    @State private var viewModel = FeedViewModel()
    @Namespace private var transitionNamespace
    @State private var selectedTab: LiquidFrameTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                FeedView(viewModel: viewModel, transitionNamespace: transitionNamespace)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(LiquidFrameTab.home)

            DebugLabView(viewModel: viewModel)
                .tabItem {
                    Label("Control", systemImage: "slider.horizontal.3")
                }
                .tag(LiquidFrameTab.control)
        }
    }
}

#Preview {
    LiquidFrameTabView()
        .preferredColorScheme(.dark)
}
