# PetLingo Kids v1.0.4：可安裝 IPA 必要設定

你之前下載到的是 `PetLingoKids-iOS-Simulator`。
那個檔案的 Info.plist 會顯示：

- `CFBundleSupportedPlatforms = iPhoneSimulator`
- `DTPlatformName = iphonesimulator`

因此永遠不能安裝到 iPhone / iPad。

v1.0.4 已把 GitHub Workflow 改成真正的：

`iphoneos -> archive -> Apple signing -> .ipa`

## GitHub Repository Secrets

必須建立 3 個：

1. `IOS_P12_BASE64`
2. `IOS_P12_PASSWORD`
3. `IOS_MOBILEPROVISION_BASE64`

### IOS_P12_BASE64
Apple Development 或 Apple Distribution 憑證匯出的 `.p12`，
轉成 Base64 後貼入 Secret。

### IOS_P12_PASSWORD
`.p12` 匯出時設定的密碼。

### IOS_MOBILEPROVISION_BASE64
Development 或 Ad Hoc `.mobileprovision` 轉成 Base64。

若要直接安裝到特定 iPhone / iPad，
該裝置 UDID 必須包含在這份 Provisioning Profile。

## 成功後

GitHub Actions 只會產生：

`PetLingoKids-iOS-Installable-IPA`

下載 Artifact 後解壓，可得到：

`PetLingoKids-iOS-v1.0.4.ipa`

這才是實機安裝檔。

## 如果沒有 Apple 簽章資料

GitHub Actions 會直接顯示哪個 Secret 缺少，
不會再產生看似成功、實際只能給 Simulator 用的檔案。
