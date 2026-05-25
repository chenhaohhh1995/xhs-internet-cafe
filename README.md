# xhs-internet-cafe

小红书网吧探店内容创作 Skill —— 为泰坦军团（Titan Army）显示器品牌自动化生成探店文案与封面图。

**面向泰坦军团品牌内容运营人员**，将"飞书文档输入"到"飞书云文档交付"的完整创作流程封装为标准化 AI 流水线。首次使用时 AI 自动引导完成环境配置，全程中文交互。

---

## 安装

```bash
# 克隆仓库到 Claude Code skills 目录
git clone https://github.com/chenhaohhh1995/xhs-internet-cafe.git ~/.claude/skills/xhs-internet-cafe
```

安装后，在 Claude Code 中发任意消息即可触发环境引导。AI 会自动检测系统环境、指导配置必装工具和 API Key，约 5 分钟完成全部配置。

详细安装步骤：[docs/INSTALL.md](docs/INSTALL.md) | 快速上手：[docs/QUICKSTART.md](docs/QUICKSTART.md)

---

## 你需要准备

| 必需 | 可选 |
|------|------|
| Gemini API Key | OpenAI API Key（封面优先用 GPT image 2） |
| 飞书账号 | 网络代理（国内访问 API 需要） |

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
| [SKILL.md](SKILL.md) | Skill 主文件，AI Agent 执行入口 |
| [docs/INSTALL.md](docs/INSTALL.md) | 新机环境安装指南 |
| [docs/QUICKSTART.md](docs/QUICKSTART.md) | 5 分钟快速上手 |
| [docs/USAGE.md](docs/USAGE.md) | 使用说明（生图引擎优先级、环境变量） |
| [references/](references/) | 参考流程与配置说明 |
| [templates/](templates/) | 文案与封面模板 |
