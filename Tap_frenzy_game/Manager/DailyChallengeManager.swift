//
//  DailyChallengeManager.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import UserNotifications
import SwiftUI

@Observable
class DailyChallengeManager {
    static let shared = DailyChallengeManager()
    
    var currentChallengeMode: GameMode = .tapFrenzy
    var isCompletedToday: Bool = false
    
    private let lastCompletedKey = "daily_challenge_last_completed_date"
    private let currentModeKey = "daily_challenge_current_mode"
    private let currentDateKey = "daily_challenge_current_date"
    
    private init() {
        generateDailyChallenge()
        checkCompletion()
    }
    
    // Generates a locked daily mode that stays static for the calendar date
    func generateDailyChallenge() {
        let calendar = Calendar.current
        let today = Date()
        
        if let savedDate = UserDefaults.standard.object(forKey: currentDateKey) as? Date,
           calendar.isDate(savedDate, inSameDayAs: today),
           let savedModeRaw = UserDefaults.standard.string(forKey: currentModeKey),
           let savedMode = GameMode(rawValue: savedModeRaw) {
            self.currentChallengeMode = savedMode
        } else {
            // Pick a completely random game mode selection for the day
            let allModes = GameMode.allCases
            self.currentChallengeMode = allModes.randomElement() ?? .tapFrenzy
            
            UserDefaults.standard.set(today, forKey: currentDateKey)
            UserDefaults.standard.set(currentChallengeMode.rawValue, forKey: currentModeKey)
        }
    }
    
    // Verifies if completion date matches today
    func checkCompletion() {
        let calendar = Calendar.current
        if let lastCompleted = UserDefaults.standard.object(forKey: lastCompletedKey) as? Date {
            isCompletedToday = calendar.isDate(lastCompleted, inSameDayAs: Date())
        } else {
            isCompletedToday = false
        }
    }
    
    // Called automatically when a matching game mode finishes
    func verifyAndCompleteChallenge(mode: GameMode) {
        if mode == currentChallengeMode && !isCompletedToday {
            withAnimation {
                isCompletedToday = true
            }
            UserDefaults.standard.set(Date(), forKey: lastCompletedKey)
        }
    }
    
    // Requests local notification permission alerts
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.scheduleDailyNotification()
                }
                completion(granted)
            }
        }
    }
    
    // Schedules a repeating local alert notification trigger
    func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎯 Daily Challenge Active!"
        content.body = "Today's challenge is waiting for you in \(currentChallengeMode.rawValue). Can you set a new high score?"
        content.sound = .default
        
        // Schedules notification for 9:00 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_challenge_alert", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
