# 設定檢查清單

在另一台電腦上設定此工具前，請按照此清單確認。

## ✅ 準備工作

### 1. 系統需求
- [ ] macOS 系統
- [ ] 已安裝 Xcode 和 Command Line Tools
- [ ] 已安裝 jq: `brew install jq`
- [ ] Git 已設定

### 2. 專案準備
- [ ] 已 clone iOSCharmander 主專案
- [ ] 知道主專案路徑（例如：`~/code/VIVOTEK/iOSCharmander`）

---

## 📥 安裝步驟

### 步驟 1: Clone AI Specs Repository

```bash
# 進到主專案的父目錄
cd ~/code/VIVOTEK  # 根據你的實際路徑調整

# Clone AI specs repo
git clone https://github.com/RyanChenVivo/iOSCharmander-ai-specs.git
```

**檢查點**：
- [ ] 確認目錄結構如下：
  ```
  ~/code/VIVOTEK/
  ├── iOSCharmander/
  └── iOSCharmander-ai-specs/
  ```

### 步驟 2: 建立 Symlinks

```bash
# 在主專案目錄執行
cd ~/code/VIVOTEK/iOSCharmander  # 根據你的實際路徑調整
./setup-ai-dev.sh
```

**檢查點**：
- [ ] 看到 "✨ AI development environment is ready!" 訊息
- [ ] 檢查 symlinks 是否建立：
  ```bash
  ls -l openspec
  ls -l .claude
  ls -l uitest-automation
  ```
  應該看到 `->` 符號指向 `../iOSCharmander-ai-specs/...`

### 步驟 3: 設定 UITest 分析工具

```bash
# 複製設定檔範例
cp uitest-automation/config.example.sh config.sh

# 編輯設定檔
nano config.sh
```

**需要確認/修改的設定**：
- [ ] `CI_MACHINE="vivotekinc@10.15.254.191"` - CI 機器 IP（通常不用改）
- [ ] `CI_REPORT_BASE="/Users/vivotekinc/Documents/CICD/UITestReport"` - CI 報告路徑（通常不用改）
- [ ] 其他設定使用預設值即可

### 步驟 4: 設定 SSH 連線到 CI 機器

**重要**：你的電腦需要能連到 CI 機器的 IP `10.15.254.191`（在公司網路內）

```bash
# 測試能否連線
ping -c 1 10.15.254.191

# 如果 ping 通，設定 SSH key（需要輸入 CI 機器密碼）
ssh-copy-id vivotekinc@10.15.254.191
```

輸入密碼後，再測試：
```bash
# 測試免密碼登入
ssh vivotekinc@10.15.254.191 "echo 'Success'"
```

**檢查點**：
- [ ] Ping 到 CI 機器成功
- [ ] SSH 免密碼登入成功

---

## 🧪 測試

### 測試 1: 執行分析腳本

```bash
cd ~/code/VIVOTEK/iOSCharmander-ai-specs
./uitest-automation/analyze_uitest_failures.sh -d today
```

**預期結果**：
- [ ] 看到 "Downloading from CI machine..." 訊息
- [ ] 看到 "✓ Downloaded successfully"
- [ ] 看到測試統計（Total, Passed, Failed）
- [ ] 看到 "Analysis Complete!"
- [ ] 產生檔案在 `~/Downloads/UITestAnalysis/YYYY-MM-DD/`

### 測試 2: 檢查輸出檔案

```bash
ls ~/Downloads/UITestAnalysis/$(date +%Y-%m-%d)/
```

**應該看到**：
- [ ] `ANALYSIS_REPORT.md`
- [ ] `test_summary.json`
- [ ] `test_details.json`
- [ ] `test_failures.json` (如果有失敗)
- [ ] `attachments/` 目錄
- [ ] `diagnostics/` 目錄

---

## ❌ 常見問題

### 問題 1: "jq: command not found"

**解決**：
```bash
brew install jq
```

### 問題 2: "Connection refused" 連不到 CI 機器

**可能原因**：
1. 不在公司網路內
2. IP 位址錯誤

**檢查**：
```bash
# 在 CI 機器上（透過螢幕共享）執行
ifconfig | grep "inet " | grep -v 127.0.0.1
```

找到正確的 IP（應該是 `10.15.x.x` 網段），然後更新 `config.sh`

### 問題 3: "Permission denied" SSH 認證失敗

**解決**：
```bash
# 重新設定 SSH key
ssh-copy-id vivotekinc@10.15.254.191
```

### 問題 4: 找不到 iOSCharmander 路徑

**檢查目錄結構**：
```bash
ls ~/code/VIVOTEK/
```

應該同時看到 `iOSCharmander` 和 `iOSCharmander-ai-specs`

如果路徑不同，編輯 `config.sh`：
```bash
IOSCHARMANDER_PATH="/實際/路徑/到/iOSCharmander"
```

---

## ✨ 完成確認

全部完成後，你應該能：

- [ ] 執行 `./uitest-automation/analyze_uitest_failures.sh -d today` 成功
- [ ] 自動從 CI 機器下載測試結果
- [ ] 在 `~/Downloads/UITestAnalysis/` 看到按日期分類的分析結果
- [ ] 可以用 Claude Code 分析測試失敗

---

## 📞 需要協助？

如果遇到問題：
1. 檢查此清單的每個步驟
2. 參考 `uitest-automation/SETUP.md` 詳細說明
3. 聯繫 Ryan Chen (ryan.cl.chen@vivotek.com)
