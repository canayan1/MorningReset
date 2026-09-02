import XCTest

// The app is a practice app: pick a school, do one routine a day, watch the
// energy orb grow. These tests drive that loop and capture store screenshots.

final class MorningResetUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - The daily loop

    @MainActor
    func testDailyPracticeOpensTheGuidedPlayer() throws {
        let app = launchApp(language: "en", region: "en_US", extraArguments: ["-seedFirstWin"])
        tapButton(app, label: "Start today's practice", timeout: 8)
        // The player shows the step counter and a way to finish.
        let finish = app.buttons.matching(NSPredicate(format: "label == %@ OR label == %@", "Next step", "Finish")).firstMatch
        XCTAssertTrue(finish.waitForExistence(timeout: 8), "Routine player did not open")
    }

    @MainActor
    func testSchoolsTabListsEverySchoolAndOpensDetail() throws {
        let app = launchApp(language: "en", region: "en_US", extraArguments: ["-premiumLocked"])
        app.tabBars.buttons["Traditions"].tap()
        for id in ["reiki", "breathing", "qigong", "meditation", "yoga",
                   "sound", "coldheat", "sleep", "nature", "journal"] {
            let row = app.buttons["school.row.\(id)"]
            if !row.exists { app.swipeUp() }
            XCTAssertTrue(row.waitForExistence(timeout: 6), "Missing school row: \(id)")
        }
        app.buttons["school.row.reiki"].tap()
        XCTAssertTrue(app.staticTexts["Reiki"].waitForExistence(timeout: 6), "School detail did not open")
    }

    @MainActor
    func testLibraryFiltersRoutines() throws {
        let app = launchApp(language: "en", region: "en_US", extraArguments: ["-premiumLocked"])
        app.tabBars.buttons["Library"].tap()
        XCTAssertTrue(app.buttons["≤5 min"].waitForExistence(timeout: 6), "Length filters missing")
        app.buttons["≤5 min"].tap()
        XCTAssertTrue(app.staticTexts["Practice Library"].exists)
    }

    // MARK: - Store screenshots

    /// Captures the six store screenshots. The order tells the product story:
    /// the orb you grow, the ten schools, what a school teaches, the guided
    /// practice itself, the library behind it, and the record it leaves.
    @MainActor
    func testCaptureAppStoreScreenshots() throws {
        // Two launches rather than one. The school sheet scrolls a long way and
        // its close control goes with it, so dismissing it reliably costs more
        // than simply starting again — and a fresh launch is deterministic.
        let locked = launchApp(language: "en", region: "en_US",
                               extraArguments: ["-seedPractice", "-premiumLocked"])
        snapshot(locked, "01_Today")

        locked.tabBars.buttons["Traditions"].tap(); usleep(900_000)
        snapshot(locked, "02_Schools")

        locked.buttons["school.row.reiki"].tap(); usleep(900_000)
        tapWhenReady(locked, label: "Inside")
        usleep(1_200_000)
        // No scroll: the photographic header is the point of this panel, and
        // scrolling past it leaves nothing but a wall of type.
        snapshot(locked, "03_Teachings")
        locked.terminate()

        // The library and the record are about abundance, so show them to a
        // subscriber. A column of padlocks sells nothing.
        let full = launchApp(language: "en", region: "en_US",
                             extraArguments: ["-seedPractice", "-premiumUnlocked"])

        let begin = full.buttons["alarm.primaryButton"]
        waitForElement(begin, timeout: 8)
        begin.tap()
        usleep(9_000_000)   // let the tree grow far enough to read
        snapshot(full, "04_Practice")
        full.terminate()

        let last = launchApp(language: "en", region: "en_US",
                             extraArguments: ["-seedPractice", "-premiumUnlocked"])
        last.tabBars.buttons["Library"].tap(); usleep(1_000_000)
        snapshot(last, "05_Library")

        last.tabBars.buttons["Wins"].tap(); usleep(1_000_000)
        snapshot(last, "06_Progress")
    }

    // MARK: - Onboarding

    @MainActor
    func testCapturePaths() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetState",
                               "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["MR_LANGUAGE_OVERRIDE"] = "en"
        app.launch()

        // Hook (single slide now)
        let start = button(in: app, label: "Get started")
        waitForElement(start, timeout: 8)
        snapshot(app, "PA01_Hook")
        start.tap()

        // The energy orb introduction
        let orbCTA = button(in: app, label: "Grow my orb")
        waitForElement(orbCTA, timeout: 8)
        snapshot(app, "PA02_Orb")
        orbCTA.tap()

        // Ten schools — pick one
        let reiki = app.buttons["onboarding.school.reiki"]
        waitForElement(reiki, timeout: 8)
        snapshot(app, "PA03_Schools")
        reiki.tap()

        // First practice offered BEFORE any paywall
        let begin = button(in: app, label: "Begin")
        waitForElement(begin, timeout: 10)
        snapshot(app, "PA04_FirstPractice")
        tapWhenReady(app, label: "Later")   // don't run a full routine in the test

        // Payoff, then the paywall
        let planContinue = button(in: app, label: "Continue")
        waitForElement(planContinue, timeout: 10)
        snapshot(app, "PA05_Plan")
        planContinue.tap()

        if element(in: app, id: "paywall.screen").waitForExistence(timeout: 8) {
            snapshot(app, "PA06_Paywall")
        }
    }

    // MARK: - Helpers

    private func tapWhenReady(_ app: XCUIApplication, label: String) {
        let b = button(in: app, label: label)
        waitForElement(b, timeout: 6)
        b.tap()
    }

    private func snapshot(_ app: XCUIApplication, _ name: String) {
        usleep(1_400_000)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launchApp(language: String, region: String, extraArguments: [String]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting", "-resetState", "-skipOnboarding", "-enableSchedule",
            "-suppressPeriodicPaywall",
            "-AppleLanguages", "(\(language))", "-AppleLocale", region
        ] + extraArguments
        app.launchEnvironment["MR_LANGUAGE_OVERRIDE"] = language
        app.launch()
        return app
    }

    private func button(in app: XCUIApplication, label: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    private func tapButton(_ app: XCUIApplication, label: String, timeout: TimeInterval = 6) {
        let b = button(in: app, label: label)
        waitForElement(b, timeout: timeout)
        b.tap()
    }

    private func element(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Timed out waiting for element")
    }
}
