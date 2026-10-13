#!/usr/bin/env bash
# 永不复还(500F) -> mota-js 一键启动脚本 (macOS / Linux / Node.js)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOTA_DIR="${SCRIPT_DIR}/_analysis/_ybfh-mota"

echo "🌌 [Anti] 正在启动 mota-js 开发服务..."
echo "📂 工程目录: ${MOTA_DIR}"

if ! command -v node >/dev/null 2>&1; then
    echo "❌ 未检测到 Node.js，请先安装 Node (brew install node)"
    exit 1
fi

cd "${MOTA_DIR}"
exec node server.js
