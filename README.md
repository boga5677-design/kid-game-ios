# PetLingo Kids iOS v1.0.2 — GitHub Actions 修正版

## 這次真正找到的問題

你上傳的 repository 內實際執行的是：

`.github/workflows/objective-c-xcode.yml`

舊檔裡有：

```bash
if [ $scheme = default ]; then scheme=$(cat default); fi
xcodebuild clean build analyze ...
```

而且沒有指定：

```bash
-sdk iphonesimulator
-destination 'generic/platform=iOS Simulator'
```

所以 Xcode 會同時看到：

- Any iOS Device
- Any iOS Simulator Device

然後警告：

`Using the first of multiple matching destinations`

這次 v1.0.2 是直接修改你上傳 ZIP 裡的
`.github/workflows/objective-c-xcode.yml`，
不是另外新增一個沒有被執行的 workflow。

## 新 workflow

建置固定使用：

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
  CODE_SIGN_IDENTITY="" \
  clean build
```

### 另外取消舊的 `analyze`

目前第一目標是先確定 App 可以成功編譯。
舊 workflow 把 `clean build analyze` 全部串在一起，
只要 Analyze 出問題也會整個 Job 失敗，而且 xcpretty 把真正 error 縮掉。

v1.0.2 先只做 `clean build`。

若失敗：
- Workflow 會直接印出所有 `error:` 行
- 完整 `xcodebuild.log` 也會上傳成 Artifact

## Project
- iOS Deployment Target：15.0
- iPhone + iPad：1,2
- Mac Catalyst：NO
- Designed for iPhone/iPad on Mac：NO
- Designed for iPhone/iPad on visionOS：NO
- Version：1.0.2
- Build：3

## GitHub 上傳方式

請用這一包內容直接覆蓋 repository。

特別確認 GitHub 上：

`.github/workflows/objective-c-xcode.yml`

第一行應為：

`name: PetLingo Kids iOS Simulator Build`

如果還看到：

`name: Xcode - Build and Analyze`

代表 GitHub 仍然在跑舊 workflow。
