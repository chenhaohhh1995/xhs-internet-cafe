# AI 新用户引导流程

> **AI Agent 专用。** 当检测到用户是首次使用本 Skill（环境未配置或 setup-check 未通过）时，按此流程引导用户完成初始化。

---

## 引导原则

- **你能自动完成的，不要问用户。** 检测 OS、检查工具版本、验证环境变量——这些都你来做，做完告诉用户结果。
- **需要用户操作的，一次说清楚。** 安装软件、填 API Key——给出精确命令，不让人猜。
- **每完成一步给反馈。** 不要让用户对着终端发呆。
- **全部就绪后教一遍用法。** 不假设用户看过文档。

---

## 第一步：打招呼 + 说明要做什么

```
👋 你好！我是小红书探店内容创作助手。

检测到这是第一次使用，我先帮你把环境配好。
大概需要 5 分钟，你跟着我一步步来就行。
```

然后立刻开始检测，不等人回应。

---

## 第二步：自动检测 OS

```bash
uname -s
```

根据结果告知用户：

| 结果 | 输出 |
|------|------|
| Darwin | `✅ 检测到 macOS` |
| MINGW64_* / MSYS_* | `✅ 检测到 Windows (Git Bash)` |
| Linux | `✅ 检测到 Linux / WSL` |

---

## 第三步：逐项检查工具，给出安装命令

按以下清单逐项检查。**每检查一项就给一次反馈**，不要攒到最后。

### 3.1 Git Bash（仅 Windows）

```
如果在 Windows 上：
  检测 bash 是否可用 → which bash
  ❌ 未检测到 → 告诉用户：
    "需要安装 Git Bash，下载链接：https://git-scm.com
     安装时一路默认选项就行。装好后重新打开这个终端。"
  ✅ 已安装 → 继续
```

### 3.2 Python

```bash
python3 --version 2>/dev/null || python --version 2>/dev/null
```

- ✅ 成功 → `Python 3.x ✅`
- ❌ 失败 →
  - Mac：`需要安装 Python。在终端运行：brew install python`
  - Windows：`需要安装 Python。下载地址：https://python.org 安装时勾选 "Add to PATH"`

### 3.3 python-docx

```bash
python3 -c "import docx" 2>/dev/null || python -c "import docx" 2>/dev/null
```

- ❌ 失败 → 自动执行 `pip3 install python-docx` 或 `pip install python-docx`，告诉用户正在安装

### 3.4 lark-cli

```bash
which lark-cli 2>/dev/null || where lark-cli 2>/dev/null
```

- ❌ 未检测到 → `需要安装飞书 CLI。请联系你的飞书管理员获取安装包。安装后运行 lark-cli 完成登录认证。`
- ⚠️ lark-cli 是非标准工具，没有公开安装链接。引导用户联系管理员即可。

### 3.5 curl

```bash
curl --version 2>/dev/null
```

- ❌ 通常不会缺。缺了就告知系统包管理器安装命令。

### 3.6 生图引擎（GPT image 2 或 dreamina）

```bash
# 检查 OPENAI_API_KEY
echo "$OPENAI_API_KEY"

# 检查 dreamina
which dreamina 2>/dev/null
```

告知逻辑：

| OPENAI_API_KEY | dreamina | 输出 |
|----------------|----------|------|
| ✅ 已设置 | 任意 | `✅ GPT image 2 可用 → 封面生成使用 OpenAI（文字渲染更稳定）` |
| ❌ 未设置 | ✅ 已安装 | `✅ dreamina 已安装 → 封面生成使用即梦。如需使用 GPT image 2，设置 OPENAI_API_KEY 即可` |
| ❌ 未设置 | ❌ 未安装 | `⚠️ 需要至少配置一种封面生成方式。推荐 GPT image 2（设置 OPENAI_API_KEY），或安装 dreamina（curl -s https://jimeng.jianying.com/cli \| bash）` |

**如用户选择 dreamina：** 提醒首次使用需要 `dreamina login` 浏览器授权。

---

## 第四步：配置环境变量

### GEMINI_API_KEY（必设）

```
检查：echo "$GEMINI_API_KEY"

❌ 未设置 →
  "需要 Gemini API Key 来生成文案。获取方式：
   1. 打开 https://aistudio.google.com/apikey
   2. 创建 API Key
   3. 把 Key 告诉我，我帮你配置"

用户给了 Key 后：
  Mac: 帮用户添加到 ~/.zshrc
  Windows: 帮用户添加到 ~/.bashrc 或系统环境变量
  执行 source ~/.zshrc 或对应文件
  ✅ GEMINI_API_KEY 配置完成
```

### OPENAI_API_KEY（可选，但有的话更好）

```
检查：echo "$OPENAI_API_KEY"

❌ 未设置 →
  "（可选）如果有 OpenAI API Key，封面图质量会更好。
   获取方式：https://platform.openai.com/api-keys
   如果不需要，跳过即可，封面会用即梦生成。"

用户给了 Key → 同上配置方式
用户跳过 → "好的，封面将使用即梦生成。"
```

### HTTPS_PROXY（建议）

```
检查：echo "$HTTPS_PROXY"

❌ 未设置 →
  "你在国内网络环境吗？如果是，需要配置代理才能访问 API。
   代理地址通常是 http://127.0.0.1:7897（Clash Verge 默认）
   你有在用的代理吗？有的话告诉我地址，我帮你配置。"

用户给了代理地址 → 同上配置方式
用户说不需要 → "好的。如果后续 API 调用超时，可能需要回来配置代理。"
```

---

## 第五步：运行自检

全部配置完成后：

```bash
bash "$SKILL_DIR/scripts/setup-check.sh"
```

输出结果展示给用户：
- 全部通过 → `🎉 环境全部就绪！`
- 仍有报错 → 回到对应步骤重新处理

---

## 第六步：教用户使用（必做）

环境就绪后，**必须**向用户说明使用方法。格式如下：

```
🎉 环境全部就绪！接下来教你怎么用。

📋 使用方式：

1. 打开飞书，复制探店模板：
   https://my.feishu.cn/wiki/BIwewPsqwi1FlykEORJc9Nisn0d?from=from_copylink

2. 在模板里填入网吧信息（店名、位置、配置、特色）
   表格第一行放 4 张封面底图

3. 回到这里，把飞书文档链接发给我，说：
   "帮我做一期网吧探店，飞书链接是 xxx"

4. 我会自动完成：
   · 提取信息 → 核实产品参数
   · 策划 A/B 两个内容方向
   · Gemini 生成 4 版文案
   · 生成 4 张封面图
   · 打包成飞书文档给你

5. 你打开飞书文档，选喜欢的版本，微调文字，发小红书。

⏱️ 全程你只需要填模板 + 发链接，耗时不超过 3 分钟。
   AI 处理大概几分钟，好了会给你飞书文档链接。

有问题随时说。准备好了就发飞书链接给我吧！
```

---

## 附：检测脚本（给 AI 自己跑）

不用每次手敲命令。执行以下脚本即可一键检测所有项：

```bash
bash "$SKILL_DIR/scripts/setup-check.sh"
```

根据退出码判断：`0` = 全部就绪，`非0` = 有未通过项。解析输出后按本流程引导修复。
