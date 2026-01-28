---
title: 部署到 Railway
summary: "在 Railway 上部署 Moltbot 作为 Telegram + Gemini 私人助理"
---

# Railway 部署指南

本指南介绍如何在 Railway 上部署 Moltbot，使用 Telegram 作为消息通道，Gemini 作为 AI 后端，打造你的私人 AI 助理。

## 前置准备

### 1. 获取 Gemini API Key

1. 访问 [Google AI Studio](https://aistudio.google.com/)
2. 登录你的 Google 账号
3. 点击 **Get API key** 获取 API 密钥
4. 保存好你的 API Key

### 2. 创建 Telegram Bot

1. 在 Telegram 中搜索 `@BotFather` 并发起对话
2. 发送 `/newbot` 命令
3. 按提示设置 Bot 名称和用户名（用户名必须以 `bot` 结尾）
4. 复制 Bot Token（格式类似 `123456789:AAH...`）

### 3. 获取你的 Telegram User ID

在配对模式下，你需要知道自己的 Telegram User ID：

1. 在 Telegram 中搜索 `@userinfobot`
2. 发送任意消息，机器人会返回你的 User ID

## 一键部署到 Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/moltbot-railway-template)

点击上方按钮开始部署，然后按照下面的步骤配置。

## 手动部署步骤

### 1. 创建 Railway 项目

1. 登录 [Railway](https://railway.com/)
2. 点击 **New Project** → **Deploy from GitHub repo**
3. 连接你的 GitHub 账号并选择 fork 的仓库

### 2. 添加持久化存储

1. 在项目中点击 **+ New** → **Volume**
2. 设置挂载路径为 `/data`
3. 点击 **Create Volume**

### 3. 配置环境变量

在 Railway 服务的 **Variables** 选项卡中设置：

| 变量名 | 必填 | 说明 |
|--------|------|------|
| `PORT` | 是 | 设为 `8080` |
| `SETUP_PASSWORD` | 是 | 设置向导的访问密码 |
| `GEMINI_API_KEY` | 是 | Google Gemini API 密钥 |
| `TELEGRAM_BOT_TOKEN` | 是 | Telegram Bot Token |
| `CLAWDBOT_STATE_DIR` | 推荐 | 设为 `/data/.clawdbot` |
| `CLAWDBOT_WORKSPACE_DIR` | 推荐 | 设为 `/data/workspace` |
| `CLAWDBOT_GATEWAY_TOKEN` | 推荐 | Gateway 管理密钥（自定义长字符串） |

### 4. 配置网络

1. 进入服务的 **Settings** 选项卡
2. 在 **Networking** 部分，启用 **Public Networking**
3. 设置端口为 `8080`
4. 记录生成的域名（如 `xxx.up.railway.app`）

### 5. 完成设置向导

1. 访问 `https://你的域名/setup`
2. 输入 `SETUP_PASSWORD` 登录
3. 选择 **Gemini API Key** 作为认证方式
4. 输入你的 Gemini API Key
5. 在 Telegram 设置中输入 Bot Token
6. 点击 **Run setup** 完成配置

## 配置说明

### Telegram 访问控制

默认使用 **配对模式（pairing）**，首次与 Bot 对话时需要验证配对码：

1. 在 Telegram 中向你的 Bot 发送消息
2. Bot 会回复一个配对码
3. 在设置向导中批准该配对码

也可以使用 **允许列表模式**：

```json5
{
  channels: {
    telegram: {
      dmPolicy: "allowlist",
      allowFrom: ["你的Telegram用户ID"]
    }
  }
}
```

### 使用其他 Gemini 模型

默认使用 `google/gemini-3-pro-preview`，可在配置中修改：

```json5
{
  agents: {
    defaults: {
      model: {
        primary: "google/gemini-3-flash-preview"  // 更快、更便宜
      }
    }
  }
}
```

### 自定义助理人设

```json5
{
  identity: {
    name: "小助理",
    language: "zh-CN",
    persona: "你是一个专业的私人助理，擅长日程管理、信息查询和文档处理。"
  }
}
```

## 管理与监控

### 控制面板

访问 `https://你的域名/moltbot` 查看控制面板：

- 查看对话状态
- 管理配对请求
- 查看日志

### 备份数据

访问 `https://你的域名/setup/export` 下载完整备份，包含：

- 配置文件
- 认证信息
- 对话历史
- 工作区文件

### 查看日志

在 Railway 控制台查看实时日志，或使用 CLI：

```bash
railway logs
```

## 常见问题

### Bot 不回复消息

1. 检查 `TELEGRAM_BOT_TOKEN` 是否正确
2. 检查 `GEMINI_API_KEY` 是否有效
3. 查看 Railway 日志排查错误

### 配对码无法使用

确保在设置向导中批准配对请求，或切换到 allowlist 模式。

### 重启后数据丢失

确保已正确配置 Volume 挂载到 `/data`，并设置了环境变量：

- `CLAWDBOT_STATE_DIR=/data/.clawdbot`
- `CLAWDBOT_WORKSPACE_DIR=/data/workspace`

## 费用估算

Railway 按使用量计费：

- **Hobby Plan**: $5/月起
- 包含 CPU、内存和存储使用

Gemini API 费用：

- `gemini-3-pro-preview`: 按 token 计费
- `gemini-3-flash-preview`: 更经济实惠

建议从 Hobby Plan 开始，根据实际使用情况调整。

## 相关文档

- [Telegram 通道配置](/channels/telegram)
- [模型提供商](/concepts/model-providers)
- [完整配置参考](/gateway/configuration)
