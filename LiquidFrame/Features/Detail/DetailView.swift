import SwiftUI

struct DetailView: View {
    let scene: LFScene
    let condition: LFBackgroundCondition
    let isFocusModeEnabled: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(scene.accentColor.opacity(0.25))
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(scene.category.uppercased())
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(scene.title)
                                .font(.largeTitle.bold())
                                .foregroundStyle(LFPalette.softIvory)
                            Text(scene.subtitle)
                                .font(.headline)
                                .foregroundStyle(LFPalette.softIvory.opacity(0.9))
                        }
                        .padding(20)
                    }
                    .frame(height: 300)
                    .background {
                        SceneBackgroundView(
                            accent: scene.accentColor,
                            condition: condition,
                            allowsMotion: scene.hasMotion,
                            isFocusModeEnabled: isFocusModeEnabled
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }

                HStack(spacing: 12) {
                    Label("\(scene.readingTime) read", systemImage: "clock")
                    Label(scene.dominantTone, systemImage: "paintpalette")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Text(scene.bodyCopy)
                    .font(.body)
                    .foregroundStyle(.primary)

                Text("This detail screen intentionally remains restrained. It validates continuity from feed selection to destination hierarchy without introducing unnecessary navigation chrome.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(20)
        }
        .navigationTitle("Scene")
        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationStack {
        DetailView(
            scene: LFSampleScenes.all[0],
            condition: .quiet,
            isFocusModeEnabled: false
        )
    }
    .preferredColorScheme(.dark)
}
