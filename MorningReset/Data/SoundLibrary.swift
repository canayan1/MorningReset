import Foundation

// MARK: - Curated indie picks
//
// Each entry rotates daily within its direction.
// We use Spotify search deep links so the user lands directly on
// real, current results — no risk of dead playlist IDs.
// The curatorial taste lives in the query and the display label.

struct SoundPick {
    let title: String      // shown in UI
    let curator: String    // shown in UI as small caption
    let query: String      // sent to Spotify search

    var spotifyURL: URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "spotify://search/\(encoded)")
    }

    var webURL: URL? {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "https://open.spotify.com/search/\(encoded)")
    }
}

enum SoundLibrary {

    // Calm — for Protect mornings.
    // Spacious, almost-silent, japanese minimal, modern classical, ambient.
    static let calm: [SoundPick] = [
        SoundPick(title: "async — morning",          curator: "Ryuichi Sakamoto",      query: "ryuichi sakamoto async morning"),
        SoundPick(title: "Music for Nine Post Cards", curator: "Hiroshi Yoshimura",    query: "hiroshi yoshimura music for nine post cards"),
        SoundPick(title: "Prehension",                curator: "Joep Beving",          query: "joep beving prehension"),
        SoundPick(title: "Spaces",                    curator: "Nils Frahm",           query: "nils frahm spaces"),
        SoundPick(title: "The Pavilion of Dreams",    curator: "Harold Budd",          query: "harold budd pavilion of dreams"),
        SoundPick(title: "melodica in the morning",   curator: "Haruka Nakamura",      query: "haruka nakamura melodica morning"),
        SoundPick(title: "Selected Ambient Works II", curator: "Aphex Twin",           query: "aphex twin selected ambient works volume ii"),
        SoundPick(title: "Substrata",                 curator: "Biosphere",            query: "biosphere substrata"),
        SoundPick(title: "Discreet Music",            curator: "Brian Eno",            query: "brian eno discreet music"),
        SoundPick(title: "Empty Bliss Beyond This World", curator: "The Caretaker",    query: "the caretaker empty bliss"),
        SoundPick(title: "Music for Airports",        curator: "Brian Eno",            query: "brian eno music for airports"),
        SoundPick(title: "Air on Tape",               curator: "Library Tapes",        query: "library tapes air on tape"),
    ]

    // Focus — for Steady mornings.
    // Tokyo lo-fi, modern instrumental jazz, scandinavian downtempo, krautrock motorik.
    static let focus: [SoundPick] = [
        SoundPick(title: "Tokyo Lo-Fi · Morning",     curator: "Spotify Editorial",    query: "tokyo lo-fi morning"),
        SoundPick(title: "Welcome to the Hills",      curator: "Yussef Dayes",         query: "yussef dayes welcome to the hills"),
        SoundPick(title: "Texas Sun",                 curator: "Khruangbin & Leon Bridges", query: "khruangbin texas sun"),
        SoundPick(title: "Beat Tape 2",               curator: "Tom Misch",            query: "tom misch beat tape 2"),
        SoundPick(title: "Migration",                 curator: "Bonobo",               query: "bonobo migration"),
        SoundPick(title: "Antiphon",                  curator: "Alfa Mist",            query: "alfa mist antiphon"),
        SoundPick(title: "Salvation Jane",            curator: "Mildlife",             query: "mildlife salvation jane"),
        SoundPick(title: "Ruler Rebel",               curator: "Shabaka Hutchings",    query: "shabaka and the ancestors ruler rebel"),
        SoundPick(title: "Days of Delight",           curator: "Toshiyuki Miyama",     query: "toshiyuki miyama days of delight"),
        SoundPick(title: "Sweetheart",                curator: "Charlotte Day Wilson", query: "charlotte day wilson sweetheart"),
        SoundPick(title: "Black Focus",               curator: "Yussef Kamaal",        query: "yussef kamaal black focus"),
        SoundPick(title: "Structuralism",             curator: "Alfa Mist",            query: "alfa mist structuralism"),
    ]

    // Energy — for Push mornings.
    // Balearic, deep house, caribou-style modern dance, motorik, sunrise rave.
    static let energy: [SoundPick] = [
        SoundPick(title: "Balearic Sunrise",          curator: "Late Night Tales",     query: "balearic sunrise late night tales"),
        SoundPick(title: "Suddenly",                  curator: "Caribou",              query: "caribou suddenly"),
        SoundPick(title: "Crush",                     curator: "Floating Points",      query: "floating points crush"),
        SoundPick(title: "Projections",               curator: "Romare",               query: "romare projections"),
        SoundPick(title: "Ordinary Drugs",            curator: "Folamour",             query: "folamour ordinary drugs"),
        SoundPick(title: "In Colour",                 curator: "Jamie xx",             query: "jamie xx in colour"),
        SoundPick(title: "Jiaolong",                  curator: "Daphni",               query: "daphni jiaolong"),
        SoundPick(title: "Promises",                  curator: "Floating Points & Pharoah Sanders", query: "floating points pharoah sanders promises"),
        SoundPick(title: "Djesse Vol. 3",             curator: "Jacob Collier",        query: "jacob collier djesse vol 3"),
        SoundPick(title: "Honeyblood",                curator: "Honeyblood Sunrise",   query: "honeyblood sunrise mix"),
        SoundPick(title: "Sunset Service",            curator: "Hot Chip",             query: "hot chip sunset service"),
        SoundPick(title: "Singularity",               curator: "Jon Hopkins",          query: "jon hopkins singularity"),
    ]

    // Daily rotation — same key as MorningData variantIndex so picks
    // align with the rest of the day's content.
    static func todayPick(for direction: SoundDirection) -> SoundPick {
        let pool: [SoundPick]
        switch direction {
        case .calm:   pool = calm
        case .focus:  pool = focus
        case .energy: pool = energy
        }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return pool[day % pool.count]
    }
}
