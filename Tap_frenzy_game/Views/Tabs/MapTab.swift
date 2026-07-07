//
//  MapTab.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI
import MapKit

struct MapTab: View {
    @State private var sessionManager = GameSessionManager.shared
    @State private var selectedSessionID: UUID?
    
    // --- FIXED: Tells the map to automatically focus and zoom on all available pins ---
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // --- UPDATED MAP WITH POSITION BINDING ---
            Map(position: $position, selection: $selectedSessionID) {
                ForEach(sessionManager.sessions) { session in
                    Marker(
                        "\(session.score) pts",
                        systemImage: iconForMode(session.mode),
                        coordinate: CLLocationCoordinate2D(
                            latitude: session.latitude,
                            longitude: session.longitude
                        )
                    )
                    .tint(colorForMode(session.mode))
                    .tag(session.id)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .top)
            
            // --- DETAILED PIN OVERLAY PANEL ---
            if let selectedID = selectedSessionID,
               let session = sessionManager.sessions.first(where: { $0.id == selectedID }) {
                
                VStack(spacing: 12) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(colorForMode(session.mode).opacity(0.2))
                                .frame(width: 48, height: 48)
                            Image(systemName: iconForMode(session.mode))
                                .font(.title3).bold()
                                .foregroundColor(colorForMode(session.mode))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.mode == .tapFrenzy ? "TapFrenzy" : (session.mode == .quizRush ? "QuizRush" : "LightItUp"))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(session.score)")
                                .font(.system(.title2, design: .rounded)).bold()
                                .foregroundColor(.white)
                            Text("Score")
                                .font(.caption2).bold()
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .background(Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea())
        // Recalculate camera layout when the user enters the tab
        .onAppear {
            selectedSessionID = nil
            updateCameraFocus()
        }
    }
    
    // MARK: - Helper Logic
    private func updateCameraFocus() {
        if !sessionManager.sessions.isEmpty {
            withAnimation(.easeInOut(duration: 0.5)) {
                position = .automatic
            }
        }
    }
    
    private func iconForMode(_ mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush:  return "bolt.fill"
        }
    }
    
    private func colorForMode(_ mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .cyan
        case .lightItUp: return .orange
        case .quizRush:  return .purple
        }
    }
}

#Preview {
    MapTab()
}
