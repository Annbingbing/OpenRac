# 🦝 OpenRac 小浣熊

> 一个轻量、强大、开箱即用的 AI Agent，支持 Telegram、HTTP API 和命令行三种使用方式。

## 特性

- **无需安装 Go 环境** — 直接下载二进制，解压即用
- **多平台支持** — Windows / macOS / Linux，Intel 和 ARM 均有预编译版本
- **Telegram Bot** — 配置 Bot Token 后即可通过 Telegram 对话，服务器部署无需开放任何端口
- **HTTP API** — 内置 SSE 流式接口，方便接入其他应用（可选开启）
- **兼容所有 OpenAI 格式接口** — OpenAI、Claude、DeepSeek、本地 Ollama 等均可使用
- **内置 7 个专项技能** — 新闻、加密行情、预测市场、SSH 远程、Web3 数据等开箱即用
- **可扩展 Skills** — 支持从 URL 一键安装社区 skill
- **安全** — 仅 Telegram 模式下不开放任何网络端口，HTTP API 默认仅本机访问

## 内置技能

| 技能 | 说明 |
|------|------|
| 📰 daily-news | 每日新闻和热门话题，多分类支持 |
| 📈 binance | 币安现货/期货行情、Web3 链上数据、智能资金信号 |
| 🎯 polymarket-odds | Polymarket 预测市场实时赔率，无需 Key |
| 🔍 rootdata-crypto | 加密项目详情、融资轮次、Web3 投资者信息 |
| 🖥️ ssh-mcp-server | SSH 远程连接服务器，执行命令/上传下载文件 |
| 🛡️ skill-vetter | 安装 skill 前的安全审查协议 |
| 🦝 proactive-agent | 主动型 agent 行为框架，WAL 协议、上下文恢复 |

## 快速开始

### 1. 下载

前往 [Releases](https://github.com/Annbingbing/OpenRac/releases) 下载对应平台的二进制文件：

| 平台 | 文件 |
|------|------|
| Windows x64 | `openrac-windows-amd64.exe` |
| macOS Intel | `openrac-darwin-amd64` |
| macOS M1/M2/M3 | `openrac-darwin-arm64` |
| Linux x64 | `openrac-linux-amd64` |
| Linux ARM | `openrac-linux-arm64` |

macOS / Linux 需要添加执行权限：

```bash
chmod +x openrac-linux-amd64
```

### 2. 配置

在二进制文件同目录下创建 `config.yaml`。

**仅 Telegram 模式（推荐服务器部署）：**

```yaml
# LLM Provider（支持所有 OpenAI 格式接口）
providers:
  - id: my-provider
    base_url: https://api.openai.com/v1   # 或 DeepSeek、本地 Ollama 等
    api_key: sk-xxxxxxxx
    model: gpt-4o
    timeout: 120s

# Telegram Bot
telegram:
  enabled: true
  bot_token: "123456:ABCdef..."

# 代理（可选）
# proxy: http://127.0.0.1:7897
```

**同时开启 HTTP API：**

```yaml
providers:
  - id: my-provider
    base_url: https://api.openai.com/v1
    api_key: sk-xxxxxxxx
    model: gpt-4o

telegram:
  enabled: true
  bot_token: "123456:ABCdef..."

gateway:
  enabled: true
  addr: :8080
  token: "your-secret-token"   # 对外暴露必须设置
```

### 3. 启动

```bash
./openrac-linux-amd64
```

### 单次对话模式

```bash
./openrac-linux-amd64 -chat "今天有什么热点新闻？"
```

## 部署到服务器

仅 Telegram 模式下，agent 通过长轮询主动拉取消息，**无需开放任何防火墙端口**，直接运行即可：

```bash
# 后台运行
nohup ./openrac-linux-amd64 > agent.log 2>&1 &

# 或使用 systemd
```

## HTTP API

需在 config.yaml 中设置 `gateway.enabled: true` 后启动：

```bash
curl -X POST http://localhost:8080/v1/chat \
  -H "Authorization: Bearer your-secret-token" \
  -H "Content-Type: application/json" \
  -d '{"message": "BTC 现在多少钱？", "session_id": "user1"}'
```

响应为 SSE 流式输出。健康检查：`GET /healthz`

## Skills 管理

在 Telegram 或 HTTP API 中直接对话即可管理 skills：

```
安装 skill：install_skill(url: "https://github.com/user/my-skill")
列出 skill：list_skills()
删除 skill：remove_skill(name: "my-skill")
```

## 配置说明

| 字段 | 说明 | 默认值 |
|------|------|--------|
| `providers[].base_url` | LLM API 地址 | — |
| `providers[].api_key` | API Key | — |
| `providers[].model` | 模型名称 | — |
| `providers[].timeout` | 请求超时 | `120s` |
| `telegram.enabled` | 启用 Telegram | `false` |
| `telegram.bot_token` | Bot Token | — |
| `gateway.enabled` | 启用 HTTP 网关 | `false` |
| `gateway.addr` | HTTP 监听地址 | `127.0.0.1:8080` |
| `gateway.token` | Bearer 鉴权 Token | 空（对外暴露必须设置） |
| `proxy` | HTTP 代理 | — |
| `max_context_tokens` | 最大上下文 Token 数 | `100000` |
| `system_prompt_extra` | 追加到系统提示词 | — |`

## License

MIT
