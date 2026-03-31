import Foundation

// MARK: - News Service

enum NewsService {

    private static let feedURL = URL(string: "https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en")!

    /// Words whose presence disqualify a headline. Substring match on lowercased text.
    private static let blocklist: Set<String> = [
        "killed", "kill", "dead", "death", "murder", "war", "attack",
        "shooting", "shot", "explosion", "explode", "crash", "disaster",
        "earthquake", "flood", "hurricane", "tornado", "wildfire",
        "outbreak", "pandemic", "crisis", "collapse", "riot", "arrested",
        "terror", "bomb", "weapon", "invasion", "missile", "nuclear",
        "famine", "genocide", "massacre", "hostage", "siege",
        "scandal", "fraud", "abuse", "trafficking", "violence",
        "wounded", "injured", "fatalities", "casualties"
    ]

    /// Fetch, filter, and return 3 calm headlines.
    /// Falls back to local pool if RSS is unavailable or no clean headlines found.
    static func fetchHeadlines() async -> [String] {
        if let fetched = try? await fetch(), !fetched.isEmpty {
            let filtered = filter(fetched)
            let result = Array(filtered.prefix(3))
            if !result.isEmpty { return result }
        }
        return localFallback()
    }

    // MARK: - Fetch

    private static func fetch() async throws -> [String] {
        let (data, response) = try await URLSession.shared.data(from: feedURL)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return RSSParser().parse(data)
    }

    // MARK: - Filter

    private static func filter(_ headlines: [String]) -> [String] {
        // Score each headline by number of blocklist substring hits.
        // Sort ascending (cleanest first), keep only score == 0.
        let scored = headlines.map { headline -> (String, Int) in
            let lower = headline.lowercased()
            let hits = blocklist.filter { lower.contains($0) }.count
            return (headline, hits)
        }
        let clean = scored.filter { $0.1 == 0 }.map { $0.0 }
        if !clean.isEmpty { return clean }
        // Fallback: return least-negative headlines if nothing is fully clean.
        return scored.sorted { $0.1 < $1.1 }.map { $0.0 }
    }

    // MARK: - Local fallback

    private static func localFallback() -> [String] {
        let pool = HeadlineContent.all
        let day = Calendar.current.component(.day, from: Date())
        let start = (day * 3) % pool.count
        return (0..<3).map { pool[(start + $0) % pool.count] }
    }
}

// MARK: - RSS Parser

private final class RSSParser: NSObject, XMLParserDelegate {
    private var results: [String] = []
    private var buffer = ""
    private var inItem = false
    private var inTitle = false

    func parse(_ data: Data) -> [String] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return results
    }

    func parser(
        _ parser: XMLParser,
        didStartElement element: String,
        namespaceURI: String?,
        qualifiedName: String?,
        attributes: [String: String] = [:]
    ) {
        if element == "item"  { inItem = true }
        if element == "title" && inItem { inTitle = true; buffer = "" }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inTitle { buffer += string }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement element: String,
        namespaceURI: String?,
        qualifiedName: String?
    ) {
        if element == "title" && inItem {
            inTitle = false
            let cleaned = stripSource(buffer.trimmingCharacters(in: .whitespacesAndNewlines))
            if !cleaned.isEmpty { results.append(cleaned) }
        }
        if element == "item" { inItem = false }
    }

    /// Remove " - Source Name" suffix that Google News appends.
    private func stripSource(_ text: String) -> String {
        if let range = text.range(of: " - ", options: .backwards) {
            return String(text[..<range.lowerBound])
        }
        return text
    }
}
