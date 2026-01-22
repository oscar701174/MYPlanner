import Foundation

// MARK: - Text Comparator

/// 텍스트 비교 구현체 (Word-level diff)
final class TextComparator: TextComparing {

    // MARK: - Public Methods

    func compare(source: String, target: String) -> TextComparisonResult {
        let sourceWords: [String] = normalizeAndTokenize(source)
        let targetWords: [String] = normalizeAndTokenize(target)

        // 빈 문자열 처리
        if sourceWords.isEmpty && targetWords.isEmpty {
            return TextComparisonResult(differences: [], matchPercentage: 1.0)
        }

        if sourceWords.isEmpty {
            let differences: [TextDifference] = targetWords.map { word in
                TextDifference(type: .insertion, sourceText: "", targetText: word)
            }
            return TextComparisonResult(differences: differences, matchPercentage: 0.0)
        }

        if targetWords.isEmpty {
            let differences: [TextDifference] = sourceWords.map { word in
                TextDifference(type: .deletion, sourceText: word, targetText: "")
            }
            return TextComparisonResult(differences: differences, matchPercentage: 0.0)
        }

        // LCS 기반 diff 계산
        let differences: [TextDifference] = computeDiff(source: sourceWords, target: targetWords)
        let matchCount: Int = differences.filter { $0.type == .match }.count
        let totalCount: Int = max(sourceWords.count, targetWords.count)
        let matchPercentage: Float = Float(matchCount) / Float(totalCount)

        return TextComparisonResult(differences: differences, matchPercentage: matchPercentage)
    }

    // MARK: - Private Methods

    /// 텍스트 정규화 및 토큰화
    private func normalizeAndTokenize(_ text: String) -> [String] {
        // 소문자 변환
        var normalized: String = text.lowercased()

        // 구두점 제거
        normalized = normalized.components(separatedBy: CharacterSet.punctuationCharacters).joined()

        // 공백으로 분리 및 빈 문자열 제거
        let words: [String] = normalized
            .split(separator: " ")
            .map { String($0).trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return words
    }

    /// LCS 기반 Diff 알고리즘
    private func computeDiff(source: [String], target: [String]) -> [TextDifference] {
        let m: Int = source.count
        let n: Int = target.count

        // LCS 테이블 생성
        var dp: [[Int]] = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 1...m {
            for j in 1...n {
                if source[i - 1] == target[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        // Backtrack하여 diff 생성
        var differences: [TextDifference] = []
        var i: Int = m
        var j: Int = n

        while i > 0 || j > 0 {
            if i > 0 && j > 0 && source[i - 1] == target[j - 1] {
                // Match
                differences.append(TextDifference(
                    type: .match,
                    sourceText: source[i - 1],
                    targetText: target[j - 1]
                ))
                i -= 1
                j -= 1
            } else if i > 0 && j > 0 && dp[i - 1][j - 1] >= dp[i - 1][j] && dp[i - 1][j - 1] >= dp[i][j - 1] {
                // Substitution - 대각선이 최선일 때 (다른 단어로 대체)
                differences.append(TextDifference(
                    type: .substitution,
                    sourceText: source[i - 1],
                    targetText: target[j - 1]
                ))
                i -= 1
                j -= 1
            } else if j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j]) {
                // Insertion (target에만 있음)
                differences.append(TextDifference(
                    type: .insertion,
                    sourceText: "",
                    targetText: target[j - 1]
                ))
                j -= 1
            } else if i > 0 {
                // Deletion (source에만 있음)
                differences.append(TextDifference(
                    type: .deletion,
                    sourceText: source[i - 1],
                    targetText: ""
                ))
                i -= 1
            }
        }

        // 역순으로 정렬 (앞에서부터)
        return differences.reversed()
    }
}
