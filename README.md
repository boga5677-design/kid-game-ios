# PetLingo Kids iOS v1.0.1 — CI 修正版

## 這版修正的錯誤

GitHub Actions log 出現：

- `Using the first of multiple matching destinations`
- 第一個 destination 是 `My Mac — Designed for [iPad,iPhone]`
- 同時列出 iOS、iOS Simulator、visionOS Simulator
- 最後 `BUILD FAILED / ANALYZE FAILED / exit code 65`

這代表執行中的 workflow 沒有把 Xcode 明確鎖定到 iOS Simulator。

## v1.0.1 修正

### Xcode Project
- iOS Deployment Target：15.0
- iPhone + iPad：`TARGETED_DEVICE_FAMILY = "1,2"`
- `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`
- `SUPPORTS_MACCATALYST = NO`
- 新增 `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD = NO`
- 新增 `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD = NO`
- Marketing Version：1.0.1
- Build：2

### GitHub Actions
`.github/workflows/ios.yml` 已改成明確：

```bash
xcodebuild \
  -project KidsPetLearning.xcodeproj \
  -scheme KidsPetLearning \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$RUNNER_TEMP/PetLingoDerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  clean build
```

不再讓 `xcodebuild` 自己猜 My Mac / iOS Device / visionOS。

另外：
- 建置失敗時會直接 grep 出真正的 `error:` 行。
- 原始 `xcodebuild.log` 無論成功失敗都會上傳成 Artifact。
- 成功後直接從固定 DerivedData 路徑打包 Simulator `.app`。
- 專案根目錄新增 `default`，內容為 `KidsPetLearning`，相容舊 GitHub iOS starter workflow 的 `scheme=default` 寫法。

## 重要：GitHub 上舊 workflow 要換掉

你的失敗 log 第一行：

```bash
if [ $scheme = default ]; then scheme=$(cat default); fi
```

不是本 ZIP 新版 `ios.yml` 的 Build 指令。

請在 GitHub `.github/workflows/` 確認：
- 使用本版 `ios.yml`
- 舊的 iOS starter workflow 若是另一個檔名，請停用或刪除
- 不要同時跑舊 workflow 與新版 workflow

## 驗證
此環境沒有 macOS / Xcode，因此不能在這裡宣稱 xcodebuild 已通過。
已完成：
- Swift syntax parse
- Info.plist validation
- shared scheme presence
- project settings static validation
- ZIP integrity check
