import Foundation

@Observable
final class WordMatcher {
    var currentPosition: Int = 0
    private var scriptWords: [ScriptWord] = []
    private var sensitivity: Double = 0.7

    func configure(script: Script, sensitivity: Double) {
        self.scriptWords = script.words
        self.sensitivity = sensitivity
        self.currentPosition = 0
    }

    func processTranscription(_ result: TranscriptionResult) -> Int? {
        guard !scriptWords.isEmpty else { return nil }
        let spokenWords = result.words
            .map { $0.normalizedForMatching }
            .filter { !$0.isEmpty }
        guard !spokenWords.isEmpty else { return nil }

        let windowStart = max(0, currentPosition - Constants.searchWindowBack)
        let windowEnd = min(scriptWords.count - 1, currentPosition + Constants.searchWindowAhead)
        guard windowStart <= windowEnd else { return nil }

        var bestMatchIndex = currentPosition
        var bestScore: Double = 0.0

        let lastSpoken = spokenWords.last!

        for i in windowStart...windowEnd {
            let scriptWord = scriptWords[i].normalized
            let score = StringSimilarity.normalizedSimilarity(lastSpoken, scriptWord)

            if score > bestScore && score >= sensitivity {
                bestScore = score
                bestMatchIndex = i
            }
        }

        if spokenWords.count >= 2 {
            let phraseScore = matchPhrase(spokenWords: spokenWords, startingNear: currentPosition)
            if let phraseResult = phraseScore, phraseResult.score >= bestScore {
                bestMatchIndex = phraseResult.endIndex
                bestScore = phraseResult.score
            }
        }

        if bestScore >= sensitivity {
            // Allow forward movement, or backward within a small window
            if bestMatchIndex >= currentPosition || (currentPosition - bestMatchIndex) <= Constants.searchWindowBack {
                currentPosition = bestMatchIndex
                return bestMatchIndex
            }
        }

        return nil
    }

    private struct PhraseMatch {
        let endIndex: Int
        let score: Double
    }

    private func matchPhrase(spokenWords: [String], startingNear position: Int) -> PhraseMatch? {
        let windowStart = max(0, position - Constants.searchWindowBack)
        let windowEnd = min(scriptWords.count - 1, position + Constants.searchWindowAhead)
        guard windowStart <= windowEnd else { return nil }
        guard spokenWords.count >= 2 else { return nil }

        let lastFew = Array(spokenWords.suffix(min(4, spokenWords.count)))
        guard windowEnd - windowStart + 1 >= lastFew.count else { return nil }

        var bestMatch: PhraseMatch?

        for startIdx in windowStart...(windowEnd - lastFew.count + 1) {
            var totalScore: Double = 0
            var comparisons = 0
            for (offset, spoken) in lastFew.enumerated() {
                let scriptIdx = startIdx + offset
                guard scriptIdx < scriptWords.count else { break }
                totalScore += StringSimilarity.normalizedSimilarity(spoken, scriptWords[scriptIdx].normalized)
                comparisons += 1
            }
            guard comparisons > 0 else { continue }
            let avgScore = totalScore / Double(comparisons)
            let endIdx = min(startIdx + comparisons - 1, scriptWords.count - 1)

            if avgScore > (bestMatch?.score ?? 0) {
                bestMatch = PhraseMatch(endIndex: endIdx, score: avgScore)
            }
        }

        return bestMatch
    }

    func reset() {
        currentPosition = 0
    }
}
