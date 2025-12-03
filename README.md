# iOSCharmander AI Specifications

這個 repository 包含 iOSCharmander 專案的 AI 輔助開發文件。

## 內容

- `/openspec/` - OpenSpec 規格和變更記錄
  - `AGENTS.md` - AI Agent 指引文件
  - `project.md` - 專案規格說明
  - `specs/` - 功能規格文件
  - `changes/` - 變更記錄和提案
- `/.claude/` - Claude Code 的設定和自定義指令
- `/uitest-automation/` - UITest 自動化分析工具
  - `README.md` - 工具說明
  - `SETUP.md` - 快速設定指南
  - `GUIDE.md` - 詳細使用指南
  - `analyze_uitest_failures.sh` - 主要分析腳本
  - `analyze-uitest-command.md` - Claude Code 指令
  - `config.example.sh` - 設定檔範例
- `config.sh` - 本地設定檔 (不納入版控)

## 用途

這些文件用於 Claude Code 進行 AI 輔助開發,包含:
- 專案架構和規格文件
- 功能開發的規劃和追蹤
- AI Agent 的行為指引
- 自定義的 Claude Code 指令

## 使用方式

這個 repo 透過 symlink 連結到主專案,讓 Claude Code 可以存取這些檔案。

### 設定步驟

#### 1. Clone 此 repository

```bash
# 假設你的 iOSCharmander 在 ~/code/VIVOTEK/iOSCharmander
cd ~/code/VIVOTEK
git clone https://github.com/RyanChenVivo/iOSCharmander-ai-specs.git
```

#### 2. 建立 symlinks (讓主專案可以存取 AI 文件)

```bash
# 在主專案目錄執行設定腳本
cd ../iOSCharmander
./setup-ai-dev.sh
```

這個腳本會：
- 檢查 iOSCharmander-ai-specs 是否存在（不存在會自動 clone）
- 自動建立 symlinks
- 驗證設定是否正確

#### 3. 設定 UITest 分析工具 (可選)

如果需要使用 UITest 自動化分析功能：

```bash
# 複製設定檔範例
cd iOSCharmander-ai-specs
cp uitest-automation/config.example.sh config.sh

# 編輯 config.sh，更新 CI 機器連線資訊
nano config.sh
```

詳細設定請參考 [uitest-automation/SETUP.md](./uitest-automation/SETUP.md)

### 日常使用

#### OpenSpec 開發流程

```bash
# 1. 使用 Claude Code 開發功能 (在主專案目錄)
cd iOSCharmander
# 使用 /openspec:proposal, /openspec:apply 等指令

# 2. Commit 主專案的程式碼變更
git add .
git commit -m "feat: add new feature"
git push

# 3. Commit AI 文件的變更 (在 AI specs repo)
cd ../iOSCharmander-ai-specs
git add .
git commit -m "docs: update specs for new feature"
git push
```

#### UITest 失敗分析流程

```bash
# 方法 1: 使用 Claude Code (推薦)
# 在對話中載入指令文件:
/add-file uitest-automation/analyze-uitest-command.md
# 並詢問: "我們來看看今天UITest的狀況並且建立openspec格式的修正任務"

# 方法 2: 手動執行腳本
./uitest-automation/analyze_uitest_failures.sh -d today
# 然後在 Claude Code 中: /add-dir ~/Downloads/UITestAnalysis
```

詳細說明請參考 [uitest-automation/README.md](./uitest-automation/README.md)

## 注意事項

- 這個 repo 的內容不會出現在主專案的 PR 中
- 只有使用 Claude Code 進行 AI 輔助開發的成員需要設定此 repo
- 不使用 AI 的開發者完全不需要理會這個 repo

## 相關連結

- 主專案: [iOSCharmander](https://github.com/VIVOTEK/iOSCharmander)
