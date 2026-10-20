import Foundation

// Stub for removed history functionality
struct HistoryEntry {
    let fileURL: URL
    let kind: Kind
    
    enum Kind {
        case image
        case text
        case color
        case fileReference
    }
}
