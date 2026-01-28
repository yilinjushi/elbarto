#!/bin/sh
# Railway 启动脚本
# 从 PORT 环境变量读取端口，如果没有则使用 8080
# 使用 --allow-unconfigured 允许在没有完整配置时启动（通过 /setup 完成配置）

PORT=${PORT:-8080}

# 输出启动信息（用于调试）
echo "Starting Moltbot Gateway on Railway..."
echo "PORT=${PORT}"
echo "Health check endpoint: http://0.0.0.0:${PORT}/health"

# 如果没有设置 GATEWAY_TOKEN，使用默认值（用户应通过 /setup 或环境变量设置）
# 重要：在生产环境中，请在 Railway 环境变量中设置 CLAWDBOT_GATEWAY_TOKEN
if [ -z "$CLAWDBOT_GATEWAY_TOKEN" ]; then
  # 使用默认 token（仅用于初始启动，用户应通过 /setup 页面重新配置）
  export CLAWDBOT_GATEWAY_TOKEN="railway-temp-token-change-me"
  echo "Using default gateway token (set CLAWDBOT_GATEWAY_TOKEN env var to override)"
fi

# 启动应用
exec node dist/index.js gateway --bind lan --port "$PORT" --allow-unconfigured
