import Foundation

enum TriviaServiceError: Error, LocalizedError {
    case badURL
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        
        switch self {
        case .badURL: return "Invalid URL."
        case .requestFailed: return "Network request failed."
        case .decodingFailed: return "Failed to decode server response."
        }
        
    }
}


struct TriviaService {
    func fetchQuestions(amount: Int = 10) async throws -> [TriviaQuestion] {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)&type=multiple") else {
            throw TriviaServiceError.badURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw TriviaServiceError.requestFailed
        }

        struct FullResponse: Decodable {
            let response_code: Int
            let results: [OpenTriviaItem]
        }

        let decoded = try JSONDecoder().decode(FullResponse.self, from: data)
        guard decoded.response_code == 0 else {
            throw TriviaServiceError.requestFailed
        }

        let mapped: [TriviaQuestion] = decoded.results.map { item in
            let answers = ([item.correct_answer] + item.incorrect_answers).shuffled()
            return TriviaQuestion(
                question: item.question.htmlDecoded,
                correctAnswer: item.correct_answer.htmlDecoded,
                allAnswers: answers.map { $0.htmlDecoded }
            )
        }
        return mapped
    }
}
