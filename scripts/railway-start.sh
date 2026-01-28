#!/bin/sh
# Railway 启动脚本
# 从 PORT 环境变量读取端口，如果没有则使用 8080
# 使用 --allow-unconfigured 允许在没有完整配置时启动（通过 /setup 完成配置）

PORT=${PORT:-8080}

# 设置状态目录（如果未设置，使用 /data/.clawdbot）
if [ -z "$CLAWDBOT_STATE_DIR" ]; then
  export CLAWDBOT_STATE_DIR="/data/.clawdbot"
fi

# 确保状态目录存在
# Railway Volume 挂载到 /data，应该允许 node 用户写入
# 如果无法创建，应用会使用默认位置（~/.clawdbot），但数据不会持久化
if [ -n "$CLAWDBOT_STATE_DIR" ]; then
  # 尝试创建目录（可能因为权限失败，但不影响应用启动）
  mkdir -p "$CLAWDBOT_STATE_DIR" 2>/dev/null || {
    echo "Warning: Could not create $CLAWDBOT_STATE_DIR, app will use default location"
  }
fi

# 输出启动信息（用于调试）
echo "Starting Moltbot Gateway on Railway..."
echo "PORT=${PORT}"
echo "CLAWDBOT_STATE_DIR=${CLAWDBOT_STATE_DIR}"
echo "Health check endpoint: http://0.0.0.0:${PORT}/health"

# 如果没有设置 GATEWAY_TOKEN，使用默认值（用户应通过 /setup 或环境变量设置）
# 重要：在生产环境中，请在 Railway 环境变量中设置 CLAWDBOT_GATEWAY_TOKEN
if [ -z "$CLAWDBOT_GATEWAY_TOKEN" ]; then
  # 使用默认 token（仅用于初始启动，用户应通过 /setup 页面重新配置）
  export CLAWDBOT_GATEWAY_TOKEN="railway-temp-token-change-me"
  echo "Using default gateway token (set CLAWDBOT_GATEWAY_TOKEN env var to override)"
fi

# 设置 Node.js 内存限制（优先使用环境变量，否则使用默认值）
# Railway 建议通过环境变量 NODE_OPTIONS 设置，更灵活
# 如果未设置，使用 2GB 作为默认值（可以根据 Railway 资源调整）
if [ -z "$NODE_OPTIONS" ]; then
  export NODE_OPTIONS="--max-old-space-size=2048"
  echo "Using default NODE_OPTIONS=${NODE_OPTIONS} (set NODE_OPTIONS env var to override)"
else
  echo "Using NODE_OPTIONS=${NODE_OPTIONS} from environment"
fi

# 启动应用
exec node dist/index.js gateway --bind lan --port "$PORT" --allow-unconfigured
