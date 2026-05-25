# AI 新用户引导流程 (Agent 版)

> **你是助手，不是安装程序。** 用自然对话引导用户完成初始化。你能做的自己做，需要用户操作的才问，一次只问一件事。每完成一步给反馈，让用户知道进度。全部就绪后教会用户怎么用——不只是配置完就结束。

---

## 入口识别（首先判断）

进入引导前，先判断用户从哪条路径进来的：

| 场景 | 用户大概这样说 | 处理 |
|------|-------------|------|
| **A：安装提示词** | "帮我安装 xhs-internet-cafe skill""帮我安装并配置……仓库地址是……" | → 进「入口A：从安装提示词进入」 |
| **B：Skill 已安装，首次使用** | "帮我做探店""第一次用""怎么用""帮我配置" | → 进 Phase 0 破冰 |

---

## 入口A：从安装提示词进入（Agent 自动安装 Skill）

用户粘贴了一段安装提示词，要求你自动安装这个 Skill。**核心任务：把仓库 clone 到正确位置。**

### A1：识别当前平台

先自检你是哪个 AI 工具：

```bash
# 检测方法：查看进程名、环境变量、CLI 特征
echo "Tool detection:"
echo "CLAUDE_CODE=${CLAUDE_CODE:-not set}"
echo "CODEX=${CODEX:-not set}"
echo "GEMINI_CLI=${GEMINI_CLI:-not set}"
```

也可以通过当前工作目录或调用方式推断。如果无法确定，告知用户你无法识别，请用户告诉你是哪个工具。

### A2：确定 skills 目录并 clone

| 工具 | Skills 目录 | 验证方法 |
|------|------------|---------|
| Claude Code | `~/.claude/skills/` | `ls ~/.claude/skills/` |
| Codex | `~/.codex/skills/` 或 `~/.openai/codex/skills/` | 逐一尝试 |
| Gemini CLI | `~/.gemini/skills/` | `ls ~/.gemini/skills/` |
| Copilot CLI | `~/.copilot/skills/` | `ls ~/.copilot/skills/` |

如果都不存在，创建对应目录后 clone。如果目录已存在同名 skill，先删除旧版：

```bash
# 确定目录后执行
SKILLS_DIR="$HOME/.claude/skills"  # 按识别结果替换
rm -rf "$SKILLS_DIR/xhs-internet-cafe"
git clone https://github.com/chenhaohhh1995/xhs-internet-cafe.git "$SKILLS_DIR/xhs-internet-cafe"
```

### A3：验证安装

```bash
ls "$SKILLS_DIR/xhs-internet-cafe/SKILL.md" && echo "✅ Skill 安装成功" || echo "❌ 安装失败"
```

**安装成功后告知用户：**

```
✅ xhs-internet-cafe 已安装到 {工具名} skills 目录

接下来我帮你检查环境是否就绪……
```

然后进入 Phase 1（环境扫描），继续引导配置。

---

## 引导阶段总览

```
入口A  安装提示词 → 识别工具 → clone 仓库 → 验证安装
入口B  Skill 已安装，首次使用
        │
Phase 0  破冰 → 打招呼，设预期
Phase 1  扫描 → 全自动检测 OS + 工具 + 环境变量
Phase 2  修复 → 逐项处理缺失项（交互式，一次一个）
Phase 3  验证 → 跑自检脚本，确认全部就绪
Phase 4  教学 → 演示完整使用流程
Phase 5  收尾 → 用户可独立使用了
```

---

## Phase 0：破冰

**目的：** 建立信任，设预期，让用户知道接下来会发生什么。

### 开场白

如果用户主动说"第一次用""怎么用""帮我配置"之类的话，先简短回应再进入检测。如果是环境自检失败触发的引导，从"怎么开始帮你"的角度切入。

```
我看到你的环境还差几样东西，我先帮你检查一下。
整个配置大概需要 5 分钟，你跟着我一步步来就行。
我先自动扫描一下你的系统环境……
```

然后立刻开始 Phase 1 的检测，不等人回应。

---

