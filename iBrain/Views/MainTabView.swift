import SwiftUI

struct MainTabView: View {
    @State private var selection: Tab = MainTabView.initialTab

    enum Tab: Hashable {
        case explore, learn, library
    }

    /// Screenshot/debug helper: `-tab=learn` or `-tab=library`.
    static var initialTab: Tab {
        #if DEBUG
        if let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-tab=") }) {
            switch arg.dropFirst(5) {
            case "learn": return .learn
            case "library": return .library
            default: return .explore
            }
        }
        #endif
        return .explore
    }

    var body: some View {
        TabView(selection: $selection) {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "brain.head.profile")
                }
                .tag(Tab.explore)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(Tab.learn)

            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "bookmark")
                }
                .tag(Tab.library)
        }
        .tint(Theme.accent)
    }
}

#Preview {
    MainTabView()
}
