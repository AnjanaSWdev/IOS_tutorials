import SwiftUI

struct HomeView: View {
    @StateObject private var scoreManager = ScoreManager.shared

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

                VStack(spacing: 28) {
                    // Header
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

                    // Game cards
                    VStack(spacing: 16) {
                        NavigationLink(destination: TapFrenzy()) {
                            gameCard(title: "TapFrenzy", icon: "hand.tap", gradient: [Color.blue, Color.cyan])
                        }

                        NavigationLink(destination: LightItUp()) {
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

                    Spacer()
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
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
    HomeView()
}
