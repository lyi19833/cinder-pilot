@echo off
echo 手动构建APK - 绕过Android Studio
echo =========================================
echo.

echo 步骤1: 检查Java环境...
java -version 2>nul
if errorlevel 1 (
    echo 错误: Java未安装或未配置
    echo 请安装Java 8或11
    pause
    exit /b 1
)
echo.

echo 步骤2: 检查Android SDK...
if not exist "app\local.properties" (
    echo 错误: local.properties文件不存在
    echo 请创建 app/local.properties 并设置sdk.dir
    echo 例如: sdk.dir=C:\\Users\\你的用户名\\AppData\\Local\\Android\\Sdk
    pause
    exit /b 1
)
echo.

echo 步骤3: 检查Gradle包装器...
if not exist "gradle\wrapper\gradle-wrapper.jar" (
    echo 正在下载Gradle包装器...
    mkdir gradle\wrapper 2>nul
    powershell -Command "Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.2-bin.zip' -OutFile 'gradle-8.2.zip'"
    if exist "gradle-8.2.zip" (
        powershell -Command "Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('gradle-8.2.zip', 'gradle-temp'); Copy-Item 'gradle-temp\gradle-8.2\wrapper\gradle-wrapper.jar' -Destination 'gradle\wrapper\'"
        rmdir /s /q gradle-temp 2>nul
        del gradle-8.2.zip 2>nul
        echo ✓ Gradle包装器已下载
    ) else (
        echo ✗ 无法下载Gradle包装器
        pause
        exit /b 1
    )
)
echo.

echo 步骤4: 复制gradle-wrapper.properties...
if not exist "gradle\wrapper\gradle-wrapper.properties" (
    copy "app\gradle\wrapper\gradle-wrapper.properties" "gradle\wrapper\" >nul 2>&1
    echo ✓ 配置文件已复制
)
echo.

echo 步骤5: 创建gradlew.bat...
if not exist "gradlew.bat" (
    @echo off > gradlew.bat
    echo @rem >> gradlew.bat
    echo @rem Copyright 2015 the original author or authors. >> gradlew.bat
    echo @rem >> gradlew.bat
    echo @rem Licensed under the Apache License, Version 2.0 ^(the "License"^); >> gradlew.bat
    echo @rem you may not use this file except in compliance with the License. >> gradlew.bat
    echo @rem You may obtain a copy of the License at >> gradlew.bat
    echo @rem >> gradlew.bat
    echo @rem      https://www.apache.org/licenses/LICENSE-2.0 >> gradlew.bat
    echo @rem >> gradlew.bat
    echo @rem Unless required by applicable law or agreed to in writing, software >> gradlew.bat
    echo @rem distributed under the License is distributed on an "AS IS" BASIS, >> gradlew.bat
    echo @rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. >> gradlew.bat
    echo @rem See the License for the specific language governing permissions and >> gradlew.band .bat
    echo @rem limitations under the License. >> gradlew.bat
    echo @rem >> gradlew.bat
    echo. >> gradlew.bat
    echo @if "%%DEBUG%%"=="" @echo off >> gradlew.bat
    echo. >> gradlew.bat
    echo set DIRNAME=%%~dp0 >> gradlew.bat
    echo if "%%DIRNAME%%"=="" set DIRNAME=. >> gradlew.bat
    echo set APP_BASE_NAME=%%~n0 >> gradlew.bat
    echo set APP_HOME=%%DIRNAME%% >> gradlew.bat
    echo. >> gradlew.bat
    echo set JAVA_EXE=java.exe >> gradlew.bat
    echo if %%JAVA_EXE%% . equ . ( >> gradlew.bat
    echo   set JAVA_EXE=java >> gradlew.bat
    echo ) >> gradlew.bat
    echo. >> gradlew.bat
    echo set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m" >> gradlew.bat
    echo. >> gradlew.bat
    echo set CLASSPATH=%%APP_HOME%%\gradle\wrapper\gradle-wrapper.jar >> gradlew.bat
    echo. >> gradlew.bat
    echo rem Execute Gradle >> gradlew.bat
    echo "%%JAVA_EXE%%" %%DEFAULT_JVM_OPTS%% %%JAVA_OPTS%% %%GRADLE_OPTS%% "-Dorg.gradle.appname=%%APP_BASE_NAME%%" -classpath "%%CLASSPATH%%" org.gradle.wrapper.GradleWrapperMain %%* >> gradlew.bat
    echo. >> gradlew.bat
    echo :end >> gradlew.bat
    echo @rem End local scope for the variables with windows NT shell >> gradlew.bat
    echo if %%ERRORLEVEL%% equ 0 goto mainEnd >> gradlew.bat
    echo. >> gradlew.bat
    echo :fail >> gradlew.bat
    echo rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of >> gradlew.bat
    echo rem the _cmd.exe /c_ return code! >> gradlew.bat
    echo set EXIT_CODE=%%ERRORLEVEL%% >> gradlew.bat
    echo if %%EXIT_CODE%% equ 0 set EXIT_CODE=1 >> gradlew.bat
    echo if not ""=="%%GRADLE_EXIT_CONSOLE%%" exit /b %%EXIT_CODE%% >> gradlew.bat
    echo exit /b %%EXIT_CODE%% >> gradlew.bat
    echo. >> gradlew.bat
    echo :mainEnd >> gradlew.bat
    echo if "%%OS%%"=="Windows_NT" endlocal >> gradlew.bat
    echo. >> gradlew.bat
    echo :omega >> gradlew.bat
    echo ✓ gradlew.bat已创建
)
echo.

echo 步骤6: 开始构建APK...
echo 注意: 这可能需要几分钟，请耐心等待...
echo.

gradlew.bat clean assembleDebug

if errorlevel 1 (
    echo.
    echo =========================================
    echo 构建失败！
    echo 尝试使用离线模式...
    echo =========================================
    echo.
    
    echo 编辑gradle.properties启用离线模式...
    echo org.gradle.offline=true >> gradle.properties
    
    echo 重新尝试构建...
    gradlew.bat clean assembleDebug --offline
    
    if errorlevel 1 (
        echo.
        echo =========================================
        echo 离线构建也失败！
        echo 请检查以下问题：
        echo 1. Android SDK路径是否正确
        echo 2. 网络连接是否正常
        echo 3. Java版本是否兼容
        echo =========================================
    ) else (
        echo.
        echo =========================================
        echo ✓ 离线构建成功！
        echo APK位置: app\build\outputs\apk\debug\app-debug.apk
        echo =========================================
    )
) else (
    echo.
    echo =========================================
    echo ✓ 构建成功！
    echo APK位置: app\build\outputs\apk\debug\app-debug.apk
    echo =========================================
)

echo.
pause