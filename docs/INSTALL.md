# xhs-internet-cafe 安装指南

新机从零到跑通全流程的环境搭建清单。按序号逐项完成即可。

---

## 1. 前置准备

- 一台可联网的电脑（macOS 或 Windows）
- 飞书账号（具备云文档读写权限）
- Gemini API Key（向管理员申请或前往 [Google AI Studio](https://aistudio.google.com/apikey) 创建）

---

## 2. 安装 Git Bash（仅 Windows）

macOS 和 Linux 自带 bash，跳过此步。

1. 访问 [git-scm.com](https://git-scm.com/download/win) 下载安装包
2. 运行安装程序，全部使用默认选项一路 Next
3. 安装完成后，在任意文件夹右键选择 "Git Bash Here" 验证能打开终端

---

## 3. 安装 Python 3.9+

**macOS：**

```bash
brew install python
```

**Windows：**

1. 访问 [python.org](https://www.python.org/downloads/) 下载安装包
2. 运行安装程序，**勾选 "Add Python to PATH"**（重要）
3. 完成后打开 Git Bash，验证：

```bash
python --version
# 应输出 Python 3.9.x 或更高
```

---

## 4. 安装 python-docx

```bash
# macOS
pip3 install python-docx

# Windows（在 Git Bash 中执行）
pip install python-docx
```

验证安装：

```bash
python -c "import docx; print(docx.__version__)"
```

---

## 5. 安装飞书 CLI（lark-cli）

> 飞书 CLI 安装包由飞书管理员统一分发，请联系你的飞书管理员获取。

获取安装包后按管理员提供的说明完成安装。安装完成后执行 OAuth 认证：

```bash
lark-cli auth
```

按浏览器弹窗提示完成授权。验证安装：

```bash
lark-cli --version
```

---

## 6. 安装即梦 CLI（dreamina）

在终端中执行：

```bash
curl -s https://jimeng.jianying.com/cli | bash
```

安装完成后登录：

```bash
dreamina login
```

按浏览器弹窗提示完成 OAuth 授权。验证安装：

```bash
dreamina --version
```

---

## 7. 配置环境变量

**macOS：** 编辑 `~/.zshrc`（或 `~/.bashrc`），在文件末尾添加：

```bash
export GEMINI_API_KEY="your-gemini-api-key"

# 如果在中国大陆网络环境需要代理，取消下面这行的注释并修改地址
# export HTTPS_PROXY="http://127.0.0.1:7897"
```

保存后执行 `source ~/.zshrc` 使其生效。

**Windows：** 两种方式任选其一：

- **方式 A（推荐）：** 编辑 Git Bash 的 `~/.bashrc`，添加同上内容，保存后执行 `source ~/.bashrc`
- **方式 B：** 在系统环境变量中添加 `GEMINI_API_KEY`（控制面板 → 系统 → 高级系统设置 → 环境变量）

> 将 `your-gemini-api-key` 替换为你在第 1 步获取的实际 Key。

---

## 8. 安装 Skill

**方式 A：npx（推荐）**

```bash
npx skills add <github-repo-url>
```

**方式 B：手动复制**

将整个 `xhs-internet-cafe` 文件夹复制到 Claude Code 的 skills 目录：

```bash
cp -r xhs-internet-cafe ~/.claude/skills/
```

---

## 9. 验证安装

运行环境自检脚本：

```bash
bash ~/.claude/skills/xhs-internet-cafe/scripts/setup-check.sh
```

所有检查项应显示绿色 `[PASS]`。如有红色 `[FAIL]`，按提示修复后重新运行。全部通过后即可开始使用，参考 [QUICKSTART.md](QUICKSTART.md) 进入快速上手流程。
