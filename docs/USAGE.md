# 使用说明

## 封面生图引擎

本 Skill 支持两种封面生成引擎，**AI 自动检测选择，无需手动切换**。

### 优先级

| 优先级 | 引擎 | 需要什么 | 优势 |
|--------|------|---------|------|
| **首选** | GPT image 2 | `OPENAI_API_KEY` 环境变量 | 中文文字渲染精度高，无需额外安装 CLI |
| **备选** | 即梦 dreamina | dreamina CLI + 积分余额 | 国内网络直连，图生图底图融合自然 |

### 自检逻辑

每次运行阶段4时，AI 按以下顺序自动检测：

1. `$OPENAI_API_KEY` 是否已设置 → **是**：使用 GPT image 2
2. `dreamina` CLI 是否可调用 → **是**：使用即梦
3. 都不可用 → 提示用户配置其中一种

### 如何配置

#### 方式一：GPT image 2（推荐）

```bash
# 在 ~/.bashrc 或 ~/.zshrc 中添加
export OPENAI_API_KEY="sk-your-openai-api-key"
```

获取 Key：https://platform.openai.com/api-keys

#### 方式二：即梦 dreamina

```bash
# 安装 CLI
curl -s https://jimeng.jianying.com/cli | bash

# 登录授权
dreamina login
```

获取积分：即梦 App 内充值

### 封面效果

两种引擎使用**同一套提示词体系**（四宫格结构 + 文字渲染规则），生成的封面风格一致。GPT image 2 在中文文字渲染方面更稳定，即梦在电竞暗调氛围方面更擅长。

---

## 环境变量清单

| 变量 | 必填 | 用途 |
|------|------|------|
| `GEMINI_API_KEY` | ✅ 必填 | Gemini 文案生成 |
| `OPENAI_API_KEY` | 可选 | GPT image 2 封面生成（优先） |
| `HTTPS_PROXY` | 建议 | 代理地址，国内网络环境通常需要 |

---

## 工作目录

每次任务在 `workspace/{日期}_{主题}/` 下创建临时文件。完成后由用户手动清理。AI 只有写入权限，不删除文件。
