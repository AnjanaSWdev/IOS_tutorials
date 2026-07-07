//
//  StatsTab.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI
import Charts

struct StatsTab: View {
    @State private var viewModel = StatsVM()
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // --- TOTALS DASHBOARD CARD ---
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TOTAL GAMES")
                                .font(.caption2).bold().foregroundColor(.gray)
                            Text("\(viewModel.totalGamesPlayed)")
                                .font(.title).bold().foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(red: 0.12, green: 0.14, blue: 0.18)).cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TOTAL POINTS")
                                .font(.caption2).bold().foregroundColor(.gray)
                            Text("\(viewModel.totalScoreAccumulated)")
                                .font(.title).bold().foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(red: 0.12, green: 0.14, blue: 0.18)).cornerRadius(12)
                    }
                    
                    // --- PERSONAL BESTS SECTION ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PERSONAL BESTS")
                            .font(.caption).bold().foregroundColor(.gray)
                            .tracking(1)
                        
                        ForEach(GameMode.allCases) { mode in
                            HStack {
                                Text(mode.rawValue)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(viewModel.personalBest(for: mode)) pts")
                                    .bold()
                                    .foregroundColor(color(for: mode))
                            }
                            .padding()
                            .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                            .cornerRadius(12)
                        }
                    }
                    
                    // --- CHARTS PERFORMANCE GRAPH ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PERFORMANCE HISTORY")
                            .font(.caption).bold().foregroundColor(.gray)
                            .tracking(1)
                        
                        Picker("Mode Selection", selection: $viewModel.selectedChartMode) {
                            ForEach(GameMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        
                        if viewModel.chartDataPoints.isEmpty {
                            Text("No game data found for this mode yet.")
                                .font(.subheadline).foregroundColor(.gray)
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .multilineTextAlignment(.center)
                        } else {
                            // Clean, type-check friendly Chart block
                            Chart {
                                ForEach(viewModel.chartDataPoints) { point in
                                    BarMark(
                                        x: .value("Game Run", point.label),
                                        y: .value("Score", point.score)
                                    )
                                    .foregroundStyle(color(for: point.mode).gradient)
                                    .annotation(position: .top) {
                                        Text("\(point.score)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            .frame(height: 180)
                            .chartXAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisGridLine()
                                        .foregroundStyle(Color.white.opacity(0.1))
                                    AxisTick()
                                        .foregroundStyle(Color.white.opacity(0.3))
                                    AxisValueLabel()
                                        .foregroundStyle(.gray)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(values: .automatic) { value in
                                    AxisGridLine()
                                        .foregroundStyle(Color.white.opacity(0.05))
                                    AxisTick()
                                        .foregroundStyle(Color.white.opacity(0.3))
                                    AxisValueLabel()
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(red: 0.12, green: 0.14, blue: 0.18))
                    .cornerRadius(16)
                    
                    // --- RECENT COMPLETED RUNS LIST ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("RECENT GAMES")
                            .font(.caption).bold().foregroundColor(.gray)
                            .tracking(1)
                        
                        if viewModel.recentSessions.isEmpty {
                            Text("Play a game session to view history insights.")
                                .font(.subheadline).foregroundColor(.gray)
                                .padding()
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.recentSessions.prefix(5)) { session in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.mode.rawValue)
                                                .font(.headline).foregroundColor(.white)
                                            Text(session.timestamp.formatted(.dateTime.month().day().hour().minute()))
                                                .font(.caption2).foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text("+\(session.score)")
                                            .font(.title3).bold()
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(red: 0.16, green: 0.19, blue: 0.23))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    // Extracted helper to avoid mixing complex logic inside the layout body tree
    private func color(for mode: GameMode) -> Color {
        switch mode {
        case .lightItUp: return .green
        case .tapFrenzy: return .blue
        case .quizRush: return .purple
        }
    }
}

#Preview {
    StatsTab()
}
