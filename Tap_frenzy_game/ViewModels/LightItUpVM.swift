//
//  LightItUp.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-05.
//

import Foundation
import SwiftUI
internal import _LocationEssentials

struct LevelConfig {
    let name: String
    let cardCount: Int
    let litWindow: Double
    let color: Color
    let columnsCount: Int
    let concurrentLit: Int
}


@Observable
class LightItUpVM {
    
    // Game States
    var score: Int = 0
    var timeElapsed: Int = 0
    var lives: Int = 3
    var activeCardIndices: Set<Int> = []
    var isGameActive: Bool = false
    var showGameOverModal: Bool = false
    
    // Persistent Highscore (Bound via modern AppStorage access)
    private let highScoreKey = "lightItUpHighScore"
    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: highScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: highScoreKey) }
    }
    
    // Internal Timers
    private var gameTimer: Timer? = nil
    private var glowTimer: Timer? = nil
    
    // Dynamic level configurations based on elapsed time
    var currentLevel: LevelConfig {
        if timeElapsed < 15 {
            return LevelConfig(name: "L1", cardCount: 3, litWindow: 1.5, color: .green, columnsCount: 3, concurrentLit: 1)
        } else if timeElapsed < 30 {
            return LevelConfig(name: "L2", cardCount: 4, litWindow: 1.2, color: .blue, columnsCount: 3, concurrentLit: 1)
        } else if timeElapsed < 45 {
            return LevelConfig(name: "L3", cardCount: 6, litWindow: 1.0, color: .yellow, columnsCount: 3, concurrentLit: 1)
        } else {
            return LevelConfig(name: "L4", cardCount: 9, litWindow: 0.8, color: .orange, columnsCount: 3, concurrentLit: 2)
        }
    }
    
    var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columnsCount)
    }
    
    // Core Game Mechanics
    func startGame() {
        score = 0
        timeElapsed = 0
        lives = 3
        showGameOverModal = false
        isGameActive = true
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeElapsed < 60 {
                self.timeElapsed += 1
            } else {
                self.endGame(dueToLives: false)
            }
        }
        
        triggerNextGlow()
    }
    
    func triggerNextGlow() {
        glowTimer?.invalidate()
        activeCardIndices.removeAll()
        
        let config = currentLevel
        var generatedIndices = Set<Int>()
        
        let countToLit = min(config.concurrentLit, config.cardCount)
        while generatedIndices.count < countToLit {
            let randomIndex = Int.random(in: 0..<config.cardCount)
            generatedIndices.insert(randomIndex)
        }
        
        activeCardIndices = generatedIndices
        
        glowTimer = Timer.scheduledTimer(withTimeInterval: config.litWindow, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.activeCardIndices.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.isGameActive { self.triggerNextGlow() }
            }
        }
    }
    
    func handleCardTap(at index: Int) {
        if activeCardIndices.contains(index) {
            score += 1
            activeCardIndices.remove(index)
            
            if activeCardIndices.isEmpty {
                triggerNextGlow()
            }
        } else {
            if lives > 0 { lives -= 1 }
            if lives == 0 { endGame(dueToLives: true) }
        }
    }
    
    func endGame(dueToLives: Bool) {
        isGameActive = false
        gameTimer?.invalidate()
        glowTimer?.invalidate()
        activeCardIndices.removeAll()
        
        if !dueToLives {
            if score > highScore { highScore = score }
            
            ScoreManager.shared.updateLightItUpHighScore(with: highScore)
            
            let currentLat = LocationService.shared.currentLocation?.coordinate.latitude ?? 6.9114
            let currentLng = LocationService.shared.currentLocation?.coordinate.longitude ?? 79.8647
                
                // Record session with location
                GameSessionManager.shared.recordSession(
                    mode: .lightItUp,
                    score: score,
                    latitude: currentLat,
                    longitude: currentLng
                )
            let currentDailyMode = UserDefaults.standard.string(forKey: "daily_challenge_mode") ?? "TapFrenzy"
            if currentDailyMode == "LightItUp" {
                UserDefaults.standard.set(true, forKey: "challenge_completed_today")
            }
        }
        
        withAnimation {
            showGameOverModal = true
        }
    }
    
    deinit {
        gameTimer?.invalidate()
        glowTimer?.invalidate()
    }
}

