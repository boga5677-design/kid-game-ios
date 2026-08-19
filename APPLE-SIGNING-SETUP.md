# 產生可安裝 iPhone / iPad IPA：Apple 簽章設定

本專案已改成真正的 `iphoneos` Archive + signed `.ipa`。

## 你需要的 Apple 資料

GitHub Repository Secrets 建立 3 個：

### 1. IOS_P12_BASE64
Apple Development 或 Apple Distribution 憑證匯出的 `.p12`，
轉成 Base64 後的完整內容。

Windows PowerShell：

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("certificate.p12")
) | Set-Content -NoNewline IOS_P12_BASE64.txt
```

把 `IOS_P12_BASE64.txt` 全部內容貼到 GitHub Secret：

`IOS_P12_BASE64`

### 2. IOS_P12_PASSWORD

匯出 `.p12` 時設定的密碼。

Secret 名稱：

`IOS_P12_PASSWORD`

### 3. IOS_MOBILEPROVISION_BASE64

Development 或 Ad Hoc `.mobileprovision` Provisioning Profile。

**要直接安裝的 iPhone / iPad UDID 必須包含在這份 Profile 裡。**

PowerShell：

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("PetLingoKids.mobileprovision")
) | Set-Content -NoNewline IOS_MOBILEPROVISION_BASE64.txt
```

把文字內容貼到 Secret：

`IOS_MOBILEPROVISION_BASE64`

---

# 不需要另外設定

Workflow 會直接從 Provisioning Profile 自動讀取：

- Team ID
- Bundle ID
- Provisioning Profile UUID
- Provisioning Profile Name
- Development / Ad Hoc / Enterprise 類型

也會從 `.p12` 自動找 Apple code-signing identity。

因此不必額外建立 Team ID / Bundle ID Secret。

---

# Provisioning Profile 必須是哪一種？

要「下載後直接裝在登錄的 iPhone / iPad」：

## Development Profile
可安裝到 Profile 內登錄的測試裝置。

或：

## Ad Hoc Profile
同樣只可安裝到 Provisioning Profile 中已登錄 UDID 的裝置。

如果使用 App Store Distribution Profile，Workflow 會直接停止，
因為 App Store Profile 產出的 IPA 不是拿來直接側載安裝的。

---

# GitHub Action 成功後

Actions → 該次 Build → Artifacts：

`PetLingoKids-iOS-Installable-IPA`

GitHub 下載 Artifact 時外層仍會是 ZIP（這是 GitHub Artifact 的固定行為）。

解壓後真正的安裝檔是：

`PetLingoKids-iOS-v1.0.3.ipa`

---

# 安裝條件

即使 IPA 已正確簽章：

- Development / Ad Hoc：目標 iPhone 或 iPad 的 UDID 必須已包含在 Provisioning Profile。
- App 的 Bundle ID 必須與 Profile 一致。
- Certificate 與 Provisioning Profile 必須屬於同一 Apple Developer Team。
- Provisioning Profile 與 Certificate 都不能過期。

---

# 目前 App 平台

- iOS 15.0+
- iPhone
- iPad / iPad mini
- 實機 SDK：iphoneos
- Release Archive
- Signed IPA
