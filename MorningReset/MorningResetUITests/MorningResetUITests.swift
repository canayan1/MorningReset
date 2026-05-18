import XCTest

final class MorningResetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testHappyPathCompletesResetInEnglishTurkishAndSpanish() throws {
        let locales: [(language: String, region: String)] = [
            ("en", "en_US"),
            ("tr", "tr_TR"),
            ("es", "es_ES")
        ]

        for locale in locales {
            let app = launchApp(
                language: locale.language,
                region: locale.region,
                extraArguments: ["-premiumLocked"]
            )

            runHappyPath(on: app, language: locale.language)
            app.terminate()
        }
    }

    @MainActor
    func testPremiumGateSmokeAppearsForStrongPatternAndCanBeDismissed() throws {
        let app = launchApp(
            language: "es",
            region: "es_ES",
            extraArguments: ["-premiumLocked", "-seedStrongPattern"]
        )

        tapStartFlow(in: app, language: "es")
        answerSteadyQuiz(in: app, language: "es")
        tapResultsContinue(in: app, language: "es")

        tapPaywallSecondary(in: app, language: "es")
        waitForElement(actionPrimaryButton(in: app, language: "es"))
    }

    private func runHappyPath(on app: XCUIApplication, language: String) {
        tapStartFlow(in: app, language: language)
        answerSteadyQuiz(in: app, language: language)
        tapResultsContinue(in: app, language: language)
        waitForElement(actionPrimaryButton(in: app, language: language), timeout: 8)
        actionPrimaryButton(in: app, language: language).tap()
        tapWinContinue(in: app, language: language)
        tapCheckoutFinish(in: app, language: language)
        waitForElement(startFlowButton(in: app, language: language))
    }

    private func answerSteadyQuiz(in app: XCUIApplication, language: String) {
        let answers: [String]
        switch language {
        case "tr":
            answers = ["Hayır", "Hayır", "Evet", "Evet", "Hayır"]
        case "es":
            answers = ["No", "No", "Sí", "Sí", "No"]
        default:
            answers = ["No", "No", "Yes", "Yes", "No"]
        }

        waitForElement(app.buttons[answers[0]])

        for answer in answers {
            waitForElement(app.buttons[answer])
            app.buttons[answer].tap()
        }
    }

    private func tapStartFlow(in app: XCUIApplication, language: String) {
        waitForElement(startFlowButton(in: app, language: language))
        startFlowButton(in: app, language: language).tap()
    }

    private func tapResultsContinue(in app: XCUIApplication, language: String) {
        let button = resultsContinueButton(in: app, language: language)
        waitForElement(button, timeout: 8)
        button.tap()
    }

    private func tapPaywallSecondary(in app: XCUIApplication, language: String) {
        let button = paywallSecondaryButton(in: app, language: language)
        waitForElement(button, timeout: 8)
        button.tap()
    }

    private func tapWinContinue(in app: XCUIApplication, language: String) {
        let button = winContinueButton(in: app, language: language)
        waitForElement(button)
        button.tap()
    }

    private func tapCheckoutFinish(in app: XCUIApplication, language: String) {
        let button = checkoutFinishButton(in: app, language: language)
        waitForElement(button)
        button.tap()
    }

    private func startFlowButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[startFlowTitle(for: language)]
    }

    private func resultsContinueButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[resultsContinueTitle(for: language)]
    }

    private func actionPrimaryButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[actionPrimaryTitle(for: language)]
    }

    private func winContinueButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[winContinueTitle(for: language)]
    }

    private func checkoutFinishButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[checkoutFinishTitle(for: language)]
    }

    private func paywallSecondaryButton(in app: XCUIApplication, language: String) -> XCUIElement {
        app.buttons[paywallSecondaryTitle(for: language)]
    }

    private func startFlowTitle(for language: String) -> String {
        switch language {
        case "tr": return "Morning Reset'i başlat"
        case "es": return "Iniciar Morning Reset"
        default: return "Start Morning Reset"
        }
    }

    private func resultsContinueTitle(for language: String) -> String {
        switch language {
        case "tr": return "Bu ilk kazanımla devam et"
        case "es": return "Continuar con esta primera victoria"
        default: return "Continue with this first win"
        }
    }

    private func actionPrimaryTitle(for language: String) -> String {
        switch language {
        case "tr": return "Göreve başladım"
        case "es": return "Empecé la tarea"
        default: return "I started the task"
        }
    }

    private func winContinueTitle(for language: String) -> String {
        switch language {
        case "tr": return "Devam et"
        case "es": return "Continuar"
        default: return "Continue"
        }
    }

    private func checkoutFinishTitle(for language: String) -> String {
        switch language {
        case "tr": return "Reset'i bitir"
        case "es": return "Terminar reset"
        default: return "Finish reset"
        }
    }

    private func paywallSecondaryTitle(for language: String) -> String {
        switch language {
        case "tr": return "Premium olmadan devam et"
        case "es": return "Continuar sin Premium"
        default: return "Continue without Premium"
        }
    }

    private func launchApp(
        language: String,
        region: String,
        extraArguments: [String]
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-resetState",
            "-skipOnboarding",
            "-enableSchedule",
            "-suppressPeriodicPaywall",
            "-AppleLanguages",
            "(\(language))",
            "-AppleLocale",
            region
        ] + extraArguments
        app.launchEnvironment["MR_LANGUAGE_OVERRIDE"] = language
        app.launch()
        waitForElement(element(in: app, id: "alarm.primaryButton"))
        return app
    }

    private func tap(_ app: XCUIApplication, id: String, timeout: TimeInterval = 5) {
        let element = element(in: app, id: id)
        waitForElement(element, timeout: timeout)
        element.tap()
    }

    private func element(in app: XCUIApplication, id: String) -> XCUIElement {
        app.descendants(matching: .any)[id]
    }

    private func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout))
    }
}
