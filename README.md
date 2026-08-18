# PetLingo Kids / 小小腦力樂園 — iOS v1.0.0

## 平台
- SwiftUI
- iOS 15.0+
- iPhone + iPad
- TARGETED_DEVICE_FAMILY = 1,2
- iPhone 支援直向、橫向
- iPad / iPad mini 支援直向、上下顛倒、橫向

## 自適應介面
首頁使用 GeometryReader 依裝置與方向調整：
- iPhone：12 款遊戲 4 欄 × 3 列
- iPad mini 直向：4 欄 × 3 列，放大卡片與毛孩
- iPad mini 橫向：6 欄 × 2 列
- 毛孩圖片使用 scaledToFit，不裁切耳朵、身體與姓名牌
- 小螢幕會自動縮小遊戲圖示與文字，不靠固定像素硬裁切

## 功能
- 每日任務 0/5
- 星星寶箱 0/30
- 寶箱獎勵制，不使用關卡式寶箱地圖
- 12 款遊戲：
  找一找、找一樣、顏色圖形、迷宮、連連看、數一數、
  數學練習、記憶挑戰、找不同、規律接龍、比一比、排順序
- 英文小教室：
  單字學習、聽力挑戰、英文測驗、發音練習
- 數字 0~100 顯示真正阿拉伯數字
- 發音練習：示範結束後 0.5 秒才開麥克風
- 進度使用 UserDefaults 儲存

## 輕柔女聲
iOS 使用 AVSpeechSynthesizer：
- zh-TW 優先 Meijia / Mei-Jia 類女聲
- en-US 優先 Samantha / Ava / Allison / Susan / Nicky / Joelle 類女聲
- 若有 Enhanced Voice，會提高選擇權重
- 找不到指定女聲時才退回同語系系統 Voice
- 語速稍慢、pitch 僅微調，避免卡通化電子音

## Xcode
開啟：
`KidsPetLearning.xcodeproj`

Scheme：
`KidsPetLearning`

Deployment Target：
`iOS 15.0`

Bundle ID：
`com.boga.kidgame.ios`

## GitHub Actions
已附：
`.github/workflows/ios.yml`

可在 macOS 15 runner 建置 iOS Simulator 版本。

> 此環境無 Xcode，因此本 ZIP 已做專案結構與 Swift 原始碼靜態檢查，
> 但未在此處宣稱 xcodebuild 已實際通過。
