# ============================================================
# xhs-internet-cafe 环境自检脚本 (Windows PowerShell)
# 用法：.\setup-check.ps1
# ============================================================

$ErrorActionPreference = "Continue"

$Pass = 0
$Fail = 0
$Warn = 0

function Pass { Write-Host "  [PASS] $args" -ForegroundColor Green; $script:Pass++ }
function Fail { Write-Host "  [FAIL] $args" -ForegroundColor Red; $script:Fail++ }
function Warn { Write-Host "  [WARN] $args" -ForegroundColor Yellow; $script:Warn++ }

function Check-Cmd {
    param($Name, $Hint)
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Pass "$Name 已安装"
        return $true
    } else {
        Fail "$Name 未安装 — $Hint"
        return $false
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "  xhs-internet-cafe 环境自检"
Write-Host "=========================================="
Write-Host ""
Write-Host "检测到操作系统：Windows"
Write-Host "注意：推荐使用 Git Bash 运行本 Skill。仅 PowerShell 环境下部分功能可能受限。"
Write-Host ""

# 1. 基础工具
Write-Host "--- 基础工具 ---"
Check-Cmd "curl" "通常系统预装"
$hasBash = Check-Cmd "bash" "安装 Git Bash: https://git-scm.com"

if (-not $hasBash) {
    Warn "bash 不可用 — 强烈建议安装 Git Bash 后使用本 Skill"
}

# 2. Python
Write-Host ""
Write-Host "--- Python 环境 ---"
$python = $null
if (Get-Command "python3" -ErrorAction SilentlyContinue) { $python = "python3" }
elseif (Get-Command "python" -ErrorAction SilentlyContinue) { $python = "python" }

if ($python) {
    $ver = & $python --version 2>&1
    Pass "Python: $ver"
} else {
    Fail "Python 未安装 — 从 python.org 下载安装，勾选 'Add to PATH'"
}

if ($python) {
    $docxCheck = & $python -c "import docx; print(docx.__version__)" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Pass "python-docx: $docxCheck"
    } else {
        Fail "python-docx 未安装 — 运行: pip install python-docx"
    }
}

# 3. 飞书 CLI
Write-Host ""
Write-Host "--- 飞书 CLI ---"
Check-Cmd "lark-cli" "参考 docs/INSTALL.md 安装飞书 CLI"

# 4. 即梦 CLI（如 OPENAI_API_KEY 已设置则为可选）
Write-Host ""
Write-Host "--- 即梦 CLI ---"
$hasOpenAI = [Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "User")
if (-not $hasOpenAI) { $hasOpenAI = $env:OPENAI_API_KEY }
if (Get-Command "dreamina" -ErrorAction SilentlyContinue) {
    Pass "dreamina CLI 已安装"
} elseif ($hasOpenAI) {
    Warn "dreamina CLI 未安装 — 但 OPENAI_API_KEY 已设置，封面将使用 GPT image 2"
} else {
    Fail "dreamina CLI 未安装且 OPENAI_API_KEY 未设置 — 需要至少配置一种生图方式"
}

# 5. 环境变量
Write-Host ""
Write-Host "--- 环境变量 ---"
$geminiKey = [Environment]::GetEnvironmentVariable("GEMINI_API_KEY", "User")
if (-not $geminiKey) { $geminiKey = $env:GEMINI_API_KEY }
if ($geminiKey) {
    Pass "GEMINI_API_KEY 已设置"
} else {
    Fail "GEMINI_API_KEY 未设置 — 在系统环境变量中添加 GEMINI_API_KEY"
}

$openaiKey = [Environment]::GetEnvironmentVariable("OPENAI_API_KEY", "User")
if (-not $openaiKey) { $openaiKey = $env:OPENAI_API_KEY }
if ($openaiKey) {
    Pass "OPENAI_API_KEY 已设置 → 封面优先使用 GPT image 2"
} else {
    Warn "OPENAI_API_KEY 未设置 → 封面将使用 dreamina（如已安装）"
}

$proxy = [Environment]::GetEnvironmentVariable("HTTPS_PROXY", "User")
if (-not $proxy) { $proxy = $env:HTTPS_PROXY }
if ($proxy) {
    Pass "HTTPS_PROXY 已设置: $proxy"
} else {
    Warn "HTTPS_PROXY 未设置 — 如果在中国大陆网络环境，可能需要设置代理"
}

# 6. 汇总
Write-Host ""
Write-Host "=========================================="
if ($Fail -eq 0) {
    Write-Host "  全部通过！($Pass 项通过, $Warn 项提醒)" -ForegroundColor Green
    Write-Host "=========================================="
    exit 0
} else {
    Write-Host "  $Fail 项未通过，请根据上方提示修复后重试" -ForegroundColor Red
    Write-Host "=========================================="
    exit 1
}
