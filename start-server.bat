@echo off
REM 远程控制服务器启动脚本（Windows）

echo 🚀 远程控制服务器启动
echo =====================

REM 检查 Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js 未安装
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo ✅ Node.js 版本: %NODE_VERSION%

REM 进入 server 目录
cd server

REM 检查依赖
if not exist "node_modules" (
    echo 📦 安装依赖...
    call npm install
)

REM 启动服务器
echo.
echo 🌐 启动服务器...
echo 服务器地址: ws://localhost:8080
echo.
echo 按 Ctrl+C 停止服务器
echo.

call npm start
