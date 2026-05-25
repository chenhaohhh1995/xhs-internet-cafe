# 常见问题排查

## 错误速查表

| 现象 | 原因 | 解决办法 |
|------|------|---------|
| Gemini API 返回错误 | API Key 未设置或已失效 | 运行 `echo $GEMINI_API_KEY` 检查，到 [Google AI Studio](https://aistudio.google.com/apikey) 验证或重新生成 |
| `curl` 无法连接（超时/无响应） | 代理未开启 | 启动 Clash Verge 或同类工具，运行 `echo $HTTPS_PROXY` 确认代理地址已设置 |
| dreamina 报 "credit exhausted" | 即梦积分用完了 | 运行 `dreamina user_credit` 查看余额，不足时充值 |
| lark-cli 报 "auth expired" | 飞书登录态过期 | 重新执行 lark-cli 认证登录 |
| 封面文字变形/乱码 | 即梦模型对中文文字的渲染不稳定 | 在当前会话中告诉 Claude，AI 会重试生成（内置了文字渲染修复规则） |
| `python-docx not found` | Python 包未安装 | 运行 `pip install python-docx`（或 `pip3 install python-docx`） |
| `command not found: dreamina` | dreamina 不在 PATH 中 | 运行 `export PATH="$HOME/bin:$PATH"` 添加到当前会话，或重新安装 dreamina CLI |
| `command not found: lark-cli` | lark-cli 未安装 | 参考安装文档，或运行 `which lark-cli` 排查路径 |
| 飞书文档导出失败 | 文档权限不足 | 确认 AI / bot 账号对该飞书文档有查看权限 |
| 工作目录路径报错 | 使用了 Windows CMD | 换用 Git Bash（Windows）或终端（macOS），本工具不支持 Windows CMD |
|`python3` 命令找不到 | Python 未安装或路径不对 | Windows 下先试 `python3`，失败则试 `python`；macOS 用 `brew install python` |

---

## 还是不行？

### 运行诊断脚本

```bash
bash scripts/setup-check.sh
```

这个脚本会自动检测工具安装状态、环境变量、网络连通性，并打印诊断报告。把输出发给 Claude 或技术支持。

### 重启 Claude Code 会话

有时候环境变量在会话中途被修改但未生效。保存进度，新开一个 Claude Code 会话再试。

### 描述问题

在 Claude Code 中输入你看到的完整错误信息，AI 会帮你分析具体原因。
