# PetLingo Kids iOS v1.0.3

這版已從 Simulator `.app` 工作流程改為 **真正 iPhone / iPad 實機 IPA 工作流程**。

## 成功後只產生一個 Artifact

`PetLingoKids-iOS-Installable-IPA`

解壓後：

`PetLingoKids-iOS-v1.0.3.ipa`

建置失敗時才另外產生：

`PetLingoKids-iOS-Signing-Logs`

## 重要

可安裝 iOS App 必須有 Apple code signing。

請先依：

`APPLE-SIGNING-SETUP.md`

建立這 3 個 GitHub Repository Secrets：

- `IOS_P12_BASE64`
- `IOS_P12_PASSWORD`
- `IOS_MOBILEPROVISION_BASE64`

Workflow 會自動從 Profile / Certificate 判斷其餘簽章資訊。

## App

- iOS 15.0+
- iPhone + iPad / iPad mini
- version 1.0.3
- build 4
- Release `iphoneos`
- Signed `.ipa`
