# 快速設定指南

這個指南幫助團隊成員在新電腦上快速設定 UITest 分析工具。

## 前提條件

- 已安裝 Xcode 和 Command Line Tools
- 已 clone iOSCharmander 主專案
- 已安裝 jq (JSON 處理工具): `brew install jq`

## 設定步驟

### 1. Clone AI Specs Repository

```bash
# 假設你的 iOSCharmander 在 ~/code/VIVOTEK/iOSCharmander
cd ~/code/VIVOTEK

# Clone AI specs repo (與主專案平行)
git clone https://github.com/RyanChenVivo/iOSCharmander-ai-specs.git
```

預期的目錄結構：
```
~/code/VIVOTEK/
├── iOSCharmander/          # 主專案
└── iOSCharmander-ai-specs/ # AI 規格和工具
```

### 2. 建立 Symlinks

讓主專案可以存取 AI 文件：

```bash
cd iOSCharmander-ai-specs
./setup-ai-dev.sh
```

這會在 `iOSCharmander/` 目錄下建立：
- `openspec/` -> symlink to `../iOSCharmander-ai-specs/openspec/`
- `.claude/` -> symlink to `../iOSCharmander-ai-specs/.claude/`

### 3. 設定 CI 連線資訊

```bash
cd iOSCharmander-ai-specs

# 複製設定檔範例
cp config.example.sh config.sh

# 編輯設定檔
nano config.sh
```

更新以下設定：

```bash
# CI 機器連線資訊
CI_MACHINE="vivotekinc@10.15.254.191"  # 確認 IP 正確

# CI 測試報告路徑 (通常不需要改)
CI_REPORT_BASE="/Users/vivotekinc/Documents/CICD/UITestReport"
```

### 4. 設定 SSH 連線 (如果需要從 CI 機器下載)

```bash
# 測試能否連到 CI 機器
ping -c 1 10.15.254.191

# 如果可以連線，設定 SSH key
ssh-copy-id vivotekinc@10.15.254.191

# 測試 SSH 連線
ssh vivotekinc@10.15.254.191 "echo 'Connection successful'"

# 測試能否存取測試報告目錄
ssh vivotekinc@10.15.254.191 "ls /Users/vivotekinc/Documents/CICD/UITestReport/"
```

**注意**: 如果公司網路有防火牆限制，可能需要 IT 協助開通連線權限。

### 5. 測試腳本

```bash
cd iOSCharmander-ai-specs

# 測試腳本能否執行
./Scripts/analyze_uitest_failures.sh --help

# 嘗試分析最近的測試結果
./Scripts/analyze_uitest_failures.sh -d today
```

如果看到類似輸出，表示設定成功：
```
========================================
UITest Failure Analysis
========================================
XCResult: /Users/.../CI_Reports/2025-12-03.xcresult
Output:   /Users/.../Downloads/UITestAnalysis

[1/5] Extracting test summary...
✓ Saved to: .../test_summary.json
...
```

## 常見問題排除

### Q1: `./setup-ai-dev.sh: No such file or directory`

**原因**: 腳本可能沒有執行權限

**解決**:
```bash
chmod +x setup-ai-dev.sh
./setup-ai-dev.sh
```

### Q2: `ssh: connect to host 10.15.254.191 port 22: Connection refused`

**原因**: 無法連線到 CI 機器 (防火牆、VPN、IP 錯誤等)

**解決**:
1. 檢查是否在公司網路內
2. 確認 CI 機器 IP 是否正確
3. 聯繫 IT 確認防火牆設定
4. 或使用網路掛載方式存取 CI 機器

### Q3: `jq: command not found`

**原因**: 未安裝 jq 工具

**解決**:
```bash
brew install jq
```

### Q4: 腳本找不到 iOSCharmander 路徑

**原因**: 目錄結構不符合預期

**解決**:
檢查目錄結構，確保 `iOSCharmander` 和 `iOSCharmander-ai-specs` 在同一層：
```bash
ls ~/code/VIVOTEK/
# 應該看到:
# iOSCharmander/
# iOSCharmander-ai-specs/
```

如果路徑不同，編輯 `config.sh` 手動指定：
```bash
IOSCHARMANDER_PATH="/實際/路徑/到/iOSCharmander"
```

### Q5: 無法下載 CI 測試報告

**選項 1**: 手動複製報告

如果你有 CI 機器的實體存取權限：
```bash
# 從 CI 機器複製到 USB 或網路硬碟
# 然後在本機分析
./Scripts/analyze_uitest_failures.sh -x /path/to/copied.xcresult
```

**選項 2**: 使用網路掛載

如果 CI 機器有共享資料夾：
```bash
# 在 Finder 中: Go > Connect to Server
# 輸入: smb://10.15.254.191
# 掛載後資料夾會出現在 /Volumes/

# 腳本會自動偵測掛載的路徑
```

## 驗證設定

執行這個檢查清單：

- [ ] Clone 完成，目錄結構正確
- [ ] Symlinks 建立成功 (`ls -l ~/code/VIVOTEK/iOSCharmander/openspec`)
- [ ] config.sh 已建立並設定
- [ ] jq 已安裝 (`jq --version`)
- [ ] 可以連線到 CI 機器 (或有替代方案)
- [ ] 腳本可以執行 (`./Scripts/analyze_uitest_failures.sh --help`)

## 下一步

設定完成後，請參考：
- [README.md](./README.md) - 整體說明
- [UITest-Analysis-Guide.md](./UITest-Analysis-Guide.md) - 詳細使用指南

## 需要協助？

如有問題，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)
