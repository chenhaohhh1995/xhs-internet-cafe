# 各阶段详细操作步骤

> **AI Agent 专用。** 执行阶段0/3/5 时读取对应章节。

---

## 阶段0：飞书文档读取（详细）

### Step 0：创建工作目录

```bash
WORKSPACE="$SKILL_DIR/workspace/$(date +%Y%m%d)_${任务主题}"
mkdir -p "$WORKSPACE"
```

- 若无法获取日期格式，使用手动命名
- 所有后续路径基于 `$WORKSPACE` 推导

### Step 1：解析 URL → 获取文档 token

从用户提供的飞书链接中提取 wiki token（URL 路径最后一段），调用：

```bash
lark-cli wiki spaces get_node --token "<wiki_token>"
```

返回值含 `doc_token`，用于下一步导出。

### Step 2：导出 .docx

```bash
lark-cli drive +export \
  --token "<doc_token>" \
  --doc-type docx \
  --file-extension docx \
  --output-dir "$WORKSPACE" \
  --overwrite
```

返回值：`saved_path`（本地 .docx 路径）、`file_token`。

### Step 3：Python 解析 .docx

```python
from docx import Document
doc = Document("<saved_path>")

# 遍历所有表格 → 提取网吧信息文字
for table in doc.tables:
    for row in table.rows:
        cells = [c.text.strip() for c in row.cells if c.text.strip()]
        if cells:
            # 第1行 = 封面图，第2行起 = 网吧信息字段
            # 按列名（如"网吧名称""位置""配置"等）归类

# 提取封面四张底图（仅第1行对应的内嵌图片）
# 从 doc.inline_shapes 中按位置提取
for i in range(4):
    shape = doc.inline_shapes[i]  # 前4张为封面图
    with open(f"$WORKSPACE/cover_{i+1:02d}.jpg", "wb") as f:
        f.write(shape._inline.graphic.graphicData.pic.blipFill.blip.embed)
```

### Step 4：输出信息摘要

```markdown
## 网吧信息
- 名称：xxx
- 位置：xxx
- 配置：xxx
- 特色：xxx

## 封面底图
- cover_01.jpg ~ cover_04.jpg ✅ 已提取

## 模糊点
- 无 / [列出模糊项]
```

---

## 阶段3：Gemini 出稿（详细）

### Step 1：组装 Prompt

每个策划方向独立组装一份 prompt。先阅读 `references/style-guide.md`，将创作人格、语气参数、正文规范中的关键约束提取到 prompt 中。

**Prompt 结构模板：**

```
你是一个小红书真实用户，现在需要写一篇网吧探店分享。

## 网吧信息
[阶段0/1收集的全部网吧信息]

## 创作要求
- 切入点：[A/B方向切入点描述]
- 钩子手法：[主钩子] + [副钩子]
- 节奏模式：[选用的节奏模式]
- 结构大纲：[该方向的大纲]
- 品牌植入：[植入方案]

## 表述规范（从 references/style-guide.md 提取）
- 人设：[从核心创作人格提取]
- 语调：[从语气参数提取]
- 字数：150-300字，自然分段
- 人称："我"
- 用词：[口语化、圈层黑话]
- 不虚构：只写用户提供的信息
- Emoji：1-3处点缀
- 植入要软：全文仅1处提及"泰坦军团"，"发现"口吻
- 首句是钩子：前15字让人停下来
- 结尾引导互动
- 参数守穷：挑1-2个最有冲击力的数据
- 品牌克制：全文仅1处品牌名
- 游戏名随机选：《CS2》《三角洲行动》《瓦罗兰特》《吃鸡》四选一
- 标签强制：必须 #泰坦军团

## 输出格式
1. 3个候选标题（20字以内）
2. 正文
3. 3-5个#话题标签
```

### Step 2：写入请求 JSON

```python
import json

request = {
    "contents": [{"parts": [{"text": prompt}]}],
    "generationConfig": {"temperature": 0.9, "maxOutputTokens": 2048}
}

with open(f"{WORKSPACE}/.temp_gemini_req_{direction}_{model}.json", "w", encoding="utf-8") as f:
    json.dump(request, f, ensure_ascii=False)
```

- `direction` = `A` / `B`
- `model` = `35flash` / `3flash`

### Step 3：四路并发调用

