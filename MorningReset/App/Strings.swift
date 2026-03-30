import Foundation

enum Strings {

    enum Alarm {
        static let title       = "Morning Reset"
        static let startButton = "Start"
    }

    enum Quiz {
        static func progress(current: Int, total: Int) -> String {
            "\(current)/\(total)"
        }
    }

    enum Results {
        static let startWithLabel = "Start with"
        static let avoidLabel     = "Avoid"
        static let winTodayLabel  = "First win"
        static let continueButton = "Continue"
    }

    enum Action {
        static let heading    = "Keep moving."
        static let skipButton = "Skip"
        static let backButton = "Back"
    }
}
