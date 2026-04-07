@echo off
echo =========================================
echo    GitHub云构建快捷访问
echo =========================================
echo.
echo 项目地址: https://github.com/lyi19833/cinder-pilot
echo.
echo 请选择要访问的页面:
echo 1. 仓库主页
echo 2. Actions构建页面
echo 3. 构建指南文档
echo 4. 退出
echo.

set /p choice="请输入选项(1-4): "

if "%choice%"=="1" (
    start "" "https://github.com/lyi19833/cinder-pilot"
) else if "%choice%"=="2" (
    start "" "https://github.com/lyi19833/cinder-pilot/actions"
) else if "%choice%"=="3" (
    start "" "https://github.com/lyi19833/cinder-pilot/blob/main/GITHUB_BUILD_GUIDE.md"
) else if "%choice%"=="4" (
    exit
) else (
    echo 无效选项，请重新运行！
    pause
)