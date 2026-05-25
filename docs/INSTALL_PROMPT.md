# AI Agent 安装提示词

将下面的提示词复制到你的 AI Agent 终端（Claude Code、Codex、Gemini CLI、Copilot CLI 等均可），AI 会自动完成安装、配置和教学引导。

---

## 一键安装（推荐）

复制以下内容，粘贴到你的 AI Agent 对话中：

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

---

## 如果 AI 没有自动识别工具

可以指定工具名称再试一次。比如用 Claude Code：

````text
我在用 Claude Code，帮我安装 xhs-internet-cafe skill
仓库：https://github.com/chenhaohhh1995/xhs-internet-cafe
装好后帮我配环境并教我怎么用。
````

用 Codex：

````text
我在用 Codex，帮我安装 xhs-internet-cafe skill
仓库：https://github.com/chenhaohhh1995/xhs-internet-cafe
装好后帮我配环境并教我怎么用。
````

---

## 工作原理

提示词会让 AI Agent 执行以下流程：

```
① 识别当前工具平台
     │
② clone 仓库到对应 skills 目录
     │
③ 运行 setup-check.sh 环境自检
     │
④ 逐项引导配置缺失项
   · GEMINI_API_KEY（必配）
   · lark-cli + dreamina / OPENAI_API_KEY
   · HTTPS_PROXY（可选）
     │
⑤ 全部就绪 → 教学演示
   · 飞书模板怎么填
   · 发链接后 AI 自动做什么
   · 怎么查看交付结果
     │
⑥ ✅ 可以开始用了
```

整个过程约 5 分钟，用户只需要跟着 AI 的引导操作。
