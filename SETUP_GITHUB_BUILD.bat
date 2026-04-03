@echo off
echo GitHub云构建设置脚本
echo =========================================
echo.

echo 步骤1: 初始化Git仓库...
git init
if errorlevel 1 (
    echo 错误: Git未安装
    echo 请先安装Git: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✓ Git仓库已初始化
echo.

echo 步骤2: 配置用户信息...
echo 请输入你的GitHub用户名:
set /p GITHUB_USERNAME=
echo 请输入你的邮箱:
set /p GITHUB_EMAIL=

git config user.name "%GITHUB_USERNAME%"
git config user.email "%GITHUB_EMAIL%"
echo ✓ Git用户信息已配置
echo.

echo 步骤3: 添加所有文件到Git...
git add .
echo ✓ 文件已添加到暂存区
echo.

echo 步骤4: 提交初始版本...
git commit -m "Initial commit: Android project with GitHub Actions"
if errorlevel 1 (
    echo 警告: 提交失败，可能没有文件变更
    echo 继续下一步...
)
echo.

echo 步骤5: 在GitHub创建新仓库...
echo 请按以下步骤操作:
echo 1. 打开 https://github.com/new
echo 2. 输入仓库名: cinder-pilot
echo 3. 不要勾选"Initialize with README"
echo 4. 点击"Create repository"
echo.
echo 创建后，你会看到以下命令:
echo   git remote add origin https://github.com/%GITHUB_USERNAME%/cinder-pilot.git
echo   git push -u origin main
echo.
echo 请复制上面的命令并在此运行
echo.

echo 步骤6: 推送代码到GitHub...
echo 输入远程仓库URL (例如: https://github.com/你的用户名/cinder-pilot.git):
set /p REMOTE_URL=

git remote add origin "%REMOTE_URL%"
git branch -M main
git push -u origin main

if errorlevel 1 (
    echo.
    echo 错误: 推送失败
    echo 可能原因:
    echo 1. 网络问题
    echo 2. 认证失败
    echo 3. 仓库不存在
    echo.
    echo 请手动推送:
    echo   1. 打开Git Bash或命令提示符
    echo   2. cd c:\Users\nora\cinder-pilot
    echo   3. git push -u origin main
) else (
    echo.
    echo ✓ 代码已推送到GitHub
)
echo.

echo =========================================
echo 设置完成！
echo.
echo 接下来:
echo 1. 访问: https://github.com/%GITHUB_USERNAME%/cinder-pilot
echo 2. 点击"Actions"标签页
echo 3. 等待构建完成（约5-10分钟）
echo 4. 下载构建好的APK
echo.
echo 重要: GitHub Actions会自动构建APK
echo 构建成功后，可以在Actions页面下载APK
echo =========================================
echo.
pause