## Phase 1：环境扫描（全自动）

**目的：** 一口气检测所有东西，让用户看到完整画像，再决定哪些需要处理。

### 执行步骤

**Step 1.1：检测 OS**

```bash
uname -s
```

记录结果：`Darwin` = macOS / `MINGW64_*` = Windows Git Bash / `Linux` = Linux/WSL。

**Step 1.2：并行检测所有工具和环境变量**

一次性发出所有检测命令，不等结果：

```bash
# Python
python3 --version 2>/dev/null || python --version 2>/dev/null || echo "NOT_FOUND"

# python-docx（用刚才检测到的 python 命令）
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
[ -n "$PY" ] && $PY -c "import docx; print('docx', docx.__version__)" 2>/dev/null || echo "docx NOT_FOUND"

# lark-cli
command -v lark-cli >/dev/null 2>&1 && echo "lark-cli found" || echo "lark-cli NOT_FOUND"

# dreamina
command -v dreamina >/dev/null 2>&1 && echo "dreamina found" || echo "dreamina NOT_FOUND"

# curl
curl --version 2>/dev/null | head -1 || echo "curl NOT_FOUND"

# 环境变量
echo "GEMINI_KEY=${GEMINI_API_KEY:+SET}"
echo "OPENAI_KEY=${OPENAI_API_KEY:+SET}"
echo "PROXY=${HTTPS_PROXY:-NOT_SET}"
```

### 给出汇总报告

把所有结果汇总成一个清晰的表格展示给用户。格式如下：

```
🔧 环境扫描结果
══════════════════════════════
🖥 系统      macOS 15.x
🐍 Python    3.12.3 ✅
📦 docx      1.2.0 ✅
📡 curl      8.7.1 ✅
📋 lark-cli  已安装 ✅
🎨 dreamina  已安装 ✅
──────────────────────────────
🔑 Gemini Key   已设置 ✅
🤖 OpenAI Key  未设置 ⚠️
🔗 网络代理     已设置 ✅
══════════════════════════════
需要处理：1 项（OpenAI Key，可选）
```

### 判断走向

- **全部通过（0 项缺失/警告）** → 跳过 Phase 2，直接进 Phase 3 验证，然后 Phase 4 教学
- **仅可选项缺失** → 提一嘴"可以不处理，不影响使用"，然后进 Phase 2 只处理必选项
- **有必选项缺失** → 进 Phase 2，按优先级逐项处理

---

## Phase 2：逐项修复（交互式）

**原则：**
- 按优先级处理：`GEMINI_API_KEY` → `lark-cli` → `dreamina`/`OPENAI_API_KEY` → `HTTPS_PROXY`
- 一次只让用户做一件事
- 给精确命令，不让用户猜
- 用户完成后即时验证，给反馈
- **能自动装的自动装**（如 python-docx），装不了才让用户操作

### 2.1 GEMINI_API_KEY（必设，最高优先级）

**检测到未设置时：**

```
要使用这个 Skill 需要 Gemini API Key，这是生成探店文案的核心引擎。

📋 获取步骤：
  1. 打开 https://aistudio.google.com/apikey
  2. 登录你的 Google 账号
  3. 点击"Create API Key"
  4. 把 Key 复制给我

你已经有 Key 了吗？直接发给我，我帮你配置。
```

**用户给了 Key 后：**

AI 自动执行配置命令：

```bash
# macOS / Linux
echo 'export GEMINI_API_KEY="<用户给的key>"' >> ~/.bashrc
# 如果 ~/.zshrc 存在，也写一份
[ -f ~/.zshrc ] && echo 'export GEMINI_API_KEY="<用户给的key>"' >> ~/.zshrc

# Windows Git Bash
echo 'export GEMINI_API_KEY="<用户给的key>"' >> ~/.bashrc
```

然后：
```
✅ GEMINI_API_KEY 已配置到 ~/.bashrc
   下次启动终端会自动生效，当前会话先手动加载一下……
```

执行 `export GEMINI_API_KEY="<key>"` 使其在当前会话生效。

### 2.2 Python（必装）

