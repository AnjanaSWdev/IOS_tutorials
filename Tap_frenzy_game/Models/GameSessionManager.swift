//
//  GameSessionManager.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import SwiftUI

@Observable
class GameSessionManager {
    static let shared = GameSessionManager()
    
    var sessions: [GameSession] = []
    private let storageKey = "saved_game_sessions"
    
    private init() {
        loadSessions()
    }
    
    /// Appends a newly completed game session and updates persistent storage.
    func recordSession(mode: GameMode, score: Int, latitude: Double = 0.0, longitude: Double = 0.0) {
        let newSession = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        sessions.append(newSession)
        saveSessions()
        
        DailyChallengeManager.shared.verifyAndCompleteChallenge(mode: mode)
    }
    
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode game sessions: \(error.localizedDescription)")
        }
    }
    
    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            self.sessions = try JSONDecoder().decode([GameSession].self, from: data)
        } catch {
            print("Failed to decode game sessions: \(error.localizedDescription)")
        }
    }
    
    func clearAllSessions() {
        self.sessions = [] // If your array is named 'allSessions' or something else, match it here
            
            // 2. Erase the persistent file data from storage
            UserDefaults.standard.removeObject(forKey: "game_sessions_key")
            UserDefaults.standard.removeObject(forKey: "sessions")
    }
    
}
