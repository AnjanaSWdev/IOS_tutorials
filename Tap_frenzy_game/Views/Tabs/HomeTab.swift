import SwiftUI


import SwiftUI

struct HomeTab: View {
    @StateObject private var scoreManager = ScoreManager.shared
    
    // Simple Persistent App Storage Keys
    @AppStorage("daily_challenge_mode") private var dailyChallengeMode = "TapFrenzy"
    @AppStorage("challenge_completed_today") private var isChallengeCompleted = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient background with soft blobs
                LinearGradient(colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.10, green: 0.14, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                Circle()
                    .fill(Color.blue.opacity(0.25))
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(x: -140, y: -220)

                Circle()
                    .fill(Color.purple.opacity(0.25))
                    .frame(width: 260, height: 260)
                    .blur(radius: 90)
                    .offset(x: 140, y: 240)

                VStack(spacing: 24) {
                    // Header (Preserved Exactly)
                    VStack(spacing: 8) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .blue.opacity(0.5), radius: 12, x: 0, y: 6)

                        Text("Game Hub")
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(LinearGradient(colors: [.white, .yellow], startPoint: .top, endPoint: .bottom))
                            .shadow(color: .yellow.opacity(0.35), radius: 12, x: 0, y: 10)
                    }
                    .padding(.top, 24)

                    // Game Menus Container
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            
                            // Dynamic daily challenge card
                            if isChallengeCompleted {
                                // Static representation displaying success status
                                dailyChallengeCardView()
                            } else {
                                // Direct routing link based on today's scheduled mode
                                NavigationLink(destination: dailyChallengeDestination) {
                                    dailyChallengeCardView()
                                }
                            }
                            
                            //Regualar game modes
                            NavigationLink(destination: TapFrenzyView()) {
                                gameCard(title: "TapFrenzy", icon: "hand.tap", gradient: [Color.blue, Color.cyan])
                            }

                            NavigationLink(destination: LightItUpView()) {
                                gameCard(title: "LightItUp", icon: "lightbulb.fill", gradient: [Color.orange, Color.pink])
                            }

                            NavigationLink(destination: QuizRushView()) {
                                gameCard(title: "QuizRush", icon: "bolt.fill", gradient: [Color.purple, Color.indigo])
                            }

                            NavigationLink(destination: HighScoresView()) {
                                gameCard(title: "High Scores", icon: "trophy.fill", gradient: [Color.green, Color.mint])
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    
    // Private UI Components
    private func dailyChallengeCardView() -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: isChallengeCompleted ? "checkmark.circle.fill" : "star.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(isChallengeCompleted ? .green : .yellow)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Daily Challenge")
                    .font(.caption).bold()
                    .foregroundColor(isChallengeCompleted ? .green : .yellow)
                
                Text(isChallengeCompleted ? "Challenge Completed!" : "Mode: \(dailyChallengeMode)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if !isChallengeCompleted {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(
            isChallengeCompleted
            ? LinearGradient(colors: [Color.black.opacity(0.4), Color.black.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
            : LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isChallengeCompleted ? Color.green.opacity(0.4) : Color.white.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: isChallengeCompleted ? Color.clear : Color.orange.opacity(0.35), radius: 14, x: 0, y: 10)
    }

    // Dynamic subview target pointer mapping strings to View instances
    @ViewBuilder
    private var dailyChallengeDestination: some View {
        switch dailyChallengeMode {
        case "LightItUp":
            LightItUpView()
        case "QuizRush":
            QuizRushView()
        default:
            TapFrenzyView()
        }
    }

    private func gameCard(title: String, icon: String, gradient: [Color]) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Start")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(16)
        .shadow(color: (gradient.last ?? .black).opacity(0.5), radius: 14, x: 0, y: 10)
    }

    private func scoreBadge(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text("\(value)")
                .font(.title2).bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.25))
        .cornerRadius(10)
    }
}


#Preview {
    HomeTab()
}
