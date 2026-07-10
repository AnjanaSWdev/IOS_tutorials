//
//  MapTab.swift
//  Tap_frenzy_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI
import MapKit

// Core Data Structure
struct LocationGroup: Identifiable {
    let id: String // "lat,lng" string identifier
    let coordinate: CLLocationCoordinate2D
    let sessions: [GameSession]
}

// Main Map Tab View
struct MapTab: View {
    @State private var sessionManager = GameSessionManager.shared
    @State private var selectedGroupID: String?
    @State private var selectedModeDetails: GameMode?
    @State private var position: MapCameraPosition = .automatic
    
    // Isolated location grouping property
    private var groupedLocations: [LocationGroup] {
        let grouped = Dictionary(grouping: sessionManager.sessions) { session in
            String(format: "%.4f,%.4f", session.latitude, session.longitude)
        }
        return grouped.map { key, sessions in
            let coord = CLLocationCoordinate2D(
                latitude: sessions.first?.latitude ?? 0,
                longitude: sessions.first?.longitude ?? 0
            )
            return LocationGroup(id: key, coordinate: coord, sessions: sessions)
        }
    }
    
    // Safely extracts the active group to prevent heavy inline lookups
    private var activeGroup: LocationGroup? {
        guard let selectedID = selectedGroupID else { return nil }
        return groupedLocations.first { $0.id == selectedID }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 1. Map Canvas View
            Map(position: $position, selection: $selectedGroupID) {
                ForEach(groupedLocations, id: \.id) { group in
                    Marker("\(group.sessions.count) Games", systemImage: "mappin.and.ellipse", coordinate: group.coordinate)
                        .tint(.red)
                        .tag(group.id)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .top)
            
            // 2. Sub-viewed Detail Card Panel
            if let group = activeGroup {
                LocationDetailPane(
                    group: group,
                    selectedGroupID: $selectedGroupID,
                    selectedModeDetails: $selectedModeDetails
                )
            }
        }
        .background(Color(red: 0.05, green: 0.07, blue: 0.12).ignoresSafeArea())
        .onAppear {
            selectedGroupID = nil
            selectedModeDetails = nil
            if !sessionManager.sessions.isEmpty { position = .automatic }
        }
        .onChange(of: selectedGroupID) { oldValue, newValue in
            selectedModeDetails = nil
        }
    }
}

// Sub-Component: Entire Overlay Pane
struct LocationDetailPane: View {
    let group: LocationGroup
    @Binding var selectedGroupID: String?
    @Binding var selectedModeDetails: GameMode?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Location Activity")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                    Text("\(group.sessions.count) total matches played here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                
                if selectedModeDetails != nil {
                    Button(action: { withAnimation(.easeInOut(duration: 0.25)) { selectedModeDetails = nil } }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                } else {
                    Button(action: { withAnimation { selectedGroupID = nil } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 12)
            
            Divider().background(Color.white.opacity(0.2))
            
            // Body Scroll Lists
            ScrollView {
                if let targetMode = selectedModeDetails {
                    let history = group.sessions
                        .filter { $0.mode == targetMode }
                        .sorted { $0.timestamp > $1.timestamp }
                    
                    VStack(spacing: 10) {
                        ForEach(history) { session in
                            SessionHistoryRow(session: session)
                        }
                    }
                    .padding()
                } else {
                    let uniqueModes = Array(Set(group.sessions.map { $0.mode })).sorted { $0.rawValue < $1.rawValue }
                    
                    VStack(spacing: 12) {
                        ForEach(uniqueModes, id: \.self) { mode in
                            let matchCount = group.sessions.filter { $0.mode == mode }.count
                            GameModeSummaryRow(mode: mode, count: matchCount, selectedModeDetails: $selectedModeDetails)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxHeight: 280)
        }
        .background(Color.black) // High-contrast solid pitch black color
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.6), radius: 16, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// Sub-Component: Summary Category Row
struct GameModeSummaryRow: View {
    let mode: GameMode
    let count: Int
    @Binding var selectedModeDetails: GameMode?
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selectedModeDetails = mode }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(MapDesign.color(for: mode).opacity(0.2))
                        .frame(width: 42, height: 42)
                    Image(systemName: MapDesign.icon(for: mode))
                        .font(.title3)
                        .foregroundColor(MapDesign.color(for: mode))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(MapDesign.title(for: mode))
                        .font(.body.bold())
                        .foregroundColor(.white)
                    Text("\(count) \(count == 1 ? "match" : "matches")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(red: 0.12, green: 0.14, blue: 0.18))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// Sub-Component: Individual Game Session History Card
struct SessionHistoryRow: View {
    let session: GameSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score: \(session.score)")
                    .font(.system(.body, design: .rounded)).bold()
                    .foregroundColor(.white)
                Text(session.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: MapDesign.icon(for: session.mode))
                .font(.title3)
                .foregroundColor(MapDesign.color(for: session.mode))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.12, green: 0.14, blue: 0.18))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Global UI Formatting Style Enums
enum MapDesign {
    static func title(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "Tap Frenzy"
        case .lightItUp: return "Light It Up"
        case .quizRush: return "Quiz Rush"
        }
    }
    static func icon(for mode: GameMode) -> String {
        switch mode {
        case .tapFrenzy: return "hand.tap.fill"
        case .lightItUp: return "lightbulb.fill"
        case .quizRush: return "bolt.fill"
        }
    }
    static func color(for mode: GameMode) -> Color {
        switch mode {
        case .tapFrenzy: return .cyan
        case .lightItUp: return .orange
        case .quizRush: return .purple
        }
    }
}



#Preview {
    MapTab()
}

