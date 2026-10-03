import SwiftUI

enum LFBackgroundCondition: String, CaseIterable, Identifiable, Codable {
    case quiet
    case bright
    case dark
    case saturated
    case busy
    case moving
    case monoMotion = "mono-motion"
    case mixedLight = "mixed-light"
    case editorialNeutral = "editorial-neutral"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quiet: return "Quiet"
        case .bright: return "Bright"
        case .dark: return "Dark"
        case .saturated: return "Saturated"
        case .busy: return "Busy"
        case .moving: return "Moving"
        case .monoMotion: return "Monochrome"
        case .mixedLight: return "Mixed Light"
        case .editorialNeutral: return "Editorial Neutral"
        }
    }
}

enum LFLayoutStyle: String, CaseIterable, Codable {
    case hero
    case compact
    case split
    case motion
}

enum LFFilterScope: String, CaseIterable, Identifiable {
    case all = "All"
    case motion = "Motion"
    case saved = "Saved"

    var id: String { rawValue }
}

struct LFScene: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: String
    let dominantTone: String
    let backgroundStyle: LFBackgroundCondition
    let accentColor: Color
    let hasMotion: Bool
    var isFavorite: Bool
    let readingTime: String
    let layoutStyle: LFLayoutStyle
    let bodyCopy: String
}
