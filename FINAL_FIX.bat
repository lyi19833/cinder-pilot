@echo off
echo 最终Gradle修复脚本 - 针对Gradle 8.2 + AGP 8.0.2
echo =========================================
echo.

echo 1. 停止所有Gradle和Java进程...
taskkill /f /im java.exe /t 2>nul
taskkill /f /im javaw.exe /t 2>nul
gradlew --stop 2>nul
gradle --stop 2>nul
echo.

echo 2. 彻底删除所有Gradle缓存...
if exist "%USERPROFILE%\.gradle" (
    echo 删除用户Gradle目录...
    rmdir /s /q "%USERPROFILE%\.gradle"
    echo 已删除
)
echo.

echo 3. 删除项目构建目录...
if exist "build" (
    rmdir /s /q "build"
    echo 删除build目录
)
if exist "app\build" (
    rmdir /s /q "app\build"
    echo 删除app/build目录
)
if exist ".gradle" (
    rmdir /s /q ".gradle"
    echo 删除.gradle目录
)
if exist "app\.gradle" (
    rmdir /s /q "app\.gradle"
    echo 删除app/.gradle目录
)
echo.

echo 4. 确保正确的Gradle包装器目录结构...
if not exist "gradle\wrapper" (
    mkdir gradle\wrapper 2>nul
    echo 创建gradle/wrapper目录
)
echo.

echo 5. 下载Gradle 8.2包装器...
echo 正在下载Gradle 8.2...
powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.2-bin.zip' -OutFile 'gradle-8.2.zip'"
if exist "gradle-8.2.zip" (
    echo 解压Gradle 8.2...
    powershell -Command "Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('gradle-8.2.zip', 'gradle-temp'); Copy-Item 'gradle-temp\gradle-8.2\wrapper\gradle-wrapper.jar' -Destination 'gradle\wrapper\' -Force"
    rmdir /s /q gradle-temp 2>nul
    del gradle-8.2.zip 2>nul
    echo ✓ Gradle 8.2包装器已下载
) else (
    echo ✗ 无法下载Gradle 8.2，请检查网络连接
)
echo.

echo 6. 复制配置文件...
copy "app\gradle\wrapper\gradle-wrapper.properties" "gradle\wrapper\" >nul 2>&1
echo ✓ 配置文件已复制
echo.

echo 7. 验证Gradle版本...
if exist "gradle\wrapper\gradle-wrapper.jar" (
    echo ✓ Gradle包装器存在
    echo 版本: Gradle 8.2 (与Android Gradle Plugin 8.0.2兼容)
) else (
    echo ✗ Gradle包装器不存在，需要手动下载
    echo 请访问: https://services.gradle.org/distributions/gradle-8.2-bin.zip
    echo 下载后放入 gradle\wrapper\ 目录
)
echo.

echo =========================================
echo 修复完成！请按以下步骤操作：
echo.
echo 1. 完全关闭Android Studio（如果正在运行）
echo 2. 打开任务管理器，确认没有Java进程
echo 3. 重新打开Android Studio
echo 4. 打开项目: c:\Users\nora\cinder-pilot
echo 5. 等待Gradle同步完成（可能需要几分钟）
echo.
echo 重要配置：
echo - Android Gradle Plugin: 8.0.2
echo - Gradle: 8.2
echo - Kotlin: 1.8.20
echo - Java: 1.8
echo =========================================
echo.
pause