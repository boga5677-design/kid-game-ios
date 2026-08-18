import SwiftUI
import UIKit

private enum AppScreen {
    case home
    case game(GameType)
    case english
    case daily
    case chest
}

struct RootView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var screen: AppScreen = .home
    @State private var showAchievements = false

    var body: some View {
        ZStack {
            Color(red: 1.00, green: 0.97, blue: 0.91)
                .ignoresSafeArea()

            switch screen {
            case .home:
                HomeView(
                    onGame: { game in
                        Feedback.tap()
                        screen = .game(game)
                    },
                    onDaily: { screen = .daily },
                    onChest: { screen = .chest },
                    onAchievements: { showAchievements = true },
                    onEnglish: { screen = .english }
                )
            case .game(let game):
                GameScreen(game: game) { screen = .home }
            case .english:
                EnglishModuleView { screen = .home }
            case .daily:
                DailyMissionView { screen = .home }
            case .chest:
                StarChestView { screen = .home }
            }
        }
        .sheet(isPresented: $showAchievements) {
            AchievementView()
                .environmentObject(progress)
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var progress: ProgressStore
    let onGame: (GameType) -> Void
    let onDaily: () -> Void
    let onChest: () -> Void
    let onAchievements: () -> Void
    let onEnglish: () -> Void

    var body: some View {
        GeometryReader { geo in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let landscape = geo.size.width > geo.size.height
            let columnsCount = isPad && landscape ? 6 : 4
            let rowsCount = Int(ceil(Double(GameType.allCases.count) / Double(columnsCount)))
            let gap: CGFloat = geo.size.height < 690 ? 4 : (isPad ? 8 : 6)
            let side: CGFloat = isPad ? 18 : 10

            let topH: CGFloat = isPad ? 70 : 58
            let missionH: CGFloat = isPad ? 92 : 78
            let petH: CGFloat = isPad ? (landscape ? 150 : 175) : (geo.size.height < 690 ? 100 : 124)
            let englishH: CGFloat = isPad ? 64 : 52
            let badgeH: CGFloat = isPad ? 60 : 48
            let totalFixed = topH + missionH + petH + englishH + badgeH + gap * 6
            let gridH = max(190, geo.size.height - totalFixed)
            let tileH = max(isPad ? 92 : 72, (gridH - gap * CGFloat(rowsCount - 1)) / CGFloat(rowsCount))

            VStack(spacing: gap) {
                topBar(isPad: isPad)
                    .frame(height: topH)

                HStack(spacing: gap) {
                    missionCard(
                        image: nil,
                        systemImage: "calendar.badge.checkmark",
                        title: "每日任務",
                        value: "\(progress.dailyProgress)/5",
                        tint: Color(red: 0.93, green: 0.98, blue: 0.84),
                        valueColor: .green,
                        action: onDaily
                    )

                    missionCard(
                        image: "TreasureChest",
                        systemImage: nil,
                        title: "星星寶箱",
                        value: progress.canOpenStarChest ? "可開啟!" : "\(progress.starChestProgress)/30",
                        tint: Color(red: 1.00, green: 0.94, blue: 0.80),
                        valueColor: .orange,
                        action: onChest
                    )
                }
                .frame(height: missionH)

                Image("MainVisual")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: petH)
                    .frame(height: petH)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? 24 : 18, style: .continuous))

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: gap),
                        count: columnsCount
                    ),
                    spacing: gap
                ) {
                    ForEach(GameType.allCases) { game in
                        CompactGameTile(game: game, isPad: isPad) {
                            onGame(game)
                        }
                        .frame(height: tileH)
                    }
                }
                .frame(height: gridH)

                Button(action: onEnglish) {
                    HStack(spacing: 12) {
                        Text("ABC")
                            .font(.system(size: isPad ? 28 : 23, weight: .heavy, design: .rounded))
                            .foregroundColor(Color(red: 0.20, green: 0.48, blue: 0.80))
                        Text("英文小教室")
                            .font(.system(size: isPad ? 25 : 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.brown)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: isPad ? 22 : 18, weight: .bold))
                            .foregroundColor(Color(red: 0.20, green: 0.48, blue: 0.80))
                    }
                    .padding(.horizontal, isPad ? 20 : 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 0.83, green: 0.93, blue: 1.00))
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? 22 : 18))
                }
                .buttonStyle(.plain)
                .frame(height: englishH)

                Button(action: onAchievements) {
                    HStack {
                        Text("🏅")
                        Text("我的徽章")
                            .fontWeight(.heavy)
                        Spacer()
                        Text("已累積 ⭐ \(progress.stars)")
                            .fontWeight(.heavy)
                    }
                    .font(.system(size: isPad ? 21 : 17, design: .rounded))
                    .foregroundColor(.brown)
                    .padding(.horizontal, isPad ? 20 : 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(red: 1.00, green: 0.91, blue: 0.64))
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? 22 : 18))
                }
                .buttonStyle(.plain)
                .frame(height: badgeH)
            }
            .padding(.horizontal, side)
            .padding(.vertical, gap)
        }
    }

    private func topBar(isPad: Bool) -> some View {
        HStack(spacing: isPad ? 18 : 10) {
            Text("小小腦力樂園")
                .font(.system(size: isPad ? 30 : 22, weight: .heavy, design: .rounded))
                .foregroundColor(.brown)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Spacer(minLength: 4)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: isPad ? 31 : 25))
                Text("\(progress.stars)")
                    .font(.system(size: isPad ? 25 : 20, weight: .heavy, design: .rounded))
            }

            Button(action: onChest) {
                HStack(spacing: 4) {
                    Image("TreasureChest")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isPad ? 42 : 34, height: isPad ? 42 : 34)
                    Text(progress.canOpenStarChest ? "OPEN" : "\(progress.starChestProgress)/30")
                        .font(.system(size: isPad ? 23 : 18, weight: .heavy, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundColor(.brown)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, isPad ? 18 : 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: isPad ? 26 : 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 5, y: 2)
    }

    private func missionCard(
        image: String?,
        systemImage: String?,
        title: String,
        value: String,
        tint: Color,
        valueColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Group {
                    if let image = image {
                        Image(image).resizable().scaledToFit()
                    } else if let systemImage = systemImage {
                        Image(systemName: systemImage)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.green)
                    }
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(value)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(valueColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct CompactGameTile: View {
    let game: GameType
    let isPad: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GeometryReader { geo in
                let compact = geo.size.height < 90
                VStack(spacing: compact ? 2 : 5) {
                    Image(systemName: game.symbol)
                        .font(.system(size: compact ? 22 : (isPad ? 31 : 27), weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: compact ? 36 : 48, height: compact ? 36 : 48)
                        .background(Color.white.opacity(0.88))
                        .clipShape(Circle())

                    Text(game.title)
                        .font(.system(size: compact ? 12 : (isPad ? 17 : 14), weight: .heavy, design: .rounded))
                        .foregroundColor(.brown)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 3)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(game.tint)
                .clipShape(RoundedRectangle(cornerRadius: compact ? 14 : 19, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: compact ? 14 : 19)
                        .stroke(Color.white, lineWidth: 1)
                )
            }
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch game {
        case .find, .maze, .math: return .blue
        case .same, .match, .memory, .odd: return .pink
        case .colorShape, .pattern: return .purple
        case .count: return .teal
        case .compare: return .orange
        case .order: return .green
        }
    }
}

struct DailyMissionView: View {
    @EnvironmentObject private var progress: ProgressStore
    let onBack: () -> Void

    private let tasks = [
        "完成任一腦力遊戲",
        "完成一題英文測驗",
        "完成一題聽力挑戰",
        "學會一個英文單字",
        "完成一次發音練習"
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 10) {
                PageHeader(title: "每日任務", onBack: onBack)

                Text("✅ 今天完成 \(progress.dailyProgress) / 5 個挑戰")
                    .font(.system(size: geo.size.width > 700 ? 26 : 20, weight: .heavy, design: .rounded))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .background(Color(red: 0.92, green: 0.98, blue: 0.84))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                VStack(spacing: 8) {
                    ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                        let done = index < progress.dailyProgress
                        HStack {
                            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(done ? .green : .gray)
                            Text(task)
                                .font(.system(size: geo.size.width > 700 ? 22 : 17, weight: .bold, design: .rounded))
                            Spacer()
                        }
                        .foregroundColor(.brown)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(done ? Color.green.opacity(0.11) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .padding(12)
        }
        .background(Color(red: 0.98, green: 1.00, blue: 0.94).ignoresSafeArea())
    }
}

struct StarChestView: View {
    @EnvironmentObject private var progress: ProgressStore
    let onBack: () -> Void

    private let rewards: [(Int, String, Color)] = [
        (5, "小徽章", Color(red: 0.91, green: 0.98, blue: 0.84)),
        (10, "貼紙", Color(red: 1.00, green: 0.91, blue: 0.81)),
        (15, "驚喜卡", Color(red: 0.94, green: 0.87, blue: 1.00)),
        (20, "彩色徽章", Color(red: 0.86, green: 0.93, blue: 1.00)),
        (25, "星星獎勵", Color(red: 1.00, green: 0.87, blue: 0.91)),
        (30, "終極寶箱", Color(red: 1.00, green: 0.91, blue: 0.65))
    ]

    var body: some View {
        GeometryReader { geo in
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnsCount = isPad ? 3 : 2
            let spacing: CGFloat = isPad ? 12 : 8

            VStack(spacing: spacing) {
                PageHeader(title: "星星寶箱", onBack: onBack)

                HStack(spacing: 14) {
                    Image("TreasureChest")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isPad ? 120 : 88, height: isPad ? 120 : 88)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("收集星星開寶箱")
                            .font(.system(size: isPad ? 27 : 20, weight: .heavy, design: .rounded))
                        Text("完成遊戲與英文挑戰，累積星星解鎖獎勵")
                            .font(.system(size: isPad ? 16 : 13, weight: .medium, design: .rounded))
                            .foregroundColor(.brown.opacity(0.68))
                        Text("⭐ \(progress.starChestProgress) / 30")
                            .font(.system(size: isPad ? 32 : 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .foregroundColor(.brown)
                .padding(.horizontal, 16)
                .frame(height: isPad ? 145 : 112)
                .background(Color(red: 1.00, green: 0.91, blue: 0.67))
                .clipShape(RoundedRectangle(cornerRadius: 24))

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnsCount),
                    spacing: spacing
                ) {
                    ForEach(Array(rewards.enumerated()), id: \.offset) { _, item in
                        RewardChestCard(
                            threshold: item.0,
                            title: item.1,
                            tint: item.2,
                            unlocked: progress.starChestProgress >= item.0
                        ) {
                            if item.0 == 30 && progress.canOpenStarChest {
                                progress.openStarChest()
                            } else if progress.starChestProgress >= item.0 {
                                Feedback.success()
                            } else {
                                Feedback.tap()
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)

                Button(action: { }) {
                    HStack {
                        Text("🏅")
                        Text("我的徽章")
                        Spacer()
                        Text("已累積 ⭐ \(progress.stars)")
                    }
                    .font(.system(size: isPad ? 21 : 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color(red: 1.00, green: 0.91, blue: 0.64))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
        }
        .background(Color(red: 1.00, green: 0.97, blue: 0.91).ignoresSafeArea())
    }
}

struct RewardChestCard: View {
    let threshold: Int
    let title: String
    let tint: Color
    let unlocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(threshold)星")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(unlocked ? .orange : .gray)

                Image("TreasureChest")
                    .resizable()
                    .scaledToFit()
                    .opacity(unlocked ? 1.0 : 0.52)
                    .frame(maxHeight: 78)

                Text(unlocked ? title : "🔒 \(title)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(.brown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            .padding(6)
            .frame(maxWidth: .infinity, minHeight: 118)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

struct PageHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 54, height: 44)
                    .background(Color(red: 0.31, green: 0.56, blue: 0.91))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.system(size: 27, weight: .heavy, design: .rounded))
                .foregroundColor(Color(red: 0.92, green: 0.31, blue: 0.42))
                .frame(maxWidth: .infinity)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Color.clear.frame(width: 54, height: 44)
        }
        .frame(height: 48)
    }
}
