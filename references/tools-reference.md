# 工具与 API 参考手册

> **AI Agent 专用。** 执行任何阶段前，如需确认工具用法、参数、错误处理，读此文档。

---

## Gemini API

### 模型

| 模型 ID | 用途 | 说明 |
|---------|------|------|
| `gemini-3.5-flash` | 文案生成 | 最新 Flash 旗舰，Agent 任务最强 |
| `gemini-3-flash-preview` | 文案生成 | 技术深度和行业口吻最佳 |

### 端点

```
https://generativelanguage.googleapis.com/v1beta/models/{MODEL_ID}:generateContent?key=$GEMINI_API_KEY
```

### 调用方式（curl）

```bash
curl --silent \
  $( [ -n "$HTTPS_PROXY" ] && echo "--proxy $HTTPS_PROXY" ) \
  -H "Content-Type: application/json" \
  --data-binary @"$SKILL_DIR/workspace/{本次任务}/.temp_gemini_req_{direction}_{model}.json" \
  "https://generativelanguage.googleapis.com/v1beta/models/{MODEL_ID}:generateContent?key=$GEMINI_API_KEY"
```

- `$GEMINI_API_KEY` 必设，否则 curl 返回 401
- `$HTTPS_PROXY` 如设置则通过 `--proxy` 走代理；未设置则直连（`$( [ -n "$VAR" ] && ... )` 自动处理）

### 请求 JSON 格式

```json
{
  "contents": [
    {
      "parts": [
        {"text": "<完整 prompt 文本>"}
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.9,
    "maxOutputTokens": 2048
  }
}
```

### 响应解析

成功时 `.candidates[0].content.parts[0].text` 包含生成文本。失败时检查 `error.code`：
- `429` → 速率限制，跳过该模型，其余照常
- `401` → API Key 无效，检查 `$GEMINI_API_KEY`
- `500` → 服务端错误，该模型返回空

### 并发策略

四个 curl 同时发出（`&` 后台 + `wait`），不排队：

```bash
curl ... &  # A方向 3.5 Flash
curl ... &  # A方向 3 Flash Preview
curl ... &  # B方向 3.5 Flash
curl ... &  # B方向 3 Flash Preview
wait
```

---

## GPT image 2（OpenAI 图生图）⭐ 封面生成首选

### 优先级

仅在 `$OPENAI_API_KEY` 已设置时使用。不可用时自动降级为即梦 dreamina。

### 认证

```bash
# 检查环境变量
echo "$OPENAI_API_KEY"
```

已设置 → 走 GPT image 2。未设置 → 跳过，使用 dreamina。

### 端点

```
POST https://api.openai.com/v1/images/generations
```

### 调用方式（curl）

```bash
PROXY=""
[ -n "$HTTPS_PROXY" ] && PROXY="--proxy $HTTPS_PROXY"

curl --silent $PROXY \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2",
    "prompt": "<完整正向提示词，含固定开头+随机文字+文字渲染规则+负面约束>",
    "n": 1,
    "size": "1024x1366",
    "response_format": "url"
  }' \
  "https://api.openai.com/v1/images/generations"
```

### 参数说明

| 参数 | 值 | 说明 |
|------|-----|------|
| `model` | `gpt-image-2` | GPT image 2 模型 |
| `prompt` | 完整提示词字符串 | 四宫格描述 + 文字渲染约束（与即梦共用同一套提示词体系） |
| `n` | 1 | 每次生成1张，4张封面需调4次 |
| `size` | `1024x1366` | 接近 3:4 竖版比例 |
| `response_format` | `url` | 返回临时下载 URL |

### 提示词适配

GPT image 2 的提示词与即梦共用同一套结构（固定开头 + 随机文字 + 文字渲染规则 + 负面提示词），无需额外修改。GPT image 2 对中文文字渲染精度更高，但仍需保留文字渲染规则约束。

### 图像下载

