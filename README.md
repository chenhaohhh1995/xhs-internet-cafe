# xhs-internet-cafe

小红书网吧探店内容创作 Skill —— 为泰坦军团（Titan Army）显示器品牌自动化生成探店文案与封面图。

**面向泰坦军团品牌内容运营人员**，将"飞书文档输入"到"飞书云文档交付"的完整创作流程封装为标准化 AI 流水线。全程中文交互，AI 自动引导配置。

---

## 安装（复制下面这段话发给你的 AI Agent）

**适用所有主流 AI 工具**：Claude Code / Codex / Gemini CLI / Copilot CLI

````text
帮我安装并配置 xhs-internet-cafe skill，仓库地址是 https://github.com/chenhaohhh1995/xhs-internet-cafe

安装完成后，引导我完成环境配置，然后教我怎么用它生成小红书探店内容。

安装步骤：
1. 先检查你当前运行在哪个 AI 工具平台（Claude Code / Codex / Gemini CLI / Copilot CLI / 其他），
   找到对应的 skills 目录（常见路径见下方参考表）
2. 如果 skills 目录下已有 xhs-internet-cafe，先删除旧版本
3. git clone 仓库到 skills 目录
4. 运行项目的环境自检脚本（scripts/setup-check.sh），检测系统和工具状态
5. 根据自检结果，逐项引导我配置缺失的工具和 API Key
   - 必配：GEMINI_API_KEY（Gemini API Key，用于生成文案）
   - 可选：OPENAI_API_KEY（GPT image 2 生封面图，没配则用即梦）
   - 可选：HTTPS_PROXY（代理，国内网络访问 API 需要）
6. 全部配置完成后，教我如何使用：
   - 飞书探店模板链接是 https://my.feishu.cn/wiki/BIwewPsqwi1FlykEORJc9Nisn0d?from=from_copylink
   - 使用方式是：在模板里填好网吧信息和封面底图，把飞书链接发给你，你会自动完成全部创作并打包回飞书文档

常用 AI 工具 skills 目录参考：
| 工具 | Skills 目录 |
|------|------------|
| Claude Code | ~/.claude/skills/ |
| Codex | ~/.codex/skills/ 或 ~/.openai/codex/skills/ |
| Gemini CLI | ~/.gemini/skills/ |
| GitHub Copilot CLI | ~/.copilot/skills/ |

如果无法确定当前工具，把仓库 clone 到 ~/xhs-internet-cafe 后问我应该放哪里。
````

复制上面这段话 → 打开你的 AI Agent 终端 → 粘贴发送 → AI 自动完成全部安装和配置（约 5 分钟）。

> 更多安装说明：[docs/INSTALL_PROMPT.md](docs/INSTALL_PROMPT.md) | 手动安装：[docs/INSTALL.md](docs/INSTALL.md)

---

## 你需要准备

| 必需 | 可选 |
|------|------|
| Gemini API Key | OpenAI API Key（封面图文字更精准） |
| 飞书账号 | 网络代理（国内访问 API 需要） |
| Git（克隆仓库用） | |

---

## 工作流

```
飞书文档（网吧信息 + 封面底图）
  → 产品调研 → 选题策划 → Gemini 双模型文案生成（4版）
  → 封面生成（GPT image 2 优先，即梦备选）
  → 飞书云文档打包交付
```

---

## 探店模板

飞书模板（复制后填入网吧信息即可使用）：
https://my.feishu.cn/wiki/BIwewPsqwi1FlykEORJc9Nisn0d?from=from_copylink

---

## 文档索引

| 文档 | 说明 |
|------|------|
| [docs/INSTALL_PROMPT.md](docs/INSTALL_PROMPT.md) | 一键安装提示词（推荐） |
| [docs/QUICKSTART.md](docs/QUICKSTART.md) | 5 分钟快速上手 |
| [docs/INSTALL.md](docs/INSTALL.md) | 手动安装指南 |
| [docs/USAGE.md](docs/USAGE.md) | 使用说明（引擎优先级、环境变量） |
| [SKILL.md](SKILL.md) | Skill 主文件，AI 执行入口 |
| [references/](references/) | 参考流程与配置说明 |
