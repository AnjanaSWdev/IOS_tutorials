import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushViewModel()

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.15).ignoresSafeArea()
            content
        }
        .navigationTitle("Quiz Rush")
        .onAppear {
            if case .idle = viewModel.state {
                Task { await viewModel.startNewRound() }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .error(let message):
            errorView(message: message)
        case .loaded:
            if let question = viewModel.currentQuestion {
                quizView(question: question)
            } else {
                loadingView
            }
        case .finished:
            finishedView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(.white)
            Text("Loading questions...")
                .foregroundColor(.white)
        }
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow).font(.largeTitle)
            Text("Couldn't load questions")
                .font(.headline)
                .foregroundColor(.white)
            Text(message)
                .foregroundColor(.white.opacity(0.8))
            Button("Retry") { Task { await viewModel.retry() } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func quizView(question: TriviaQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Score: \(viewModel.score)")
                Spacer()
                Text("Streak: \(viewModel.streak)")
            }
            .font(.subheadline)
            .foregroundColor(.white)

            Text(viewModel.progressText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            Text(question.question)
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.12, green: 0.14, blue: 0.18)))

            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    answerButton(answer: answer, correct: question.correctAnswer)
                }
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut, value: viewModel.answerResult)
    }

    private func answerButton(answer: String, correct: String) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let showResult = viewModel.answerResult != nil
        let isCorrect = answer == correct

        return Button {
            viewModel.selectAnswer(answer)
        } label: {
            HStack {
                Text(answer)
                    .foregroundColor(.white)
                Spacer()
                if showResult && isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonBackground(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor(isSelected: isSelected, isCorrect: isCorrect, showResult: showResult), lineWidth: 2)
            )
        }
        .disabled(viewModel.selectedAnswer != nil)
        .scaleEffect(isSelected && showResult ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: showResult)
    }

    private func buttonBackground(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult && isSelected {
            return isCorrect ? Color.green.opacity(0.25) : Color.red.opacity(0.25)
        }
        return Color(red: 0.12, green: 0.14, blue: 0.18)
    }

    private func borderColor(isSelected: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if showResult && isSelected {
            return isCorrect ? .green : .red
        }
        return .white.opacity(isSelected ? 0.6 : 0.2)
    }

    private var finishedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 48))
                .foregroundColor(.white)
            Text("Round Complete!")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Final Score: \(viewModel.score)")
                .font(.headline)
                .foregroundColor(.white)
            Button("Play Again") { Task { await viewModel.startNewRound() } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    NavigationStack { QuizRushView() }
}

