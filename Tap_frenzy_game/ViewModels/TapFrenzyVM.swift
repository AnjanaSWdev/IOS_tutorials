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

@Observable
class TapFrenzyVM {
    
    var countDownTimer = 10
    var timerRunning = false
    var score = 0
    var showGameOver = false
    
    func handleTap() {
        if countDownTimer > 0 && timerRunning {
            score += 1
        } else if !timerRunning && !showGameOver {
            // Starts the game loop on the first tap
            timerRunning = true
        }
    }
    
    func updateTimer() {
        if timerRunning && countDownTimer > 0 {
            countDownTimer -= 1
            
            if countDownTimer == 0 {
                timerRunning = false
                showGameOver = true
                checkHighScore()
                
                // Get current GPS Coordinates
                
                let currentLat = LocationService.shared.currentLocation?.coordinate.latitude ?? 6.9114
                let currentLng = LocationService.shared.currentLocation?.coordinate.longitude ?? 79.8647

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
    }
    
    private func checkHighScore() {
        ScoreManager.shared.updateTapFrenzyHighScore(with: score)
    }
}
