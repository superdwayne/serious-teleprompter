import Foundation

enum StringSimilarity {
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count

        if m == 0 { return n }
        if n == 0 { return m }

        var previousRow = Array(0...n)
        var currentRow = Array(repeating: 0, count: n + 1)

        for i in 1...m {
            currentRow[0] = i
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                currentRow[j] = min(
                    currentRow[j - 1] + 1,
                    previousRow[j] + 1,
                    previousRow[j - 1] + cost
                )
            }
            previousRow = currentRow
        }

        return previousRow[n]
    }

    static func normalizedSimilarity(_ s1: String, _ s2: String) -> Double {
        let maxLen = max(s1.count, s2.count)
        guard maxLen > 0 else { return 1.0 }
        let distance = levenshteinDistance(s1, s2)
        return 1.0 - Double(distance) / Double(maxLen)
    }

    static func partialSimilarity(_ query: String, in text: String) -> Double {
        guard !query.isEmpty else { return 0.0 }
        guard query.count <= text.count else {
            return normalizedSimilarity(query, text)
        }

        var bestScore = 0.0
        let queryLen = query.count
        let textArray = Array(text)

        for start in 0...(textArray.count - queryLen) {
            let substring = String(textArray[start..<start + queryLen])
            let score = normalizedSimilarity(query, substring)
            bestScore = max(bestScore, score)
            if bestScore >= 0.99 { break }
        }

        return bestScore
    }
}
