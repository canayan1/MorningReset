import Foundation

enum ActionContent {

    private static var dayIndex: Int {
        Calendar.current.component(.day, from: Date())
    }

    static var todayInsight: String {
        let pool = InsightContent.all
        return pool[dayIndex % pool.count]
    }

    static var todayBonusAction: String {
        let pool = ExtraActionContent.all
        return pool[dayIndex % pool.count]
    }
}