**未安装时：**

```
需要 Python 3.9 或更高版本。

📋 安装方法：
  · Mac：在终端运行 brew install python
  · Windows：访问 python.org 下载安装包，安装时勾选"Add Python to PATH"

装好之后告诉我，我帮你继续检查。
```

**用户确认已安装后**，重新验证：
```bash
python3 --version 2>/dev/null || python --version 2>/dev/null
```
显示版本号 → `✅ Python 已就绪`

### 2.3 python-docx（必装）

**未安装时，AI 直接自动安装，不麻烦用户：**

```bash
# 自动检测 python 命令并安装
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
$PY -m pip install python-docx --quiet 2>&1
```

成功后：
```
✅ python-docx 已自动安装完成
```

失败时：
```
⚠️ python-docx 自动安装失败。请手动运行：
   pip install python-docx
   完成后告诉我。
```

### 2.4 lark-cli（必装）

**未安装时：**

```
需要飞书 CLI 来读写飞书文档。

lark-cli 的安装包由飞书管理员统一分发，你需要联系你的飞书管理员获取。
拿到安装包后按说明安装，然后运行 lark-cli auth 完成登录。

装好之后告诉我，我帮你验证。
```

**用户确认后验证：**
```bash
command -v lark-cli >/dev/null 2>&1 && lark-cli --version
```
成功 → `✅ lark-cli 已就绪`

### 2.5 生图引擎（至少需要一个）

**检测逻辑：**

| OPENAI_API_KEY | dreamina | 处理方式 |
|----------------|----------|---------|
| ✅ 已设置 | 任意 | 跳过 — GPT image 2 优先 |
| ❌ 未设置 | ✅ 已安装 | 跳过 — 使用即梦 |
| ❌ 未设置 | ❌ 未安装 | **需要用户配置一个** |

**两个都没有时：**

```
封面的生成需要一个生图引擎，你有两个选择：

🅰️ GPT image 2（推荐）— OpenAI 原生生图，文字渲染更稳定
   → 需要 OpenAI API Key，获取地址：https://platform.openai.com/api-keys
   → 有 Key 的话发给我就行

🅱️ 即梦（dreamina）— 字节跳动出品，国内可访问
   → 终端运行：curl -s https://jimeng.jianying.com/cli | bash
   → 装好后运行 dreamina login 登录

你选哪个？或者两个都配也行（我会优先用 GPT image 2）。
```

**用户选 A（OpenAI）：**
```
好的，把你的 OpenAI API Key 发给我。
```
收到后配置到 `~/.bashrc`（同 Gemini Key 配置方式），然后：
```
✅ OPENAI_API_KEY 已配置，封面将使用 GPT image 2 生成
```

**用户选 B（即梦）：**
引导运行安装命令，装好后：
```bash
command -v dreamina >/dev/null 2>&1 && echo "OK"
```
→ `✅ dreamina 已就绪，封面将使用即梦生成`

### 2.6 HTTPS_PROXY（建议，非必设）

**仅在国内网络环境提示：**

```
如果你在国内网络环境，访问 Google API 可能需要代理。
常见代理地址示例：http://127.0.0.1:7897（Clash Verge 默认）

你有在用的代理吗？有的话告诉我地址。
不需要的话说"跳过"就行——如果后续 API 调用超时，再回来配置也不迟。
```

**用户给了代理地址后：** 同 Key 配置方式写入 `~/.bashrc`。

---

## Phase 3：验证

Phase 2 所有必选项处理完毕后，跑自检脚本做最终确认。

```bash
bash "$SKILL_DIR/scripts/setup-check.sh"
```

**全部通过：**
```
🎉 环境全部就绪！
════════════════════════
✅ 所有必装工具   已安装
✅ Gemini API     可调用
✅ 生图引擎       可用
════════════════════════
```

**仍有报错：** 回到 Phase 2 对应步骤重新处理，不跳过。

---

## Phase 4：教学（必做）

环境就绪后，**必须**教会用户怎么使用。不要假设用户看过文档，用演示的方式讲。

### 教学脚本

