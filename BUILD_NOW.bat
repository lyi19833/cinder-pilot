@echo off
echo =========================================
echo   立即构建APK - 最简方法
echo =========================================
echo.

echo 正在检查环境...
if not exist "gradlew.bat" (
    echo 错误: gradlew.bat文件不存在！
    pause
    exit /b 1
)

echo.
echo 步骤1: 确保Gradle Wrapper配置正确...
if not exist "gradle\wrapper\gradle-wrapper.properties" (
    echo 正在创建gradle-wrapper.properties文件...
    echo #Mon Dec 02 15:00:00 CST 2024>gradle\wrapper\gradle-wrapper.properties
    echo distributionBase=GRADLE_USER_HOME>>gradle\wrapper\gradle-wrapper.properties
    echo distributionPath=wrapper/dists>>gradle\wrapper\gradle-wrapper.properties
    echo distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip>>gradle\wrapper\gradle-wrapper.properties
    echo networkTimeout=120000>>gradle\wrapper\gradle-wrapper.properties
    echo zipStoreBase=GRADLE_USER_HOME>>gradle\wrapper\gradle-wrapper.properties
    echo zipStorePath=wrapper/dists>>gradle\wrapper\gradle-wrapper.properties
    echo ✅ Gradle Wrapper配置完成
)

echo.
echo 步骤2: 清理可能存在的缓存...
if exist "%USERPROFILE%\.gradle" (
    echo 注意: 如果构建失败，可能需要手动清理 %USERPROFILE%\.gradle 目录
)

echo.
echo 步骤3: 开始构建APK...
echo 这可能需要几分钟时间，请耐心等待...
echo.

setlocal enabledelayedexpansion
set "outputFile="

echo ==================== 构建开始 ====================
.\gradlew.bat assembleDebug --no-daemon 2>&1 | tee build.log

if %errorlevel% equ 0 (
    echo.
    echo ==================== 构建成功! ====================
    
    rem 查找APK文件
    for /r "app\build\outputs\apk" %%f in (*.apk) do (
        if not defined outputFile (
            set "outputFile=%%f"
            echo ✅ APK文件位置: %%f
            echo 📱 文件大小: %%~zf 字节
            echo.
            echo 📋 APK信息:
            echo   路径: %%~dpnxf
            echo   大小: %%~zf 字节
            echo   修改时间: %%~tf
        )
    )
    
    if defined outputFile (
        echo.
        echo 🔧 如何安装:
        echo   1. 将上面的APK文件复制到手机
        echo   2. 在手机文件管理器中找到并安装
        echo   3. 可能需要开启"允许安装未知来源应用"
        echo.
        echo   或者使用ADB命令:
        echo   adb install "!outputFile!"
    ) else (
        echo ⚠️  构建成功但未找到APK文件
        echo   请检查: app\build\outputs\apk\debug\ 目录
    )
    
    echo.
    echo 📁 构建日志已保存到: build.log
) else (
    echo.
    echo ==================== 构建失败! ====================
    echo ❌ 构建过程中出现错误
    echo.
    echo 🔍 查看详细错误日志:
    echo   1. 查看 build.log 文件
    echo   2. 或在上面查看错误信息
    echo.
    echo 💡 解决方案:
    echo   1. 运行 FORCE_CORRECT_GRADLE.bat 修复环境
    echo   2. 手动删除 %USERPROFILE%\.gradle 目录后重试
    echo   3. 使用GitHub云构建: 运行 OPEN_GITHUB.bat
)

echo.
pause