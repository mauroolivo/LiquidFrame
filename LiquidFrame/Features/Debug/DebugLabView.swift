import SwiftUI
import Observation

struct DebugLabView: View {
    @Bindable var viewModel: FeedViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Background Override") {
                    Picker("Condition", selection: Binding(
                        get: { viewModel.backgroundOverride ?? .quiet },
                        set: { viewModel.backgroundOverride = $0 }
                    )) {
                        ForEach(LFBackgroundCondition.allCases) { condition in
                            Text(condition.title).tag(condition)
                        }
                    }

                    Button("Clear override") {
                        viewModel.backgroundOverride = nil
                    }
                }

                Section("Cluster Comparison") {
                    Toggle("Use naive implementation", isOn: $viewModel.useNaiveCluster)
                    Toggle("Show state overlay", isOn: $viewModel.showsStateOverlay)
                }

                Section("Behavior") {
                    Toggle("Focus mode", isOn: $viewModel.isFocusModeEnabled)
                    Toggle("Filter strip visible", isOn: $viewModel.showsFilterStrip)
                }
            }
            .navigationTitle("LiquidFrame Lab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DebugLabView(viewModel: FeedViewModel())
}
