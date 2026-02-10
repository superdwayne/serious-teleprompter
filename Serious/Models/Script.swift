import Foundation

struct ScriptWord: Identifiable, Codable, Sendable {
    let id: Int
    let text: String
    let normalized: String
}

struct ScriptLine: Sendable {
    let startIndex: Int
    let words: [ScriptWord]
}

struct Script: Identifiable, Codable, Sendable {
    let id: UUID
    var title: String
    var rawText: String
    var words: [ScriptWord]
    var createdAt: Date
    var updatedAt: Date

    var wordCount: Int { words.count }

    var lines: [ScriptLine] {
        let lineTexts = rawText.components(separatedBy: .newlines)
        var result: [ScriptLine] = []
        var wordIndex = 0

        for lineText in lineTexts where !lineText.trimmingCharacters(in: .whitespaces).isEmpty {
            let lineWordTexts = lineText.split(separator: " ").map(String.init)
            let lineWords = lineWordTexts.compactMap { text -> ScriptWord? in
                guard wordIndex < words.count else { return nil }
                let word = words[wordIndex]
                wordIndex += 1
                return word
            }
            if !lineWords.isEmpty {
                result.append(ScriptLine(startIndex: lineWords[0].id, words: lineWords))
            }
        }
        return result
    }

    init(id: UUID = UUID(), title: String, rawText: String) {
        self.id = id
        self.title = title
        self.rawText = rawText
        self.createdAt = Date()
        self.updatedAt = Date()
        self.words = Self.tokenize(rawText)
    }

    static func tokenize(_ text: String) -> [ScriptWord] {
        text.split(separator: /\s+/)
            .enumerated()
            .map { index, word in
                let text = String(word)
                return ScriptWord(
                    id: index,
                    text: text,
                    normalized: text.normalizedForMatching
                )
            }
    }
}
