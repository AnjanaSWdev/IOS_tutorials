//
//  TapFrenzy.swift
//  Tap_frenzy_game
//
//  Created by TEST on 2026-06-10.
//

import SwiftUI
import Combine

struct TapFrenzyView: View {
    
    // 1. Added this to allow the Exit button to pop back to the menu
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = TapFrenzyVM()
    
    // Timer publisher remains a UI wrapper responsibility for view triggers
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.10, green: 0.14, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header Layout
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.score)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Time")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.countDownTimer)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                .padding(.horizontal)

                Spacer()

                // Main Tap Button
                Button(action: viewModel.handleTap) {
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

                VStack(spacing: 8) {
                    if !viewModel.timerRunning {
                        Text("Tap to Start")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.vertical)
            
            
            if viewModel.showGameOver {
                // Dimmed background to focus the popup
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("GAME OVER")
                        .font(.title).bold()
                        .foregroundColor(.red)
                        .tracking(2)
                    
                    // Final Score Box
                    VStack(spacing: 4) {
                        Text("FINAL SCORE")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(viewModel.score)")
                            .font(.system(size: 54, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 0.08, green: 0.11, blue: 0.15))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        
                        // Play Again
                        Button(action: {
                            withAnimation { viewModel.showGameOver = false }
                            viewModel.resetGame()
                        }) {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        // Native Share Score Button
                        ShareLink(item: "I just scored \(viewModel.score) points in Tap Frenzy! Can you beat my speed?") {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Score")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        
                        // Exit Button
                        Button(action: {
                            withAnimation { viewModel.showGameOver = false }
                            dismiss()
                        }) {
                            Text("Exit to Menu")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(28)
                .frame(width: 320)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.16, green: 0.19, blue: 0.23))
                        .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 15)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        // 3. Added smooth spring animation for when the popup appears
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.showGameOver)
        .onReceive(timer) { _ in
            viewModel.updateTimer()
        }
    }
}

// Button Style Component
struct ScaledPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    TapFrenzyView()
}

