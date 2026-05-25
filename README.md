# xhs-internet-cafe

小红书网吧探店内容创作 Skill -- 为泰坦军团 (Titan Army) 显示器品牌自动化生成小红书探店文案与封面图。

面向泰坦军团品牌内容运营人员，将"飞书文档输入"到"飞书云文档交付"的完整创作流程封装为标准化 AI 流水线。

## 快速安装

```bash
# 方式一：通过 npx（推荐）
npx skills add <github-repo-url>

# 方式二：手动复制
cp -r xhs-internet-cafe ~/.claude/skills/
```

详细安装步骤与环境配置请参阅 [docs/INSTALL.md](docs/INSTALL.md)，快速上手指南请参阅 [docs/QUICKSTART.md](docs/QUICKSTART.md)。

## 运行要求

`macOS / Windows` | `Python >=3.9` | `Gemini API` | `飞书 (Feishu)` | `封面: GPT image 2 / 即梦 (自动检测)`

## 工作流

```
飞书文档（网吧信息 + 封面底图）
  → 产品调研 → 选题策划 → Gemini 文案生成
  → 封面生成（GPT image 2 优先，即梦备选）
  → 飞书云文档打包交付
```

## 文档索引

| 文档 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | Skill 主文件，AI Agent 执行入口 |
| [docs/INSTALL.md](docs/INSTALL.md) | 新机环境安装指南 |
| [docs/QUICKSTART.md](docs/QUICKSTART.md) | 5 分钟快速上手 |
| [docs/USAGE.md](docs/USAGE.md) | 使用说明（生图引擎优先级、环境变量） |
| [references/](references/) | 参考流程与配置说明 |
| [templates/](templates/) | 文案与封面模板 |
