import SwiftUI

struct LiquidFrameRootView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            FeedView(viewModel: viewModel)
        }
    }
}

#Preview {
    LiquidFrameRootView()
        .preferredColorScheme(.dark)
}
