#!/bin/sh
# Railway 启动脚本
# 从 PORT 环境变量读取端口，如果没有则使用 8080

PORT=${PORT:-8080}
exec node dist/index.js gateway --bind lan --port "$PORT"
