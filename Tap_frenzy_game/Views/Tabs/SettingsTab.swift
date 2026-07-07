//
//  SettingsTab.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI
import UserNotifications

struct SettingsTab: View {
    @AppStorage("isNotificationEnabled") private var isNotificationEnabled = false
    @State private var selectedTime = Date()
    
    // State to control the confirmation dialog pop-up
    @State private var showResetConfirmation = false
    
    var body: some View {
        List {
            // --- SECTION 1: NOTIFICATIONS ---
            Section(header: Text("Notifications")) {
                Toggle("Daily Challenge Reminder", isOn: $isNotificationEnabled)
                    .onChange(of: isNotificationEnabled) { _, enabled in
                        if enabled { requestAndSchedule() }
                        else { cancelNotification() }
                    }
                
                if isNotificationEnabled {
                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .onChange(of: selectedTime) { _, _ in
                            scheduleNotification()
                        }
                }
            }
            
            // --- SECTION 2: RESET STATS (DANGER ZONE) ---
            Section(header: Text("Clear Stats")) {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Label("Reset All Stats & Progress", systemImage: "trash.fill")
                        .foregroundColor(.red)
                }
            }
        }
        // Native iOS confirmation prompt for destructive actions
        .confirmationDialog(
            "Are you completely sure?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Yes, Clear Everything", role: .destructive) {
                clearAppStats()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently erase your high scores, game sessions, and charts history. This action cannot be undone.")
        }
    }
    
    // MARK: - Reset Data Logic
    private func clearAppStats() {
        // 1. Clear high scores inside ScoreManager (updates HomeTab instantly)
        ScoreManager.shared.resetAllScores()
        
        // 2. Clear history sessions if you have a GameSessionManager setup
        // GameSessionManager.shared.clearAllSessions()
        GameSessionManager.shared.clearAllSessions()
        // 3. Clear the daily challenge completion status so they can play it again
        UserDefaults.standard.removeObject(forKey: "challenge_completed_today")
        
        // 4. Force a full clear of any remaining history tracking keys
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "game_sessions_key")
        
        print("All game statistics have been permanently deleted.")
    }
    
    // MARK: - Notification Logic
    private func requestAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                scheduleNotification()
            } else {
                DispatchQueue.main.async { isNotificationEnabled = false }
            }
        }
    }
    
    private func scheduleNotification() {
        cancelNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Daily Challenge Active!"
        content.body = "Tap to open the app and play today's challenge!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }
}


#Preview {
    SettingsTab()
}

