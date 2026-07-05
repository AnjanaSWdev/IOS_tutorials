//
//  TapFrenzy.swift
//  Tap_frenzy_game
//
//  Created by TEST on 2026-06-10.
//

import SwiftUI
import Combine

struct TapFrenzy: View {
    
    @State var countDownTimer = 10
    @State var timerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var score = 0
    
    @State private var showGameOver = false
    
    private func resetGame() {
        
            showGameOver = false
            countDownTimer = 10
            score = 0
            
            
        }
    private func checkHighScore() {
        ScoreManager.shared.updateTapFrenzyHighScore(with: score)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.10, green: 0.14, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(score)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(countDownTimer)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()

                // Main Tap Button
                Button(action: {
                    if(countDownTimer > 0 && timerRunning == true){
                        score += 1
                    }
                    else{
                        timerRunning = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 220, height: 220)
                            .shadow(color: Color.blue.opacity(0.4), radius: 16, x: 0, y: 10)

                        Circle()
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 240, height: 240)

                        Text("TAP")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
                .buttonStyle(ScaledPressButtonStyle())

                // Progress bar
                VStack(spacing: 8) {
                    if !timerRunning {
                        Text("Tap to Start")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.vertical)
        }
        .onReceive(timer) { _ in
            if countDownTimer > 0 && timerRunning{
                countDownTimer -= 1
            }else if countDownTimer == 0{
                timerRunning = false
                showGameOver = true
                checkHighScore()
            }
        }
        .alert("Game Over", isPresented: $showGameOver) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("Final Score: \(score) points")
        }
    }
}

struct ScaledPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    TapFrenzy()
}

