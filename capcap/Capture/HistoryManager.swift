import AppKit
import Foundation

// Stub for removed history functionality
final class HistoryManager {
    static let shared = HistoryManager()
    
    private init() {}
    
    func add(image: NSImage) {}
    func addFile(_ url: URL) {}
    func addFileReferences(_ urls: [URL]) {}
    func addText(_ text: String) {}
    func addColor(hex: String) {}
    func image(for entry: HistoryEntry) -> NSImage? { nil }
    func imageEntries() -> [HistoryEntry] { [] }
    func hasFavoriteEntries() -> Bool { false }
    
    static func markAsSavedByCapcap(url: URL) {}
    static func isFavorite(url: URL) -> Bool { false }
}

extension Notification.Name {
    static let historyDidAddEntry = Notification.Name("historyDidAddEntry")
}