```bash
PROXY=""
[ -n "$HTTPS_PROXY" ] && PROXY="--proxy $HTTPS_PROXY"

# 同时发出四个请求
curl --silent $PROXY -H "Content-Type: application/json" \
  --data-binary @"$WORKSPACE/.temp_gemini_req_A_35flash.json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=$GEMINI_API_KEY" \
  > "$WORKSPACE/.temp_response_A_35flash.json" 2>&1 &

curl --silent $PROXY -H "Content-Type: application/json" \
  --data-binary @"$WORKSPACE/.temp_gemini_req_A_3flash.json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$GEMINI_API_KEY" \
  > "$WORKSPACE/.temp_response_A_3flash.json" 2>&1 &

curl --silent $PROXY -H "Content-Type: application/json" \
  --data-binary @"$WORKSPACE/.temp_gemini_req_B_35flash.json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=$GEMINI_API_KEY" \
  > "$WORKSPACE/.temp_response_B_35flash.json" 2>&1 &

curl --silent $PROXY -H "Content-Type: application/json" \
  --data-binary @"$WORKSPACE/.temp_gemini_req_B_3flash.json" \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$GEMINI_API_KEY" \
  > "$WORKSPACE/.temp_response_B_3flash.json" 2>&1 &

wait
```

### Step 4：解析响应

```python
import json, re

for direction in ["A", "B"]:
    for model_key, model_name in [("35flash", "3.5 Flash"), ("3flash", "3 Flash Preview")]:
        with open(f"{WORKSPACE}/.temp_response_{direction}_{model_key}.json") as f:
            resp = json.load(f)
        if "candidates" in resp:
            text = resp["candidates"][0]["content"]["parts"][0]["text"]
            # 从 text 中解析：候选标题 / 正文 / 标签
        else:
            # 被限或失败，该版本留空
            pass
```

### Step 5：审核

对照 `references/style-guide.md` + `references/planning-guide.md`：

**质量审查**：品牌信息准确、植入软度、真人感（无AI腔）、字数范围、Emoji密度、不虚构、细节支撑

**流量审查**：首句钩子、点击欲、完读率、收藏欲、评论欲

退回修改最多2轮。通过后进入阶段4。

---

## 阶段4：封面生成（详细）

### Step 0：检测生图引擎

```bash
# 优先级1：GPT image 2
if [ -n "$OPENAI_API_KEY" ]; then
  ENGINE="gpt-image-2"
# 优先级2：即梦 dreamina
elif command -v dreamina &> /dev/null; then
  ENGINE="dreamina"
else
  echo "❌ 无可用的生图引擎。请设置 OPENAI_API_KEY 或安装 dreamina CLI。"
  exit 1
fi
echo "使用引擎：$ENGINE"
```

### Step 1：路由决策 + 封面文案（两种引擎通用）

从阶段3通过的正文中提取内容特征 → 按 `references/cover-guide.md` 执行路由决策 → 锁定每种方向的 2 种拆法 → 生成三行封面文案。

每方向生成 2 组候选，共 4 组封面文案。

### Step 2：随机配色 + 随机字号（通用）

从 `references/jimeng-prompt-template.md` 八套配色方案中每张独立随机，四张不可全同。字号从随机池中独立随机。

### Step 3：组装提示词（通用）

按 `references/jimeng-prompt-template.md` 模板：固定开头（四宫格结构）→ 随机文字参数 → 固定文字渲染规则 → 负面提示词。

### Step 4A：GPT image 2 生图（如引擎 = gpt-image-2）

```bash
PROXY=""
[ -n "$HTTPS_PROXY" ] && PROXY="--proxy $HTTPS_PROXY"

# 每张封面独立调用
for direction in A B; do
  for n in 1 2; do
    curl --silent $PROXY \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"model\":\"gpt-image-2\",\"prompt\":\"<完整提示词>\",\"n\":1,\"size\":\"1024x1366\",\"response_format\":\"url\"}" \
      "https://api.openai.com/v1/images/generations" \
      > "$WORKSPACE/.temp_response_cover_${direction}${n}.json"
    
    # 解析返回的 URL 并下载图片
    IMG_URL=$(python3 -c "import json; print(json.load(open('$WORKSPACE/.temp_response_cover_${direction}${n}.json'))['data'][0]['url'])")
    curl --silent $PROXY -o "$WORKSPACE/cover_${direction}${n}.png" "$IMG_URL"
  done
done
```

