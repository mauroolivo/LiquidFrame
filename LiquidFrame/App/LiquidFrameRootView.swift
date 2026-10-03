import SwiftUI

struct LiquidFrameRootView: View {
    @State private var viewModel = FeedViewModel()
    @Namespace private var transitionNamespace

    var body: some View {
        NavigationStack {
            FeedView(viewModel: viewModel, transitionNamespace: transitionNamespace)
        }
    }
}

#Preview {
    LiquidFrameRootView()
        .preferredColorScheme(.dark)
}
