import Foundation
import Combine
import SwiftUI

@MainActor
final class QuizRushVM: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        case finished
    }

    enum AnswerResult {
        case correct
        case wrong
    }

    // MARK: - Published state
    @Published private(set) var state: State = .idle
    @Published private(set) var questions: [TriviaQuestion] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var score: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var selectedAnswer: String? = nil
    @Published private(set) var answerResult: AnswerResult? = nil

    // MARK: - Dependencies
    private let service: TriviaService
    private let questionCount: Int

    init(service: TriviaService = TriviaService(), questionCount: Int = 10) {
        self.service = service
        self.questionCount = questionCount
    }

    // MARK: - Public API
    func startNewRound() async {
        state = .loading
        score = 0
        streak = 0
        currentIndex = 0
        selectedAnswer = nil
        answerResult = nil

        do {
            let fetched = try await service.fetchQuestions(amount: questionCount)
            questions = Array(fetched.prefix(questionCount))
            if questions.isEmpty {
                state = .error("No questions returned. Please try again.")
            } else {
                state = .loaded
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    var currentQuestion: TriviaQuestion? {
        get {
            guard questions.indices.contains(currentIndex) else { return nil }
            return questions[currentIndex]
        }
    }

    var progressText: String {
        "\(min(currentIndex + 1, questionCount)) of \(questionCount)"
    }

    func selectAnswer(_ answer: String) {
        guard state == .loaded, let question = currentQuestion, selectedAnswer == nil else { return }
        selectedAnswer = answer
        if answer == question.correctAnswer {
            streak += 1
            let base = 100
            let bonus = max(0, (streak - 1) * 10) // bonus for consecutive correct
            score += base + bonus
            answerResult = .correct
        } else {
            // small penalty, advance anyway
            streak = 0
            score = max(0, score - 25)
            answerResult = .wrong
        }

        // Advance after a short delay to show feedback
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)
            goToNextQuestion()
        }
    }

    func retry() async {
        await startNewRound()
    }

    private func goToNextQuestion() {
        selectedAnswer = nil
        answerResult = nil
        currentIndex += 1
        if currentIndex >= questionCount {
            state = .finished
            
            // Update high score
            ScoreManager.shared.updateQuizRushHighScore(with: score)
            
            // Appends the finished game stats directly into our permanent history storage
            GameSessionManager.shared.recordSession(mode: .quizRush, score: score)
            
        } else {
            state = .loaded
        }
    }
}

