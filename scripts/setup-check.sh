#!/usr/bin/env bash
# ============================================================
# xhs-internet-cafe 环境自检脚本
# 支持：macOS / Linux / Windows Git Bash / WSL
# 用法：bash setup-check.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

header() {
  echo ""
  echo "=========================================="
  echo "  xhs-internet-cafe 环境自检"
  echo "=========================================="
  echo ""
}

check_os() {
  local os
  os=$(uname -s 2>/dev/null || echo "Unknown")
  case "$os" in
    Darwin)  echo "macOS" ;;
    MINGW64_*|MSYS_*|CYGWIN_*) echo "Windows (Git Bash)" ;;
    Linux)   echo "Linux / WSL" ;;
    *)       echo "Unknown ($os)" ;;
  esac
}

pass() {
  echo -e "  [${GREEN}PASS${NC}] $1"
  PASS=$((PASS + 1))
}

fail() {
  echo -e "  [${RED}FAIL${NC}] $1"
  FAIL=$((FAIL + 1))
}

warn() {
  echo -e "  [${YELLOW}WARN${NC}] $1"
  WARN=$((WARN + 1))
}

check_cmd() {
  if command -v "$1" &> /dev/null; then
    pass "$1 已安装"
    return 0
  else
    fail "$1 未安装 — $2"
    return 1
  fi
}

# --- Main ---
header

echo "检测到操作系统：$(check_os)"
echo ""

# 1. 基础工具
echo "--- 基础工具 ---"
check_cmd "curl"  "通常系统预装，如缺失请通过包管理器安装"
check_cmd "bash"  "系统必需，不应缺失"

# 2. Python
echo ""
echo "--- Python 环境 ---"
PYTHON=""
if command -v python3 &> /dev/null; then
  PYTHON="python3"
elif command -v python &> /dev/null; then
  PYTHON="python"
fi

if [ -n "$PYTHON" ]; then
  PY_VER=$($PYTHON --version 2>&1)
  pass "Python: $PY_VER"
else
  fail "Python 未安装 — Mac: brew install python | Windows: python.org 下载"
fi

if [ -n "$PYTHON" ]; then
  if $PYTHON -c "import docx" 2>/dev/null; then
    DOCX_VER=$($PYTHON -c "import docx; print(docx.__version__)" 2>/dev/null)
    pass "python-docx: $DOCX_VER"
  else
    fail "python-docx 未安装 — 运行: pip install python-docx"
  fi
fi

# 3. 飞书 CLI
echo ""
echo "--- 飞书 CLI ---"
check_cmd "lark-cli" "参考 docs/INSTALL.md 安装飞书 CLI"

# 4. 即梦 CLI
echo ""
echo "--- 即梦 CLI ---"
if command -v dreamina &> /dev/null; then
  pass "dreamina CLI 已安装"
else
  fail "dreamina CLI 未安装 — 运行: curl -s https://jimeng.jianying.com/cli | bash"
fi

# 5. 环境变量
echo ""
echo "--- 环境变量 ---"
if [ -n "$GEMINI_API_KEY" ]; then
  pass "GEMINI_API_KEY 已设置"
else
  fail "GEMINI_API_KEY 未设置 — 在 ~/.bashrc 或 ~/.zshrc 中添加: export GEMINI_API_KEY=\"your-key\""
fi

if [ -n "$HTTPS_PROXY" ]; then
  pass "HTTPS_PROXY 已设置: $HTTPS_PROXY"
else
  warn "HTTPS_PROXY 未设置 — 如果在中国大陆网络环境，可能需要设置代理"
fi

# 6. 工作目录
echo ""
echo "--- 工作目录 ---"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -d "$SKILL_DIR" ]; then
  pass "Skill 目录: $SKILL_DIR"
else
  fail "Skill 目录不存在"
fi

# 7. 汇总
echo ""
echo "=========================================="
PASS_TOTAL=$((PASS + WARN))
if [ $FAIL -eq 0 ]; then
  echo -e "  ${GREEN}全部通过！${NC} ($PASS 项通过, $WARN 项提醒)"
  echo "=========================================="
  exit 0
else
  echo -e "  ${RED}$FAIL 项未通过${NC}，请根据上方提示修复后重试"
  echo "=========================================="
  exit 1
fi
