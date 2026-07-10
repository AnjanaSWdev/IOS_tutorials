//
//  StatsVM.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import SwiftUI

// A simple, explicit model that the Chart can read instantly without guessing types
struct ChartDataPoint: Identifiable {
    let id: UUID
    let label: String
    let score: Int
    let mode: GameMode
}

@Observable
class StatsVM {
    var sessionManager = GameSessionManager.shared
    var selectedChartMode: GameMode = .lightItUp
    
    var totalGamesPlayed: Int {
        sessionManager.sessions.count
    }
    
    var totalScoreAccumulated: Int {
        sessionManager.sessions.reduce(0) { $0 + $1.score }
    }
    
    func personalBest(for mode: GameMode) -> Int {
        sessionManager.sessions
            .filter { $0.mode == mode }
            .map { $0.score }
            .max() ?? 0
    }
    
    var recentSessions: [GameSession] {
        sessionManager.sessions.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Pre-compute chart data points explicitly
    var chartDataPoints: [ChartDataPoint] {
        let filtered = sessionManager.sessions
            .filter { $0.mode == selectedChartMode }
            .sorted { $0.timestamp < $1.timestamp }
        
        return filtered.enumerated().map { index, session in
            ChartDataPoint(
                id: session.id,
                label: "G\(index + 1)",
                score: session.score,
                mode: session.mode
            )
        }
    }
}
