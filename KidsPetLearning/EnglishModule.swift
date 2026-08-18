import SwiftUI
import UIKit

enum EnglishScreen: Equatable {
    case home
    case categories
    case learning(String)
    case levels
    case quiz(Int)
    case pronunciation
    case daily
    case petGrowth
    case parent
    case achievements
}

struct EnglishModuleView: View {
    let onExit: () -> Void
    @StateObject private var speech = EnglishSpeechManager()
    @State private var screen: EnglishScreen = .home

    var body: some View {
        ZStack {
            Color(red: 1.00, green: 0.97, blue: 0.91).ignoresSafeArea()
            content
        }
        .environmentObject(speech)
        .onDisappear { speech.stopListening() }
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .home:
            EnglishHomeView(
                onExit: onExit,
                go: { screen = $0 }
            )
        case .categories:
            EnglishCategoryView(onBack: { screen = .home }, go: { screen = $0 })
        case .learning(let category):
            EnglishLearningView(category: category, onBack: { screen = .categories })
        case .levels:
            EnglishLevelMapView(onBack: { screen = .home }, go: { screen = $0 })
        case .quiz(let level):
            EnglishQuizView(level: level, onBack: { screen = .levels })
        case .pronunciation:
            EnglishPronunciationView(onBack: { screen = .home })
        case .daily:
            EnglishDailyTaskView(onBack: { screen = .home }, goLearn: { screen = .categories })
        case .petGrowth:
            EnglishPetGrowthView(onBack: { screen = .home })
        case .parent:
            EnglishParentView(onBack: { screen = .home })
        case .achievements:
            EnglishAchievementsView(onBack: { screen = .home })
        }
    }
}

struct EnglishHeader: View {
    let title: String
    let subtitle: String?
    let onBack: () -> Void
    @EnvironmentObject private var progress: ProgressStore

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 43)
                    .background(Color(red: 0.30, green: 0.55, blue: 0.90))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .buttonStyle(.plain)

            VStack(spacing: 1) {
                Text(title)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.brown.opacity(0.62))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
            .frame(maxWidth: .infinity)

            Text("⭐ \\(progress.stars)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.brown)
                .frame(width: 76, height: 42)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(height: 50)
    }
}

struct EnglishHomeView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var speech: EnglishSpeechManager
    let onExit: () -> Void
    let go: (EnglishScreen) -> Void

    private let columns = [GridItem(.flexible(), spacing: 9), GridItem(.flexible(), spacing: 9)]

    var body: some View {
        GeometryReader { geo in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad

            VStack(spacing: isPad ? 12 : 9) {
                EnglishHeader(title: "ABC 英文小教室", subtitle: "偶貴・黑糖・熊熊陪你學", onBack: onExit)

                Image("MainVisual")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: isPad ? 220 : 170)
                    .frame(height: isPad ? 220 : 170)

                Text("📚 已學會主題 \(progress.englishCompletedThemes.count) / \(EnglishWordBank.categories.count)")
                    .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .frame(maxWidth: .infinity, minHeight: isPad ? 62 : 50)
                    .background(Color(red: 0.91, green: 0.97, blue: 0.84))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                LazyVGrid(columns: columns, spacing: isPad ? 12 : 9) {
                    EnglishMenuTile(
                        icon: "book.closed.fill",
                        title: "單字學習",
                        subtitle: "分類學習 224 個單字",
                        tint: Color(red: 0.82, green: 0.93, blue: 1.00)
                    ) { open("單字學習", .categories) }

                    EnglishMenuTile(
                        icon: "headphones",
                        title: "聽力挑戰",
                        subtitle: "聽單字，選出正確圖片",
                        tint: Color(red: 1.00, green: 0.89, blue: 0.80)
                    ) { open("聽力挑戰", .levels) }

                    EnglishMenuTile(
                        icon: "checkmark.square.fill",
                        title: "英文測驗",
                        subtitle: "看題目選正確英文",
                        tint: Color(red: 0.86, green: 0.94, blue: 1.00)
                    ) { open("英文測驗", .quiz(1)) }

                    EnglishMenuTile(
                        icon: "mic.fill",
                        title: "發音練習",
                        subtitle: "示範後 0.5 秒再開麥克風",
                        tint: Color(red: 1.00, green: 0.88, blue: 0.84)
                    ) { open("發音練習", .pronunciation) }
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, isPad ? 18 : 12)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
    }

    private func open(_ label: String, _ destination: EnglishScreen) {
        Feedback.tap()
        speech.speak(label, language: "zh-TW")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            go(destination)
        }
    }
}

struct EnglishStatus: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 13, weight: .bold, design: .rounded))
                Text(value).font(.system(size: 20, weight: .heavy, design: .rounded))
            }
            Spacer(minLength: 0)
        }
        .foregroundColor(.brown)
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(tint)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct EnglishMenuTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 45, height: 45)
                    .background(Color.white.opacity(0.78))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                Spacer(minLength: 0)
            }
            .foregroundColor(.brown)
            .padding(.horizontal, 9)
            .frame(maxWidth: .infinity, minHeight: 78)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
