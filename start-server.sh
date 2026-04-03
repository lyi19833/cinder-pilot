#!/bin/bash

# 远程控制服务器测试脚本

echo "🚀 远程控制服务器测试"
echo "====================="

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js 未安装"
    exit 1
fi

echo "✅ Node.js 版本: $(node -v)"

# 检查依赖
cd server
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    npm install
fi

# 启动服务器
echo ""
echo "🌐 启动服务器..."
echo "服务器地址: ws://localhost:8080"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

npm start