```bash
curl --silent $PROXY -o "$WORKSPACE/cover_{direction}_{n}.png" "<image_url>"
```

### 错误处理

| 错误 | 处理 |
|------|------|
| 401 | API Key 无效，降级为 dreamina |
| 429 | 速率限制，等待后重试，仍失败则降级 |
| 内容策略拒绝 | 简化提示词中可能敏感的描述，重试 |

---

## lark-cli（飞书/Lark CLI）

### 用途

| 命令 | 用途 | 阶段 |
|------|------|------|
| `lark-cli wiki spaces get_node` | 通过 URL 解析 wiki token → 获取文档 token | 阶段0 |
| `lark-cli drive +export` | 将飞书文档导出为 .docx 到本地 | 阶段0 |
| `lark-cli drive +import` | 将本地 .docx 导入飞书为云文档 | 阶段5 |

### 安装与认证

lark-cli 是非标准工具，需要单独安装并完成飞书 OAuth 认证。具体安装方式由飞书官方提供。首次使用前需完成登录认证。

### 关键命令

#### 解析 wiki token

```bash
lark-cli wiki spaces get_node --token "<wiki_token_from_url>"
```

从飞书知识库 URL 中提取 token。例如 URL `https://my.feishu.cn/docx/TnZgdIYUQoTGO8xtZXOckvmNnYb` 中的 `TnZgdIYUQoTGO8xtZXOckvmNnYb`。

#### 导出 Word

```bash
lark-cli drive +export \
  --token "<doc_token>" \
  --doc-type docx \
  --file-extension docx \
  --output-dir "$SKILL_DIR/workspace/{本次任务}/" \
  --overwrite
```

返回值含 `saved_path`（本地 .docx 路径）和 `file_token`。

#### 导入 Word

```bash
lark-cli drive +import \
  --file "$SKILL_DIR/workspace/{本次任务}/最终文档.docx" \
  --type docx \
  --name "{网吧名称} 探店笔记 — {日期}"
```

返回值含 `document_id` 和 `url`（飞书文档链接）。

### 错误处理

| 错误 | 可能原因 | 处理 |
|------|---------|------|
| Token 无效 | URL 格式不对或文档不存在 | 让用户确认链接是否正确 |
| 导出失败 | 文档权限不足 | 让用户确认已将 AI 添加为文档协作者 |
| 导入失败 | 文件不存在或格式错误 | 检查 .docx 是否已用 python-docx 保存成功 |
| 认证过期 | 登录态失效 | 执行 lark-cli 的认证刷新流程 |

---

## dreamina CLI（即梦 AI 图像生成）

### 安装

```bash
curl -s https://jimeng.jianying.com/cli | bash
```

安装后二进制文件通常在 `$HOME/bin/dreamina`。使用前确保在 PATH 中：

```bash
export PATH="$HOME/bin:$PATH"
```

### 认证

首次使用需 OAuth 设备授权：

```bash
dreamina login
```

按终端提示在浏览器中完成授权。登录态本地持久化，后续复用。

### 主要命令

| 命令 | 用途 |
|------|------|
| `dreamina login` | OAuth 设备授权 |
| `dreamina user_credit` | 查询积分/额度余额 |
| `dreamina image2image` | 图生图（以参考图为底图生成新图） |
| `dreamina query_result --submit_id=<id>` | 查询异步任务结果 |

### image2image 命令

```bash
dreamina image2image \
  --images "$SKILL_DIR/workspace/{本次任务}/cover_01.jpg,$SKILL_DIR/workspace/{本次任务}/cover_02.jpg,$SKILL_DIR/workspace/{本次任务}/cover_03.jpg,$SKILL_DIR/workspace/{本次任务}/cover_04.jpg" \
  --prompt "<完整正向提示词，含固定开头+随机文字+文字渲染规则+负面约束>" \
  --ratio 3:4 \
  --resolution_type 2k \
  --model_version 5.0 \
  --poll 120
```

