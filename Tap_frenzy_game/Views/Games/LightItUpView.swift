//
//  File.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import Foundation
import SwiftUI

struct LightItUpView: View {
    
    @State private var viewModel = LightItUpVM()
    
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.15)
                .ignoresSafeArea()
            
            // Main Game Layer
            if !viewModel.showGameOverModal {
                VStack(spacing: 20) {
                    
                    // Top Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.caption).foregroundColor(.gray)
                            Text("\(viewModel.score)")
                                .font(.largeTitle).bold().foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        if viewModel.isGameActive {
                            VStack(spacing: 4) {
                                Text("LEVEL")
                                    .font(.caption).foregroundColor(.gray)
                                Text(viewModel.currentLevel.name)
                                    .font(.headline).bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(viewModel.currentLevel.color.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME")
                                .font(.caption).foregroundColor(.gray)
                            Text("\(60 - viewModel.timeElapsed)s")
                                .font(.largeTitle).bold().foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Lives Display
                    if viewModel.isGameActive {
                        HStack(spacing: 6) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(index < viewModel.lives ? .red : .gray.opacity(0.3))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Game View Grid
                    if viewModel.isGameActive {
                        ScrollView {
                            LazyVGrid(columns: viewModel.columns, spacing: 12) {
                                ForEach(0..<viewModel.currentLevel.cardCount, id: \.self) { index in
                                    CardView(
                                        isGlowing: viewModel.activeCardIndices.contains(index),
                                        glowColor: viewModel.currentLevel.color
                                    ) {
                                        viewModel.handleCardTap(at: index)
                                    }
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                                    .shadow(radius: 10)
                            )
                        }
                        .padding(.horizontal, 16)
                        .frame(maxHeight: 520)
                    } else {
                        // Initial Landing Menu Screen
                        VStack(spacing: 20) {
                            Text("Light It Up")
                                .font(.largeTitle).bold().foregroundColor(.white)
                            
                            Button(action: viewModel.startGame) {
                                Text("Start Game")
                                    .font(.headline).foregroundColor(.white)
                                    .padding().frame(width: 200)
                                    .background(Color.blue).cornerRadius(12)
                            }
                        }
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
            
            // Game Over PopUp Window
            if viewModel.showGameOverModal {
                VStack(spacing: 24) {
                    Text(viewModel.lives == 0 ? "GAME OVER" : "VICTORY!")
                        .font(.title).bold()
                        .foregroundColor(viewModel.lives == 0 ? .red : .green)
                        .tracking(2)
                    
                    Text(viewModel.lives == 0 ? "You ran out of lives." : "You survived the whole 60 seconds!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // Center Focused Score Box
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
                    
                    // Action Button
                    Button(action: {
                        withAnimation {
                            viewModel.showGameOverModal = false
                        }
                        viewModel.startGame()
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    ShareLink(item: "I just scored \(viewModel.score) points in Light It Up! Think you have a better memory?") {
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
                }
                
                
                .padding(28)
                .frame(width: 320)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.16, green: 0.19, blue: 0.23))
                        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 15)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.showGameOverModal)
    }
}

// Card Component (Kept private or internal to the view file)
struct CardView: View {
    let isGlowing: Bool
    let glowColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isGlowing ? glowColor : Color(red: 0.16, green: 0.19, blue: 0.23))
                .aspectRatio(0.8, contentMode: .fit)
                .shadow(color: isGlowing ? glowColor.opacity(0.7) : Color.clear, radius: isGlowing ? 14 : 0)
                .animation(.easeInOut(duration: 0.1), value: isGlowing)
        }
        .buttonStyle(StaticButtonStyle())
    }
}

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label }
}

#Preview {
    LightItUpView()
}
