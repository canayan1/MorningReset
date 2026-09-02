import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        TabView(selection: $state.activeTab) {
            AlarmView()
                .tabItem {
                    Label(
                        L10n.text(en: "Today", tr: "Bugün", es: "Hoy"),
                        systemImage: "house.fill"
                    )
                }
                .tag(AppTab.today)

            SchoolsView()
                .tabItem {
                    Label(
                        L10n.text(en: "Traditions", tr: "Gelenekler", es: "Tradiciones"),
                        systemImage: "sparkles"
                    )
                }
                .tag(AppTab.schools)

            LibraryView()
                .tabItem {
                    Label(
                        L10n.text(en: "Library", tr: "Kütüphane", es: "Biblioteca"),
                        systemImage: "books.vertical.fill"
                    )
                }
                .tag(AppTab.library)

            MyWinsView()
                .tabItem {
                    Label(
                        L10n.text(en: "Wins", tr: "Kazanımlar", es: "Logros"),
                        systemImage: "trophy.fill"
                    )
                }
                .tag(AppTab.wins)
        }
        .tint(DS.accent)
    }
}
