# Railway 部署步骤详解

## 部署顺序说明

**重要**：Railway 的某些配置选项（如 Public Networking）在首次部署成功后才显示。请按照以下顺序操作：

## 第一步：初始部署（无需 Public Networking）

### 1. 创建项目并连接仓库

1. 登录 [Railway](https://railway.com/)
2. 点击 **New Project** → **Deploy from GitHub repo**
3. 选择你的仓库（`yilinjushi/elbarto`）

### 2. 添加 Volume（推荐，用于数据持久化）

**重要**：在设置环境变量之前，先添加 Volume：

1. 在服务卡片上，点击 **+ New** → **Volume**
2. 设置 **Mount Path** 为 `/data`
3. 点击创建

这样数据会持久化保存，重启不会丢失。

### 3. 设置环境变量（部署前必须设置）

在服务的 **Variables** 选项卡中，添加以下环境变量：

| 变量名 | 值 | 说明 | 必填 |
|--------|------|------|------|
| `PORT` | `8080` | Railway 可能自动设置，但建议手动设置 | 推荐 |
| `SETUP_PASSWORD` | 你的密码 | 设置向导访问密码 | **必需** |
| `GEMINI_API_KEY` | 你的密钥 | Google Gemini API 密钥 | **必需** |
| `TELEGRAM_BOT_TOKEN` | 你的 Token | Telegram Bot Token | **必需** |
| `NODE_OPTIONS` | `--max-old-space-size=4096` | Node.js 内存限制（防止内存不足错误） | **强烈推荐** |
| `CLAWDBOT_STATE_DIR` | `/data/.clawdbot` | 状态目录（如果使用 Volume） | 推荐 |
| `CLAWDBOT_GATEWAY_TOKEN` | 随机字符串 | Gateway 认证 token | 可选 |

**关键环境变量说明：**

- **`NODE_OPTIONS`**: 设置为 `--max-old-space-size=4096` 可以防止 "JavaScript heap out of memory" 错误。如果 Railway 分配的内存较小，可以设置为 `2048` 或 `3072`。
- **`CLAWDBOT_STATE_DIR`**: 如果添加了 Volume 挂载到 `/data`，设置为 `/data/.clawdbot` 可以确保数据持久化。

**如何获取 API 密钥：**

- **Gemini API Key**: 访问 https://aistudio.google.com/ → Get API key
- **Telegram Bot Token**: 在 Telegram 中搜索 `@BotFather` → `/newbot` → 复制 Token

### 4. 首次部署

1. Railway 会自动检测代码更新并开始部署
2. 等待构建和部署完成
3. 如果健康检查失败，查看 **Deploy Logs** 排查问题

**重要提示：**
- 确保已设置 `NODE_OPTIONS` 环境变量，否则可能因内存不足而崩溃
- 确保已添加 Volume 并设置 `CLAWDBOT_STATE_DIR`，否则数据不会持久化

## 第二步：部署成功后的配置

### 1. 启用 Public Networking（部署成功后才会显示）

部署成功后，在服务的 **Settings** 选项卡中：

1. 找到 **Networking** 或 **Public Networking** 部分
2. 如果看到 **Generate Domain** 或 **Public Networking** 选项：
   - 点击启用
   - 端口设置为 `8080`（或你设置的 PORT 值）
3. 记录生成的域名（如 `xxx.up.railway.app`）

**注意**：
- 如果看不到这个选项，可能是因为：
  - 部署还未完全成功
  - Railway 界面版本不同，选项位置可能不同
  - 某些计划可能不显示此选项

### 2. 访问设置向导

部署成功并启用 Public Networking 后：

1. 访问 `https://你的域名/setup`
2. 输入 `SETUP_PASSWORD` 登录
3. 完成配置：
   - 确认 Gemini API Key
   - 确认 Telegram Bot Token
   - 配置其他选项
4. 点击 **Run setup** 完成配置

### 3. 测试健康检查

访问 `https://你的域名/health`，应该返回：
```json
{"status":"ok","timestamp":"2026-01-28T..."}
```

## 如果看不到 Public Networking 选项

### 方法 1：检查部署状态

1. 查看 **Deploy Logs**，确认部署是否成功
2. 查看 **Build Logs**，确认构建是否成功
3. 如果看到 "Deployment failed"，需要先解决部署问题

### 方法 2：查找替代位置

在不同版本的 Railway 界面中，Public Networking 可能位于：
- **Settings** → **Networking**
- **Settings** → **Public Networking**
- **Networking** 选项卡（独立选项卡）
- 服务卡片上的 **Generate Domain** 按钮

### 方法 3：使用 Railway CLI

如果界面找不到，可以使用 Railway CLI：

```bash
# 安装 Railway CLI
npm i -g @railway/cli

# 登录
railway login

# 生成域名
railway domain
```

### 方法 4：Railway 可能自动处理

在某些情况下，Railway 会自动：
- 分配端口
- 生成域名
- 配置网络

检查服务卡片上是否已经显示了域名。

## 常见错误及解决方案

### 错误 1：内存不足 (JavaScript heap out of memory)

**症状：**
```
FATAL ERROR: Reached heap limit Allocation failed - JavaScript heap out of memory
```

**解决方案：**
1. 在 Railway **Variables** 中添加：
   - 变量名：`NODE_OPTIONS`
   - 变量值：`--max-old-space-size=4096`
2. 检查 Railway **Settings** → **Resources**，确保分配了足够的内存（至少 512MB，推荐 1GB+）
3. 重新部署

### 错误 2：权限不足 (Permission denied)

**症状：**
```
Error: EACCES: permission denied, mkdir '/data/.clawdbot'
```

**解决方案：**

**方法 A：添加 Volume（推荐）**
1. 在服务中添加 Volume
2. Mount Path 设置为 `/data`
3. 在环境变量中设置 `CLAWDBOT_STATE_DIR=/data/.clawdbot`
4. 重新部署

**方法 B：使用用户目录（临时方案）**
如果无法使用 Volume，设置：
- `CLAWDBOT_STATE_DIR=/home/node/.clawdbot`
- 注意：数据不会持久化，重启会丢失

### 错误 3：健康检查失败

**排查步骤：**

1. **查看部署日志**
   - 在 **Deploy Logs** 中查找：
     - `Starting Moltbot Gateway on Railway...`
     - `PORT=8080`
     - `Health check endpoint: http://0.0.0.0:8080/health`

2. **检查端口监听**
   - 确保应用正确监听端口
   - 日志中应该显示服务器已启动
   - 没有端口冲突错误

3. **检查环境变量**
   - 确保 `PORT` 环境变量已设置
   - 值应该是 `8080`（或 Railway 自动分配的值）

4. **手动测试**
   - 部署成功后，访问 `https://你的域名/health`
   - 应该返回 `{"status":"ok","timestamp":"..."}`

## 常见问题

### Q: 为什么看不到 Public Networking 选项？

A: 可能的原因：
1. 部署还未成功完成
2. Railway 界面版本不同，选项位置不同
3. 某些计划可能不包含此功能
4. Railway 可能已自动配置，检查服务卡片上的域名

### Q: 健康检查一直失败怎么办？

A: 
1. 检查部署日志中的错误信息
2. 确认 `PORT` 环境变量已设置
3. 确认应用已成功启动（查看日志）
4. 尝试增加健康检查超时时间

### Q: 应用启动需要多长时间？

A: 
- 首次启动可能需要 30-60 秒
- 健康检查超时设置为 300 秒（5 分钟）
- 如果超过 5 分钟仍未启动，检查日志中的错误

## 下一步

部署成功后：
1. 访问 `/setup` 完成配置
2. 在 Telegram 中测试 Bot
3. 根据需要调整配置