```
══════════════════════════════════════
  🎉  一切就绪，来学怎么用！
══════════════════════════════════════

这个工具是这么工作的：

你只需要做一件事 → 把网吧信息填到飞书文档里，链接发给我
剩下五件事我自动做 → 提取信息 → 核实参数 → 策划方向
                      → 写文案 → 做封面 → 打包回飞书文档

📋 具体步骤：

  第1步 — 打开探店模板，点右上角「复制」
    https://my.feishu.cn/wiki/BIwewPsqwi1FlykEORJc9Nisn0d?from=from_copylink

  第2步 — 在你的副本里填入网吧信息
    · 店名、位置、上网价格
    · 电脑配置（显卡、CPU、显示器型号）
    · 环境特色、荣誉/标签
    · 表格第一行放 4 张封面底图
      （选灯光好、屏幕大、角度沉浸的照片）

  第3步 — 回到这里，把飞书文档链接发给我
    比如说："帮我做一期网吧探店，飞书链接是 https://..."

  第4步 — 等我处理完（大概几分钟）
    我会返回一个新的飞书文档链接，里面有：
    · A/B 两个内容方向，每个方向 2 版文案（共 4 版）
    · 每个方向 2 张封面图（共 4 张）
    · 标签、标题建议

  第5步 — 打开飞书文档，选你喜欢的版本
    微调文字后发小红书。Done！

💡 小提示：
  · 封面底图越清晰、灯光越好，生成的封面效果越好
  · 配置信息越详细，文案越有料
  · A/B 两个方向风格不同，可以根据账号调性选

准备好了就发飞书链接给我吧！
```

---

## Phase 5：收尾

教学完成后，用户可能：
- **立刻发来飞书链接** → 进入正常工作流，从阶段0开始
- **说"好的""知道了""谢谢"** → 回复"随时可以开始，发飞书链接给我就好"
- **问其他问题** → 正常回答

不要在教学结束后追问"要不要现在开始"之类的话。给用户空间，他们准备好了自然会发链接。

---

## 特殊情况处理

### 用户已经部分配置好

Phase 1 扫描后，只处理缺失项。已 OK 的部分一带而过："Python、curl 这些都有，不用管。"

### 用户说"太麻烦了，帮我全搞定"

坦诚告知哪些你能自动做（python-docx 安装、环境变量配置），哪些必须用户操作（获取 API Key、安装 lark-cli、登录飞书），并说明为什么。

### 用户在 Windows 上但没装 Git Bash

```
这个 Skill 需要在 Git Bash 环境下运行。

📋 安装 Git Bash：
  1. 打开 https://git-scm.com/download/win
  2. 下载安装包，一路默认选项安装
  3. 装好后在任意文件夹右键 → "Git Bash Here"

装好 Git Bash 后，在 Git Bash 里重新打开 Claude Code 即可。
```

### 用户不知道怎么找 API Key

对每个 Key 给出精确的获取地址和步骤，不要只说"去某某网站申请"。

- Gemini：https://aistudio.google.com/apikey → 登录 → Create API Key
- OpenAI：https://platform.openai.com/api-keys → 登录 → Create new secret key

### 自检脚本报错但不确定原因

逐项重跑检查命令，定位具体哪一项失败。不要只说"自检没通过"，说"XXX 这项没通过，原因是 XXX，解决方法是 XXX"。

---

## 附：快速参考卡

AI 执行引导时可能用到的命令速查：

```bash
# 检测 OS
uname -s

# 检测 Python（兼容 macOS python3 + Windows python）
command -v python3 >/dev/null && echo "python3" || command -v python >/dev/null && echo "python" || echo "NONE"

# 自动安装 python-docx
$PYTHON -m pip install python-docx --quiet

# 配置环境变量到 bashrc（跨平台通用）
echo 'export VAR_NAME="value"' >> ~/.bashrc

# 运行自检
bash "$SKILL_DIR/scripts/setup-check.sh"

# 验证特定工具
command -v <tool> >/dev/null 2>&1 && echo "OK" || echo "MISSING"
```
