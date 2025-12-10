# 快速設定指南

這個指南幫助團隊成員在新電腦上快速設定 UITest 分析工具。

## 前提條件

- 已安裝 Xcode 和 Command Line Tools
- 已 clone iOSCharmander 主專案
- 已安裝 jq (JSON 處理工具): `brew install jq`
- 可連線到 CI 機器（或有其他存取方式）

## 設定步驟

### 1. Clone AI Specs Repository

```bash
# 假設你的 iOSCharmander 在 ~/code/XcodeFile/iOScharmander
# 注意：目錄名稱可能因環境而異
cd ~/code/XcodeFile  # 或 ~/code/VIVOTEK

# Clone AI specs repo (與主專案平行)
git clone https://github.com/RyanChenVivo/iOSCharmander-ai-specs.git
```

預期的目錄結構：
```
~/code/XcodeFile/  (或 ~/code/VIVOTEK/)
├── iOScharmander/           # 主專案
└── iOSCharmander-ai-specs/  # AI 規格和工具
```

### 2. 建立 Symlinks

讓主專案可以存取 AI 文件：

```bash
cd iOSCharmander-ai-specs
./setup-ai-dev.sh
```

這會在主專案目錄下建立：
- `openspec/` -> symlink to `../iOSCharmander-ai-specs/openspec/`
- `.claude/` -> symlink to `../iOSCharmander-ai-specs/.claude/`

### 3. 驗證設定（新架構不需要 config.sh）

新架構簡化了設定，配置直接寫在腳本中。你只需要確認：

```bash
# 測試是否可連線到 CI 機器
ssh vivotekinc@10.15.254.191 "echo 'Connection successful'"

# 測試能否存取提取的資料
ssh vivotekinc@10.15.254.191 "ls /Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest"
```

如果 CI 機器的 IP 或路徑不同，需要編輯 `download_test_data.sh` 中的配置：

```bash
# 編輯下載腳本
nano uitest-automation/download_test_data.sh

# 修改以下變數（如需要）
CI_MACHINE="vivotekinc@10.15.254.191"
CI_DATA_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
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

### 5. 測試下載腳本

```bash
cd iOSCharmander-ai-specs

# 測試下載腳本
./uitest-automation/download_test_data.sh
```

如果看到類似輸出，表示設定成功：
```
=== 下載 UITest 測試資料 ===
從 CI 機器下載 JSON 檔案...

正在下載...
✓ 下載完成！

資料位置: /Users/yourname/Downloads/UITestAnalysis/latest

測試日期: 2025-12-08
總測試數: 120
失敗數: 0

沒有失敗的測試！
```

### 6. （CI 管理員）部署 CI 端腳本

**注意：這步驟只需要執行一次，由 CI 管理員完成。**

```bash
# 將提取腳本複製到 CI 機器
scp uitest-automation/ci-scripts/extract_uitest_data.sh \
    vivotekinc@10.15.254.191:/Users/vivotekinc/Documents/CICD/scripts/

# 設定執行權限
ssh vivotekinc@10.15.254.191 \
    "chmod +x /Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh"

# 在 Jenkins UITest job 中加入執行腳本的步驟
# 詳見 ci-scripts/README.md
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

### Q4: 找不到測試資料

**原因**: CI 端可能還沒部署提取腳本

**解決**:
1. 確認 CI 機器上是否已部署 `extract_uitest_data.sh`
2. 確認 Jenkins 是否已整合該腳本
3. 檢查 CI 機器上的資料路徑：
```bash
ssh vivotekinc@10.15.254.191 "ls -la /Users/vivotekinc/Documents/CICD/UITestAnalysisData/"
```

如果沒有看到資料，請聯繫 CI 管理員部署腳本（詳見 `ci-scripts/README.md`）。

### Q5: 無法下載 CI 測試報告

**選項 1**: 手動複製報告

如果你有 CI 機器的實體存取權限，可以直接複製提取的資料：
```bash
# 從 CI 機器複製到 USB 或網路硬碟
# 然後複製到本機的 Downloads/UITestAnalysis/
cp -r /path/to/copied/data ~/Downloads/UITestAnalysis/
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
- [ ] Symlinks 建立成功 (`ls -l iOScharmander/openspec`)
- [ ] jq 已安裝 (`jq --version`)
- [ ] 可以連線到 CI 機器 (`ssh vivotekinc@10.15.254.191`)
- [ ] 可以存取 CI 端提取的資料 (`ssh vivotekinc@10.15.254.191 "ls /Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest"`)
- [ ] 下載腳本可以執行 (`./uitest-automation/download_test_data.sh`)
- [ ] AI slash command 可用 (在 Claude Code 中執行 `/analyze-uitest`)

## 下一步

設定完成後，請參考：
- [README.md](./README.md) - 快速開始與使用指南
- [WRITING_GUIDE.md](./WRITING_GUIDE.md) - UITest 編寫指南
- [ci-scripts/README.md](./ci-scripts/README.md) - CI 端腳本部署（CI 管理員）

## 需要協助？

如有問題，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)
