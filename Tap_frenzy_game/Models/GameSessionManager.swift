//
//  GameSessionManager.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import Observation

@Observable
class GameSessionManager {
    static let shared = GameSessionManager()
    
    // The master list holding every single played game session
    var sessions: [GameSession] = []
    
    private let cacheKey = "game_sessions_key"
    
    private init() {
        loadSessions()
    }
    
    // Records a new game session and appends it to history
    func recordSession(mode: GameMode, score: Int, latitude: Double, longitude: Double) {
        
        // Create a completely brand new session with a unique ID every single time
        let newSession = GameSession(
            id: UUID(),
            mode: mode,
            score: score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        
        // Append to the array so old matches are NEVER deleted ---
        self.sessions.append(newSession)
        
        // Persist the entire updated history array to the phone
        saveSessions()
    }
    
    // Saves the full array to local storage as encoded JSON data
    private func saveSessions() {
        do {
            let data = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("Failed to encode game sessions: \(error.localizedDescription)")
        }
    }
    
    // Loads the full history back into memory when the app opens up
    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: cacheKey) {
            do {
                let decoded = try JSONDecoder().decode([GameSession].self, from: data)
                self.sessions = decoded
            } catch {
                print("Failed to decode game sessions: \(error.localizedDescription)")
            }
        }
    }
    
    // Clears everything out cleanly when hitting Reset in Settings
    func clearAllSessions() {
        self.sessions = []
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
}