### Step 4B：dreamina 生图（如引擎 = dreamina）

```bash
export PATH="$HOME/bin:$PATH"

for direction in A B; do
  for n in 1 2; do
    dreamina image2image \
      --images "$WORKSPACE/cover_01.jpg,$WORKSPACE/cover_02.jpg,$WORKSPACE/cover_03.jpg,$WORKSPACE/cover_04.jpg" \
      --prompt "<完整提示词>" \
      --ratio 3:4 \
      --resolution_type 2k \
      --model_version 5.0 \
      --poll 120
    # 输出文件重命名为 cover_{direction}{n}.png
  done
done
```

### Step 5：质量检查（通用）

逐张检查：四宫格布局 / 分割线清晰 / 文字完整无乱码 / 居中无倾斜 / 配色一致 / 缩略图可读。不合格最多重试 2 次。

---

## 阶段5：飞书打包（详细）

### Step 1：构建 .docx

```python
from docx import Document
from docx.shared import Inches
import os

WORKSPACE = os.environ.get("WORKSPACE", "workspace/当前任务")
doc = Document()

# ========== 内容类型A ==========
doc.add_heading(f'内容类型A：{A_content_type}', 1)

doc.add_heading('封面图', 2)

doc.add_heading('A1版本', 3)
doc.add_picture(f'{WORKSPACE}/cover_A1.png', width=Inches(4))

doc.add_heading('A2版本', 3)
doc.add_picture(f'{WORKSPACE}/cover_A2.png', width=Inches(4))

doc.add_heading('Gemini 3.5 Flash 版本', 2)
doc.add_paragraph('候选标题：')
for i, t in enumerate(A_35flash_titles, 1):
    doc.add_paragraph(f'{i}. {t}')
doc.add_paragraph('正文：')
doc.add_paragraph(A_35flash_body)
doc.add_paragraph('标签：')
doc.add_paragraph(A_35flash_tags)

doc.add_heading('Gemini 3 Flash Preview 版本', 2)
doc.add_paragraph('候选标题：')
for i, t in enumerate(A_3flash_titles, 1):
    doc.add_paragraph(f'{i}. {t}')
doc.add_paragraph('正文：')
doc.add_paragraph(A_3flash_body)
doc.add_paragraph('标签：')
doc.add_paragraph(A_3flash_tags)

# ========== 内容类型B（同上结构） ==========
doc.add_heading(f'内容类型B：{B_content_type}', 1)

doc.add_heading('封面图', 2)

doc.add_heading('B1版本', 3)
doc.add_picture(f'{WORKSPACE}/cover_B1.png', width=Inches(4))

doc.add_heading('B2版本', 3)
doc.add_picture(f'{WORKSPACE}/cover_B2.png', width=Inches(4))

doc.add_heading('Gemini 3.5 Flash 版本', 2)
doc.add_paragraph('候选标题：')
for i, t in enumerate(B_35flash_titles, 1):
    doc.add_paragraph(f'{i}. {t}')
doc.add_paragraph('正文：')
doc.add_paragraph(B_35flash_body)
doc.add_paragraph('标签：')
doc.add_paragraph(B_35flash_tags)

doc.add_heading('Gemini 3 Flash Preview 版本', 2)
doc.add_paragraph('候选标题：')
for i, t in enumerate(B_3flash_titles, 1):
    doc.add_paragraph(f'{i}. {t}')
doc.add_paragraph('正文：')
doc.add_paragraph(B_3flash_body)
doc.add_paragraph('标签：')
doc.add_paragraph(B_3flash_tags)

# ========== 信息待补充（如有） ==========
if fuzzy_items:
    doc.add_heading('信息待补充', 1)
    for item in fuzzy_items:
        doc.add_paragraph(f'· {item["描述"]} — 建议填写格式：{item["格式"]}')

doc.save(f'{WORKSPACE}/最终文档.docx')
```

### Step 2：导入飞书

```bash
lark-cli drive +import \
  --file "$WORKSPACE/最终文档.docx" \
  --type docx \
  --name "{网吧名称} 探店笔记 — $(date +%Y%m%d)"
```

### Step 3：输出链接

告知用户飞书文档链接。完整内容在飞书文档中查看，不在对话框展示。
