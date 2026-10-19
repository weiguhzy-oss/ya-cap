import Foundation

enum HistorySearchScope: Equatable {
    case files
}

enum HistorySearchMatcher {
    static func matches(_ entry: HistoryEntry, query: String, scope: HistorySearchScope) -> Bool {
        // Simplified: no search functionality
        return true
    }
}
