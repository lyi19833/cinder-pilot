@echo off
echo =========================================
echo    Android APK构建测试
echo =========================================
echo.

echo 1. 检查Gradle Wrapper...
if not exist "gradle\wrapper\gradle-wrapper.properties" (
    echo 错误: gradle-wrapper.properties文件不存在！
    pause
    exit /b 1
)

echo 2. 检查Gradle版本...
type gradle\wrapper\gradle-wrapper.properties | find "distributionUrl"

echo.
echo 3. 开始构建APK...
echo 注意: 这可能需要几分钟时间...
echo.

call gradlew assembleDebug

if %errorlevel% equ 0 (
    echo.
    echo =========================================
    echo   ✅ 构建成功！
    echo =========================================
    echo APK文件位置: app\build\outputs\apk\debug\app-debug.apk
    echo.
    echo 文件大小: 
    if exist "app\build\outputs\apk\debug\app-debug.apk" (
        for %%F in ("app\build\outputs\apk\debug\app-debug.apk") do echo   %%~zF 字节
    )
    echo.
    echo 你可以:
    echo 1. 将APK复制到手机安装
    echo 2. 使用Android Studio运行到模拟器
    echo 3. 使用ADB安装: adb install app\build\outputs\apk\debug\app-debug.apk
) else (
    echo.
    echo =========================================
    echo   ❌ 构建失败！
    echo =========================================
    echo 请查看上面的错误信息
    echo.
    echo 备选方案:
    echo 1. 使用GitHub云构建: https://github.com/lyi19833/cinder-pilot/actions
    echo 2. 运行 FORCE_CORRECT_GRADLE.bat 修复Gradle
    echo 3. 运行 BUILD_APK_MANUALLY.bat 手动构建
)

echo.
pause