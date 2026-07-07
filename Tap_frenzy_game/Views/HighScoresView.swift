import SwiftUI

struct HighScoresView: View {
    
    @ObservedObject private var scoreManager = ScoreManager.shared

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.15).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("High Scores")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    scoreRow(title: "TapFrenzy", score: scoreManager.tapFrenzyHighScore, color: .blue, symbol: "hand.tap")
                    scoreRow(title: "LightItUp", score: scoreManager.lightItUpHighScore, color: .orange, symbol: "lightbulb")
                    scoreRow(title: "QuizRush", score: scoreManager.quizRushHighScore, color: .green, symbol: "bolt.fill")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.12, green: 0.14, blue: 0.18)))

                Spacer()
            }
            .padding()
        }
    }

    private func scoreRow(title: String, score: Int, color: Color, symbol: String) -> some View {
        HStack {
            Label(title, systemImage: symbol)
                .foregroundColor(.white)
            Spacer()
            Text("\(score)")
                .font(.title2).bold()
                .foregroundColor(color)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.15)))
    }
}

#Preview {
    HighScoresView()
}
