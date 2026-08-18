import SwiftUI
import UIKit
import AudioToolbox

enum GameType: String, CaseIterable, Identifiable {
    case find, same, colorShape, maze, match, count, math, memory
    case odd, pattern, compare, order

    var id: String { rawValue }

    var title: String {
        switch self {
        case .find: return "找一找"
        case .same: return "找一樣"
        case .colorShape: return "顏色圖形"
        case .maze: return "迷宮"
        case .match: return "連連看"
        case .count: return "數一數"
        case .math: return "數學練習"
        case .memory: return "記憶挑戰"
        case .odd: return "找不同"
        case .pattern: return "規律接龍"
        case .compare: return "比一比"
        case .order: return "排順序"
        }
    }

    var subtitle: String {
        switch self {
        case .find: return "專注搜尋"
        case .same: return "觀察細節"
        case .colorShape: return "辨識形狀"
        case .maze: return "手眼協調"
        case .match: return "拖曳配對"
        case .count: return "數量概念"
        case .math: return "基本加減法"
        case .memory: return "短期記憶"
        case .odd: return "觀察差異"
        case .pattern: return "邏輯規律"
        case .compare: return "大小比較"
        case .order: return "數字順序"
        }
    }

    var symbol: String {
        switch self {
        case .find: return "magnifyingglass"
        case .same: return "circle.grid.cross"
        case .colorShape: return "square.on.circle"
        case .maze: return "point.topleft.down.to.point.bottomright.curvepath"
        case .match: return "link"
        case .count: return "number"
        case .math: return "plus.forwardslash.minus"
        case .memory: return "brain.head.profile"
        case .odd: return "circle.grid.3x3.fill"
        case .pattern: return "ellipsis"
        case .compare: return "greaterthan"
        case .order: return "list.number"
        }
    }

    var tint: Color {
        switch self {
        case .find: return Color(red: 0.90, green: 0.97, blue: 0.82)
        case .same: return Color(red: 1.00, green: 0.89, blue: 0.80)
        case .colorShape: return Color(red: 0.93, green: 0.85, blue: 1.00)
        case .maze: return Color(red: 0.85, green: 0.91, blue: 1.00)
        case .match: return Color(red: 1.00, green: 0.84, blue: 0.89)
        case .count: return Color(red: 0.82, green: 0.96, blue: 0.94)
        case .math: return Color(red: 0.83, green: 0.90, blue: 1.00)
        case .memory: return Color(red: 1.00, green: 0.89, blue: 0.79)
        case .odd: return Color(red: 1.00, green: 0.88, blue: 0.93)
        case .pattern: return Color(red: 0.87, green: 0.94, blue: 1.00)
        case .compare: return Color(red: 1.00, green: 0.93, blue: 0.72)
        case .order: return Color(red: 0.89, green: 0.96, blue: 0.84)
        }
    }
}

final class ProgressStore: ObservableObject {
    @Published var stars: Int { didSet { defaults.set(stars, forKey: "stars") } }
    @Published var gamesPlayed: Int { didSet { defaults.set(gamesPlayed, forKey: "gamesPlayed") } }
    @Published var difficulty: Int { didSet { defaults.set(difficulty, forKey: "difficulty") } }
    @Published var dailyProgress: Int { didSet { defaults.set(dailyProgress, forKey: "dailyProgress") } }
    @Published var chestClaims: Int { didSet { defaults.set(chestClaims, forKey: "chestClaims") } }

    @Published var englishUnlockedLevel: Int { didSet { defaults.set(englishUnlockedLevel, forKey: "englishUnlockedLevel") } }
    @Published var englishTodayWords: Int { didSet { defaults.set(englishTodayWords, forKey: "englishTodayWords") } }
    @Published var englishCorrect: Int { didSet { defaults.set(englishCorrect, forKey: "englishCorrect") } }
    @Published var englishAttempts: Int { didSet { defaults.set(englishAttempts, forKey: "englishAttempts") } }
    @Published var englishCompletedThemes: Set<String> {
        didSet { defaults.set(Array(englishCompletedThemes), forKey: "englishCompletedThemes") }
    }

    private let defaults = UserDefaults.standard
    private let openedAt = Date()
    private let dailyKey: String

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dailyKey = formatter.string(from: Date())

        stars = defaults.integer(forKey: "stars")
        gamesPlayed = defaults.integer(forKey: "gamesPlayed")
        let savedDifficulty = defaults.integer(forKey: "difficulty")
        difficulty = savedDifficulty == 0 ? 1 : min(max(savedDifficulty, 1), 3)
        chestClaims = defaults.integer(forKey: "chestClaims")

        if defaults.string(forKey: "dailyDate") == dailyKey {
            dailyProgress = min(5, defaults.integer(forKey: "dailyProgress"))
        } else {
            dailyProgress = 0
            defaults.set(dailyKey, forKey: "dailyDate")
            defaults.set(0, forKey: "dailyProgress")
        }

        englishUnlockedLevel = max(1, defaults.integer(forKey: "englishUnlockedLevel"))
        englishCorrect = defaults.integer(forKey: "englishCorrect")
        englishAttempts = defaults.integer(forKey: "englishAttempts")
        englishCompletedThemes = Set(defaults.stringArray(forKey: "englishCompletedThemes") ?? [])

        if defaults.string(forKey: "englishDailyDate") == dailyKey {
            englishTodayWords = defaults.integer(forKey: "englishTodayWords")
        } else {
            englishTodayWords = 0
            defaults.set(dailyKey, forKey: "englishDailyDate")
            defaults.set(0, forKey: "englishTodayWords")
        }
    }

    var englishAccuracy: Int {
        guard englishAttempts > 0 else { return 0 }
        return Int(Double(englishCorrect) / Double(englishAttempts) * 100)
    }

    var sessionMinutes: Int {
        max(1, Int(Date().timeIntervalSince(openedAt) / 60))
    }

    var canOpenStarChest: Bool {
        stars / 30 > chestClaims
    }

    var starChestProgress: Int {
        canOpenStarChest ? 30 : stars % 30
    }

    func openStarChest() {
        guard canOpenStarChest else { return }
        chestClaims += 1
        Feedback.success()
    }

    private func recordDailyActivity() {
        if dailyProgress < 5 {
            dailyProgress += 1
            defaults.set(dailyKey, forKey: "dailyDate")
        }
    }

    func reward() {
        stars += 1
        gamesPlayed += 1
        recordDailyActivity()
        Feedback.success()
    }

    func learnedEnglishWord(category: String) {
        stars += 1
        englishTodayWords += 1
        englishCompletedThemes.insert(category)
        recordDailyActivity()
        defaults.set(dailyKey, forKey: "englishDailyDate")
        Feedback.success()
    }

    func answerEnglish(correct: Bool) {
        englishAttempts += 1
        if correct {
            englishCorrect += 1
            stars += 1
            recordDailyActivity()
            Feedback.success()
        } else {
            Feedback.error()
        }
    }

    func finishEnglishLevel(_ level: Int) {
        if level >= englishUnlockedLevel && englishUnlockedLevel < 20 {
            englishUnlockedLevel = min(20, level + 1)
        }
    }
}

enum Feedback {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1104)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        AudioServicesPlaySystemSound(1053)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
