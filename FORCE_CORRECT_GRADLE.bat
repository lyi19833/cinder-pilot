@echo off
echo 强制修复Gradle版本问题...
echo.

echo 1. 停止所有Gradle进程...
gradlew --stop 2>nul
gradle --stop 2>nul
echo.

echo 2. 删除所有Gradle缓存...
if exist "%USERPROFILE%\.gradle" (
    echo 删除用户Gradle缓存...
    rmdir /s /q "%USERPROFILE%\.gradle"
)

echo 3. 删除项目构建目录...
if exist "build" (
    rmdir /s /q "build"
)
if exist "app\build" (
    rmdir /s /q "app\build"
)
if exist ".gradle" (
    rmdir /s /q ".gradle"
)
if exist "app\.gradle" (
    rmdir /s /q "app\.gradle"
)

echo 4. 确保正确的Gradle包装器存在...
if not exist "gradle" mkdir gradle
if not exist "gradle\wrapper" mkdir gradle\wrapper

echo 5. 下载Gradle 8.6包装器...
echo 正在下载gradle-wrapper.jar...
powershell -Command "Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.6-bin.zip' -OutFile 'gradle-8.6.zip'"
if exist "gradle-8.6.zip" (
    echo 解压gradle-wrapper.jar...
    powershell -Command "Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('gradle-8.6.zip', 'gradle-temp'); Copy-Item 'gradle-temp\gradle-8.6\wrapper\gradle-wrapper.jar' -Destination 'gradle\wrapper\'"
    rmdir /s /q gradle-temp 2>nul
    del gradle-8.6.zip 2>nul
    echo Gradle 8.6包装器已下载。
) else (
    echo 警告: 无法下载Gradle 8.6，使用现有版本。
)

echo 6. 复制gradle-wrapper.properties...
copy "app\gradle\wrapper\gradle-wrapper.properties" "gradle\wrapper\" >nul 2>&1

echo.
echo =========================================
echo 强制修复完成！
echo.
echo 接下来步骤：
echo 1. 完全关闭Android Studio
echo 2. 打开任务管理器，结束所有Java进程
echo 3. 重新打开Android Studio
echo 4. 等待Gradle同步完成
echo =========================================
echo.
pause