import Foundation

import SwiftUI

struct OpenTriviaResponse: Decodable {
    let results: [OpenTriviaItem]
}

struct OpenTriviaItem: Decodable {
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

struct TriviaQuestion: Identifiable, Equatable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let allAnswers: [String]
}

extension String {
    var htmlDecoded: String {
        // Fast path: no entities present
        if !self.contains("&") { return self }

        var result = self

        // Common named entities used by Open Trivia DB and typical HTML
        let entities: [String: String] = [
            "&amp;": "&",
            "&quot;": "\"",
            "&apos;": "'",
            "&#039;": "'",
            "&lt;": "<",
            "&gt;": ">",
            "&nbsp;": " ",
            "&ldquo;": "“",
            "&rdquo;": "”",
            "&lsquo;": "‘",
            "&rsquo;": "’"
        ]

        for (key, value) in entities {
            result = result.replacingOccurrences(of: key, with: value)
        }

        // Helper to decode numeric entities (decimal and hex)
        func decodeNumericEntities(_ s: String, pattern: String, radix: Int) -> String {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return s }
            var output = s
            // Iteratively replace the first match until none left
            while let match = regex.firstMatch(in: output, options: [], range: NSRange(output.startIndex..., in: output)) {
                guard let codeRange = Range(match.range(at: 1), in: output) else { break }
                let codeString = String(output[codeRange])
                guard let codePoint = Int(codeString, radix: radix), let scalar = UnicodeScalar(codePoint) else { break }
                guard let fullRange = Range(match.range(at: 0), in: output) else { break }
                output.replaceSubrange(fullRange, with: String(scalar))
            }
            return output
        }

   
        result = decodeNumericEntities(result, pattern: #"&#(\d+);"#, radix: 10)
        result = decodeNumericEntities(result, pattern: #"&#x([0-9A-Fa-f]+);"#, radix: 16)

        return result
    }
}
