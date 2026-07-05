//
//  LightItUp.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-05.
//

import Foundation
import SwiftUI

// MARK: - Level Configuration Model
struct LevelConfig {
    let name: String
    let cardCount: Int
    let litWindow: Double
    let color: Color
    let columnsCount: Int
    let concurrentLit: Int
}

struct LightItUp: View {
    // MARK: - Game States
    @State private var score: Int = 0
    @State private var timeElapsed: Int = 0
    @State private var lives: Int = 3
    @State private var activeCardIndices: Set<Int> = []
    @State private var isGameActive: Bool = false
    @State private var showGameOverModal: Bool = false

    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    
    // MARK: - Timers
    @State private var gameTimer: Timer? = nil
    @State private var glowTimer: Timer? = nil
    
    // MARK: - Dynamic Level Resolution
    private var currentLevel: LevelConfig {
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
    
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: currentLevel.columnsCount)
    }
    
    var body: some View {
        ZStack {
            // Dark Background
            Color(red: 0.08, green: 0.11, blue: 0.15)
                .ignoresSafeArea()
            
            // MARK: - Main Game Layer
            // This entire vertical layout completely vanishes when the pop-up shows
            if !showGameOverModal {
                VStack(spacing: 20) {
                    // Top Header (Only visible while playing)
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.caption).foregroundColor(.gray)
                            Text("\(score)")
                                .font(.largeTitle).bold().foregroundColor(.white)
                            Text("BEST \(highScore)")
                                .font(.caption2).foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if isGameActive {
                            VStack(spacing: 4) {
                                Text("LEVEL")
                                    .font(.caption).foregroundColor(.gray)
                                Text(currentLevel.name)
                                    .font(.headline).bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(currentLevel.color.opacity(0.8))
                                    .cornerRadius(8)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("TIME")
                                .font(.caption).foregroundColor(.gray)
                            Text("\(60 - timeElapsed)s")
                                .font(.largeTitle).bold().foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Lives Display
                    if isGameActive {
                        HStack(spacing: 6) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(index < lives ? .red : .gray.opacity(0.3))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Game View Grid / Start Screen Switcher
                    if isGameActive {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<currentLevel.cardCount, id: \.self) { index in
                                    CardView(
                                        isGlowing: activeCardIndices.contains(index),
                                        glowColor: currentLevel.color
                                    ) {
                                        handleCardTap(at: index)
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
                            
                            Button(action: startGame) {
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
            
            // MARK: - Game Over Centered Pop-up Window
            if showGameOverModal {
                VStack(spacing: 24) {
                    Text(lives == 0 ? "GAME OVER" : "VICTORY!")
                        .font(.title).bold()
                        .foregroundColor(lives == 0 ? .red : .green)
                        .tracking(2)
                    
                    Text(lives == 0 ? "You ran out of lives." : "You survived the whole 60 seconds!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    // Center Focused Score Box
                    VStack(spacing: 4) {
                        Text("FINAL SCORE")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("\(score)")
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
                            showGameOverModal = false
                        }
                        startGame()
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showGameOverModal)
    }
    
    // MARK: - Game Operations
    func startGame() {
        score = 0
        timeElapsed = 0
        lives = 3
        showGameOverModal = false
        isGameActive = true
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeElapsed < 60 {
                timeElapsed += 1
            } else {
                endGame(dueToLives: false)
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
        
        glowTimer = Timer.scheduledTimer(withTimeInterval: config.litWindow, repeats: false) { _ in
            activeCardIndices.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if isGameActive { triggerNextGlow() }
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
        }
        withAnimation {
            showGameOverModal = true
        }
    }
}

// MARK: - Card Component
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
    LightItUp()
}

