//
//  File.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI

struct TabShell: View {
    // Keeps track of the active tab selection
    @State private var selectedTab: Tab = .home
    
    enum Tab: Int, CaseIterable {
        case home
        case stats
        case map
        case settings
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .stats: return "Stats"
            case .map: return "Map"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .stats: return "chart.bar.xaxis"
            case .map: return "map.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
           
            NavigationStack {
                HomeTab()
                    .navigationTitle(Tab.home.title)
            }
            .tabItem {
                Label(Tab.home.title, systemImage: Tab.home.icon)
            }
            .tag(Tab.home)
            
           
            NavigationStack {
                StatsTab()
                    .navigationTitle(Tab.stats.title)
            }
            .tabItem {
                Label(Tab.stats.title, systemImage: Tab.stats.icon)
            }
            .tag(Tab.stats)
            
           
            NavigationStack {
                MapTab()
                    .navigationTitle(Tab.map.title)
            }
            .tabItem {
                Label(Tab.map.title, systemImage: Tab.map.icon)
            }
            .tag(Tab.map)
            
           
            NavigationStack {
                SettingsTab()
                    .navigationTitle(Tab.settings.title)
            }
            .tabItem {
                Label(Tab.settings.title, systemImage: Tab.settings.icon)
            }
            .tag(Tab.settings)
        }
        
    }
}



#Preview {
   TabShell()
}
