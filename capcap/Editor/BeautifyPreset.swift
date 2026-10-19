import AppKit

struct BeautifyPreset: Equatable {
    let id: String
    let displayName: String
    let startColor: NSColor
    let endColor: NSColor
    let angleDegrees: CGFloat
    let isWallpaper: Bool
    let isTransparent: Bool

    init(
        id: String,
        displayName: String,
        startColor: NSColor,
        endColor: NSColor,
        angleDegrees: CGFloat,
        isWallpaper: Bool = false,
        isTransparent: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.startColor = startColor
        self.endColor = endColor
        self.angleDegrees = angleDegrees
        self.isWallpaper = isWallpaper
        self.isTransparent = isTransparent
    }

    static func == (lhs: BeautifyPreset, rhs: BeautifyPreset) -> Bool {
        lhs.id == rhs.id
    }

    /// Pure alpha background: export keeps transparent padding and rounded
    /// corners; live preview draws a checkerboard so the empty areas stay
    /// visible in the editor.
    static let transparent = BeautifyPreset(
        id: "transparent",
        displayName: L10n.beautifyPresetTransparent,
        startColor: .clear,
        endColor: .clear,
        angleDegrees: 0,
        isTransparent: true
    )

    static let wallpaper = BeautifyPreset(
        id: "wallpaper",
        displayName: L10n.beautifyPresetWallpaper,
        startColor: .clear,
        endColor: .clear,
        angleDegrees: 0,
        isWallpaper: true
    )

    /// Simplified preset list with only essential options
    static let primaryPresets: [BeautifyPreset] = [
        transparent,
        wallpaper,
    ]

    static var defaults: [BeautifyPreset] {
        primaryPresets
    }

    static func preset(forID id: String?) -> BeautifyPreset? {
        guard let id else { return nil }
        return defaults.first(where: { $0.id == id })
    }

    static var defaultPreset: BeautifyPreset {
        preset(forID: Defaults.lastBeautifyPresetID) ?? primaryPresets[0]
    }

    static func toolbarPresets(preferredIDs: [String]) -> [BeautifyPreset] {
        return primaryPresets
    }

    static func promotedToolbarPresetIDs(
        selecting presetID: String,
        currentIDs: [String]
    ) -> [String] {
        return primaryPresets.map(\.id)
    }

    static func pickerPresets(excluding toolbarPresets: [BeautifyPreset]) -> [BeautifyPreset] {
        return []
    }
}
