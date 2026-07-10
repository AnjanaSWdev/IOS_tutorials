import Foundation
import Combine

final class ScoreManager: ObservableObject {
    
    static let shared = ScoreManager()

    // UserDefaults keys
    private static let tapFrenzyKey = "tapFrenzyHighScore"
    private static let lightItUpKey = "lightItUpHighScore"
    private static let quizRushKey = "quizRushHighScore"

    @Published private(set) var tapFrenzyHighScore: Int
    @Published private(set) var lightItUpHighScore: Int
    @Published private(set) var quizRushHighScore: Int

    private init() {
        let defaults = UserDefaults.standard
        self.tapFrenzyHighScore = defaults.integer(forKey: Self.tapFrenzyKey)
        self.lightItUpHighScore = defaults.integer(forKey: Self.lightItUpKey)
        self.quizRushHighScore = defaults.integer(forKey: Self.quizRushKey)
    }

    func updateTapFrenzyHighScore(with score: Int) {
        guard score > tapFrenzyHighScore else { return }
        tapFrenzyHighScore = score
        UserDefaults.standard.set(score, forKey: Self.tapFrenzyKey)
    }

    func updateLightItUpHighScore(with score: Int) {
        guard score > lightItUpHighScore else { return }
        lightItUpHighScore = score
        UserDefaults.standard.set(score, forKey: Self.lightItUpKey)
    }

    func updateQuizRushHighScore(with score: Int) {
        guard score > quizRushHighScore else { return }
        quizRushHighScore = score
        UserDefaults.standard.set(score, forKey: Self.quizRushKey)
    }
    
    func resetAllScores() {
        
        // Reset the live publishing variables so the UI updates instantly
        self.tapFrenzyHighScore = 0
        self.quizRushHighScore = 0
        self.lightItUpHighScore = 0
        
        // Clear the persistent keys from memory
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "tap_frenzy_high_score")
        defaults.removeObject(forKey: "quiz_rush_high_score")
        defaults.removeObject(forKey: "light_it_up_high_score")
        
    }
    
}
