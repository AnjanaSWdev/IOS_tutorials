//  QuizRushView.swift
//  Quiz_rush_game
//
//  Created by student2 on 2026-07-07.
//

import SwiftUI

struct QuizRushView: View {
    @StateObject private var viewModel = QuizRushVM()

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
        VStack(spacing: 20) {
            
            // Header Layout: Score on Left, Question Progress on Right
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SCORE")
                        .font(.caption2.bold())
                        .foregroundColor(.gray)
                    Text("\(viewModel.score)")
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("QUESTION")
                        .font(.caption2.bold())
                        .foregroundColor(.gray)
                    Text(viewModel.progressText)
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 4)

            // Centered Streak Badge with animation
            if viewModel.streak > 0 {
                StreakBadge(streak: viewModel.streak)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))
            } else {
                Spacer()
                    .frame(height: 12)
            }

            // Question Card View
            Text(question.question)
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.12, green: 0.14, blue: 0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            // Multiple Choice Choices
            VStack(spacing: 12) {
                ForEach(question.allAnswers, id: \.self) { answer in
                    answerButton(answer: answer, correct: question.correctAnswer)
                }
            }

            Spacer()
        }
        .padding()
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.streak)
        .animation(.easeInOut, value: viewModel.answerResult)
    }

    private func answerButton(answer: String, correct: String) -> some View {
        let isSelected = viewModel.selectedAnswer == answer
        let showResult = viewModel.answerResult != nil
        let isCorrectAnswer = answer == correct
        let userSelectedWrongAnswer = viewModel.selectedAnswer != nil && viewModel.selectedAnswer != correct
        
        // Dynamic evaluation states:
        // 1. Show as Correct: If it is the correct answer and (user clicked it OR user clicked the wrong choice)
        let shouldShowAsCorrect = showResult && isCorrectAnswer && (isSelected || userSelectedWrongAnswer)
        // 2. Show as Wrong: If it is the user's selected option and it is indeed incorrect
        let shouldShowAsWrong = showResult && isSelected && !isCorrectAnswer

        return Button {
            viewModel.selectAnswer(answer)
        } label: {
            HStack {
                Text(answer)
                    .foregroundColor(.white)
                Spacer()
                if shouldShowAsCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if shouldShowAsWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonBackground(shouldShowAsCorrect: shouldShowAsCorrect, shouldShowAsWrong: shouldShowAsWrong))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor(shouldShowAsCorrect: shouldShowAsCorrect, shouldShowAsWrong: shouldShowAsWrong, isSelected: isSelected), lineWidth: 2)
            )
        }
        .disabled(viewModel.selectedAnswer != nil)
        .scaleEffect(isSelected && showResult ? 0.98 : 1)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: showResult)
    }

    private func buttonBackground(shouldShowAsCorrect: Bool, shouldShowAsWrong: Bool) -> Color {
        if shouldShowAsCorrect {
            return Color.green.opacity(0.25)
        }
        if shouldShowAsWrong {
            return Color.red.opacity(0.25)
        }
        return Color(red: 0.12, green: 0.14, blue: 0.18)
    }

    private func borderColor(shouldShowAsCorrect: Bool, shouldShowAsWrong: Bool, isSelected: Bool) -> Color {
        if shouldShowAsCorrect {
            return .green
        }
        if shouldShowAsWrong {
            return .red
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

// Sub-Component: Dynamic Animated Streak Badge
struct StreakBadge: View {
    let streak: Int
    @State private var pulseTrigger = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundColor(.orange)
                .symbolEffect(.bounce, value: pulseTrigger)
            
            Text("Streak: \(streak)")
                .font(.system(.subheadline, design: .rounded).bold())
                .foregroundColor(.orange)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.orange.opacity(0.12))
        )
        .overlay(
            Capsule()
                .stroke(Color.orange.opacity(0.35), lineWidth: 1.5)
        )
        .scaleEffect(pulseTrigger ? 1.15 : 1.0)
        .onChange(of: streak) { _, newStreak in
            guard newStreak > 0 else { return }
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                pulseTrigger = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    pulseTrigger = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack { QuizRushView() }
}


