//
//  GameSession.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case lightItUp = "Light It Up"
    case tapFrenzy = "Tap Frenzy"
    case quizRush = "Quiz Rush"
    
    var id: String { self.rawValue }
}

struct GameSession: Codable, Identifiable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}