### 参数说明

| 参数 | 可选值 | 说明 |
|------|--------|------|
| `--images` | 本地路径，逗号分隔 | 参考底图，最多10张；路径用正斜杠 |
| `--prompt` | 字符串 | 正向提示词，dreamina 无独立 `--negative-prompt`，负面约束写入末尾 |
| `--ratio` | 21:9/16:9/3:2/4:3/1:1/**3:4**/2:3/9:16 | 3:4 为小红书竖版封面 |
| `--resolution_type` | **2k**/4k | 2k 为高清，1k 不支持图生图 |
| `--model_version` | 4.0/4.1/4.5/4.6/**5.0** | 5.0 为最新模型 |
| `--poll` | 秒数 | 提交后轮询等待，0=不等待（异步任务需后续 `query_result`） |

### 错误处理

| 错误 | 处理 |
|------|------|
| 积分不足 | `dreamina user_credit` 确认余额，告知用户充值 |
| 认证过期 | `dreamina login` 重新授权 |
| 任务超时 | `dreamina query_result --submit_id=<id>` 查询结果 |
| 生成质量不合格 | 调整提示词重新生成，最多重试2次 |

---

## python + python-docx

### Python 调用

```bash
# 先试 python3，失败降级 python
python3 -c "..." 2>/dev/null || python -c "..."
```

### python-docx 安装

```bash
pip3 install python-docx 2>/dev/null || pip install python-docx
```

### 常用代码片段

#### 解析 Word 文档

```python
from docx import Document
doc = Document("workspace/{本次任务}/xxx.docx")

# 遍历表格
for table in doc.tables:
    for row in table.rows:
        cells = [c.text for c in row.cells]
        # 按行位置提取网吧信息

# 提取内嵌图片
for i, shape in enumerate(doc.inline_shapes):
    with open(f"workspace/{本次任务}/cover_{i+1:02d}.jpg", "wb") as f:
        f.write(shape._inline.graphic.graphicData.pic.blipFill.blip.embed)
```

#### 构建输出 Word 文档

```python
from docx import Document
from docx.shared import Inches

doc = Document()

# 内容类型A
doc.add_heading('内容类型A：{A方向内容类型}', 1)
doc.add_heading('封面图', 2)
doc.add_heading('A1版本', 3)
doc.add_picture('workspace/{本次任务}/cover_A1.png', width=Inches(4))
# ... 后续结构参考 SKILL.md 阶段5

doc.save('workspace/{本次任务}/最终文档.docx')
```

---

## curl

### 代理处理模板

```bash
# 代理条件化：$HTTPS_PROXY 已设置则走代理，未设置则直连
PROXY_ARG=""
[ -n "$HTTPS_PROXY" ] && PROXY_ARG="--proxy $HTTPS_PROXY"

curl --silent $PROXY_ARG \
  -H "Content-Type: application/json" \
  --data-binary @<json_file> \
  "<api_url>"
```

### 并发调用

```bash
curl ... &  # 进程1 后台
curl ... &  # 进程2 后台
curl ... &  # 进程3 后台
curl ... &  # 进程4 后台
wait         # 等待全部完成
```

各进程输出写入独立临时文件，`wait` 后统一解析。

---

## 跨平台速查

| 项目 | macOS | Windows (Git Bash) |
|------|-------|-------------------|
| 用户目录 | `/Users/xxx/` | `/c/Users/xxx/` |
| HOME | `/Users/xxx` | `/c/Users/xxx` |
| PATH 分隔 | `:` | `:` |
| 换行符 | `\n` | `\n` |
| Python | `python3` | `python3` / `python` |
| Shell | zsh/bash | bash (Git Bash) |
| 工具查找 | `which` | `which` |
| dreamina 安装路径 | `$HOME/bin/dreamina` | `$HOME/bin/dreamina` |
