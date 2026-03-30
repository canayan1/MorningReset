import Foundation

struct ActionArticle {
    let headline: String
    let body: String
}

struct ActionPlaylist {
    let title: String
    let description: String
}

enum ActionContent {

    // Edit these to update what appears in the Learn panel.
    static let articles: [ActionArticle] = [
        ActionArticle(
            headline: "Why your first hour shapes the whole day",
            body: "The first task you complete sets the cognitive tone for everything that follows. Spend that window on output, not input."
        ),
        ActionArticle(
            headline: "The case for a no-phone morning",
            body: "Checking your phone first thing hands over your attention before you've decided what it's worth. Own the first hour."
        ),
        ActionArticle(
            headline: "One small commitment before anything else",
            body: "Make one decision before you open any app. Write it down or say it out loud. It anchors the rest of the morning."
        ),
    ]

    // Edit these to update what appears in the Mode panel.
    static let playlists: [ActionPlaylist] = [
        ActionPlaylist(
            title: "Focus",
            description: "Clean, instrumental. No drops, no lyrics. Consistent tempo for deep work."
        ),
        ActionPlaylist(
            title: "Chill",
            description: "Slow, spacious, ambient. For mornings that need to start gently."
        ),
        ActionPlaylist(
            title: "Energy",
            description: "Higher tempo, driving rhythm. Move fast, cut through resistance."
        ),
    ]
}
