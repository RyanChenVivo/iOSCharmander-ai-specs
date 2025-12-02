# iOSCharmander AI Specifications

這個 repository 包含 iOSCharmander 專案的 AI 輔助開發文件。

## 內容

- `/openspec/` - OpenSpec 規格和變更記錄
  - `AGENTS.md` - AI Agent 指引文件
  - `project.md` - 專案規格說明
  - `specs/` - 功能規格文件
  - `changes/` - 變更記錄和提案
- `/.claude/` - Claude Code 的設定和自定義指令

## 用途

這些文件用於 Claude Code 進行 AI 輔助開發,包含:
- 專案架構和規格文件
- 功能開發的規劃和追蹤
- AI Agent 的行為指引
- 自定義的 Claude Code 指令

## 使用方式

這個 repo 透過 symlink 連結到主專案,讓 Claude Code 可以存取這些檔案。

### 設定步驟

在主專案目錄執行:

```bash
# 方法一: 使用設定腳本(推薦)
./setup-ai-dev.sh

# 方法二: 手動設定
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander
ln -s ../iOSCharmander-ai-specs/openspec openspec
ln -s ../iOSCharmander-ai-specs/.claude .claude
```

### 日常使用

```bash
# 1. 使用 Claude Code 開發功能
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander
claude "實作新功能"

# 2. Commit 主專案的程式碼變更
git add iOSCharmander/
git commit -m "feat: add new feature"
git push

# 3. Commit AI 文件的變更
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs
git add .
git commit -m "docs: update specs for new feature"
git push
```

## 注意事項

- 這個 repo 的內容不會出現在主專案的 PR 中
- 只有使用 Claude Code 進行 AI 輔助開發的成員需要設定此 repo
- 不使用 AI 的開發者完全不需要理會這個 repo

## 相關連結

- 主專案: [iOSCharmander](https://github.com/VIVOTEK/iOSCharmander)
- 管理方案說明: 請參考主專案的 `AI_SPECS_MANAGEMENT_PROPOSAL.md`
