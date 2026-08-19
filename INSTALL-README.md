# PetLingo Kids iOS v1.0.5 — 實機 IPA

## 這次確認到的真正問題

你最新上傳的 GitHub Repository 內：

`.github/workflows/objective-c-xcode.yml`

仍然是：

- `-sdk iphonesimulator`
- `-destination 'generic/platform=iOS Simulator'`
- Artifact：`PetLingoKids-iOS-Simulator`

而你上傳的最新成品也確實是：

- `DTPlatformName = iphonesimulator`
- `CFBundleSupportedPlatforms = iPhoneSimulator`
- 沒有 `embedded.mobileprovision`
- 沒有 Code Signature

所以它一定不能安裝到 iPhone / iPad。

## v1.0.5 改成真正實機平台

現在 Workflow 使用：

```bash
-sdk iphoneos
-destination 'generic/platform=iOS'
```

成功後 Artifact：

`PetLingoKids-iOS-Device-IPA`

解壓後：

`PetLingoKids-iOS-v1.0.5-Device-Unsigned.ipa`

這個 IPA 是 **iphoneos 實機版本**，不再是 Simulator。

## 但 iOS 跟 Android 不一樣

`.ipa` 不能像 Android APK 一樣在 iPhone 的「檔案」App 裡點一下就安裝。

Apple 要求 App 在安裝前一定要有有效 Code Signing。

這版 GitHub Actions 先產生「真正 iPhone/iPad 平台的 IPA」，
之後需要用其中一種方式簽章/安裝：

- Mac + Xcode / Apple Configurator
- Sideloadly
- AltStore / AltServer
- Apple Developer Development / Ad Hoc 簽章
- TestFlight

如果使用 Development / Ad Hoc 簽章，
Provisioning Profile 還必須包含目標 iPhone / iPad 的 UDID。

## 重要：確認 GitHub Workflow 有真的被換掉

GitHub 開啟：

`.github/workflows/objective-c-xcode.yml`

第一行必須是：

`name: PetLingo Kids iPhone iPad Device IPA`

並且搜尋檔案，應該看到：

`-sdk iphoneos`

不能再看到：

`-sdk iphonesimulator`

如果你的上傳方式沒有覆蓋 `.github` 隱藏資料夾，
專案根目錄另外附了一份：

`COPY-THIS-TO-objective-c-xcode.yml`

請把它的內容整份複製到 GitHub 的：

`.github/workflows/objective-c-xcode.yml`
