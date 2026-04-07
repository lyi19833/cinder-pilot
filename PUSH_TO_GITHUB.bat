@echo off
echo 推送代码到GitHub
echo ==============================
echo.

echo 请先完成以下步骤:
echo 1. 访问 https://github.com/new
echo 2. 创建仓库: cinder-pilot
echo 3. 不要勾选"Initialize with README"
echo 4. 点击"Create repository"
echo.
echo 创建后，你会看到类似这样的命令:
echo   git remote add origin https://github.com/YOUR_USERNAME/cinder-pilot.git
echo   git branch -M main
echo   git push -u origin main
echo.
echo 请告诉我你的GitHub用户名:
set /p GITHUB_USERNAME=

echo.
echo 正在设置远程仓库...
git remote add origin https://github.com/%GITHUB_USERNAME%/cinder-pilot.git
git branch -M main

echo.
echo 正在推送代码到GitHub...
echo 注意: 可能会要求输入用户名密码
echo 如果使用GitHub Token，请用Token代替密码
echo.
git push -u origin main

echo.
if errorlevel 1 (
    echo 推送失败！
    echo 可能原因:
    echo 1. 仓库不存在
    echo 2. 认证失败
    echo 3. 网络问题
    echo.
    echo 请手动执行:
    echo   git push -u origin main
) else (
    echo ✓ 代码已推送到GitHub！
    echo.
    echo 下一步:
    echo 1. 访问 https://github.com/%GITHUB_USERNAME%/cinder-pilot
    echo 2. 点击"Actions"标签页
    echo 3. 等待构建完成（约5-10分钟）
    echo 4. 下载APK
)

echo.
pause