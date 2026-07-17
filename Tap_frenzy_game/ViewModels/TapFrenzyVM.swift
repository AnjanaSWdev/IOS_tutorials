//
//  File.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import SwiftUI
import Combine
internal import _LocationEssentials

// Core structure representing a single floating score animation popup
struct ScorePop: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    var offset: CGSize
    var opacity: Double = 1.0
}

enum ButtonColorState {
    case blue
    case green
    case grey
}

@Observable
class TapFrenzyVM {
    
    var countDownTimer = 10
    var timerRunning = false
    var score = 0
    var showGameOver = false
    
    // Dynamic Game Modifiers
    var buttonColorState: ButtonColorState = .blue
    var buttonOffset: CGSize = .zero
    var scorePops: [ScorePop] = [] // Keeps track of active float animations
    
    func handleTap() {
        if countDownTimer > 0 && timerRunning {
            let popText: String
            let popColor: Color
            
            // Calculate point changes and pop design based on button color
            switch buttonColorState {
            case .blue:
                score += 1
                popText = "+1"
                popColor = .cyan
            case .green:
                score += 3
                popText = "+3"
                popColor = .green
            case .grey:
                score = max(0, score - 2)
                popText = "-2"
                popColor = .red
            }
            
            // Trigger floating text pop
            triggerPop(text: popText, color: popColor)
            
        } else if !timerRunning && !showGameOver {
            // Starts the game loop on the first tap
            timerRunning = true
            
            // Instantly transition position and color on first tap
            updateButtonPosition()
            changeButtonColor()
        }
    }
    
    func updateTimer() {
        if timerRunning && countDownTimer > 0 {
            countDownTimer -= 1
            
            // Jumps to a random position and changes color state every 2 seconds
            if countDownTimer % 2 == 0 && countDownTimer > 0 {
                updateButtonPosition()
                changeButtonColor()
            }
            
            if countDownTimer == 0 {
                timerRunning = false
                showGameOver = true
                checkHighScore()
                
                // Reset positions back to default center once game ends
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    buttonOffset = .zero
                    buttonColorState = .blue
                }
                
                // Get current GPS Coordinates
                let currentLat = LocationService.shared.currentLocation?.coordinate.latitude ?? 0
                let currentLng = LocationService.shared.currentLocation?.coordinate.longitude ?? 0

                GameSessionManager.shared.recordSession(
                    mode: .tapFrenzy,
                    score: score,
                    latitude: currentLat,
                    longitude: currentLng
                )

                // Check for daily challenge completion
                let currentDailyMode = UserDefaults.standard.string(forKey: "daily_challenge_mode") ?? "TapFrenzy"
                if currentDailyMode == "TapFrenzy" {
                    UserDefaults.standard.set(true, forKey: "challenge_completed_today")
                }
            }
        }
    }
    
    func resetGame() {
        showGameOver = false
        countDownTimer = 10
        score = 0
        buttonColorState = .blue
        buttonOffset = .zero
        scorePops.removeAll()
    }
    
    private func checkHighScore() {
        ScoreManager.shared.updateTapFrenzyHighScore(with: score)
    }
    
    // Generates high-speed spring dynamic coordinates (Response tightened from 0.45s -> 0.28s)
    private func updateButtonPosition() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
            // Screen boundaries
            let randomX = CGFloat.random(in: -75...75)
            let randomY = CGFloat.random(in: -120...120)
            buttonOffset = CGSize(width: randomX, height: randomY)
        }
    }
    
    // Randomizes colors (60% Blue, 20% Green, 20% Grey)
    private func changeButtonColor() {
        let diceRoll = Double.random(in: 0...1)
        if diceRoll < 0.6 {
            buttonColorState = .blue
        } else if diceRoll < 0.8 {
            buttonColorState = .green
        } else {
            buttonColorState = .grey
        }
    }
    
    // Spawns and starts the upward drifting fade-out animation sequence
    private func triggerPop(text: String, color: Color) {
        // Center the pop on the button's exact position with a slight randomized horizontal scatter
        let initialPop = ScorePop(
            text: text,
            color: color,
            offset: CGSize(width: buttonOffset.width + CGFloat.random(in: -25...25), height: buttonOffset.height - 35)
        )
        scorePops.append(initialPop)
        
        let targetID = initialPop.id
        
        // Triggers SwiftUI to cleanly animate layout parameters
        withAnimation(.easeOut(duration: 0.55)) {
            if let index = scorePops.firstIndex(where: { $0.id == targetID }) {
                scorePops[index].offset.height -= 70 // Float up
                scorePops[index].opacity = 0.0       // Fade away
            }
        }
        
        // Memory cleanup to remove pop once transaction is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            self.scorePops.removeAll { $0.id == targetID }
        }
    }
}
