//
//  iBrainApp.swift
//  iBrain
//

import SwiftUI

@main
struct iBrainApp: App {
    init() {
        AppAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .tint(Theme.accent)
        }
    }
}

/// UIKit-level chrome so the tab bar and navigation bars match the paper-white palette.
enum AppAppearance {
    static func configure() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = UIColor(Theme.background)
        tab.shadowColor = UIColor(Theme.hairline)

        let item = tab.stackedLayoutAppearance
        item.normal.iconColor = UIColor(Theme.textTertiary)
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.textTertiary),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        item.selected.iconColor = UIColor(Theme.accent)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.accent),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(Theme.background)
        nav.shadowColor = .clear
        nav.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.textPrimary),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Theme.accent)
    }
}
