@echo off
echo Setting up Android development environment...

REM Check if Java is installed (try as Administrator)
runas /user:Administrator "java -version" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java JDK is not accessible
    echo Please ensure Java is installed and accessible
    pause
    exit /b 1
) else (
    echo Java found in Administrator context
    echo Note: You may need to run builds as Administrator
)

REM Check Android SDK in multiple locations
set SDK_FOUND=0
if exist "%LOCALAPPDATA%\Android\Sdk" (
    echo Android SDK found at %LOCALAPPDATA%\Android\Sdk
    set SDK_FOUND=1
    set SDK_PATH=%LOCALAPPDATA%\Android\Sdk
) else if exist "C:\Users\Administrator\AppData\Local\Android\Sdk" (
    echo Android SDK found at C:\Users\Administrator\AppData\Local\Android\Sdk
    set SDK_FOUND=1
    set SDK_PATH=C:\Users\Administrator\AppData\Local\Android\Sdk
) else if exist "C:\Program Files\Android\android-sdk" (
    echo Android SDK found at C:\Program Files\Android\android-sdk
    set SDK_FOUND=1
    set SDK_PATH=C:\Program Files\Android\android-sdk
) else if exist "C:\Program Files (x86)\Android\android-sdk" (
    echo Android SDK found at C:\Program Files (x86)\Android\android-sdk
    set SDK_FOUND=1
    set SDK_PATH=C:\Program Files (x86)\Android\android-sdk
)

if %SDK_FOUND%==0 (
    echo WARNING: Android SDK not found in common locations
    echo Please install Android SDK through Android Studio
    echo Or manually install from: https://developer.android.com/studio#downloads
) else (
    REM Update local.properties
    echo sdk.dir=%SDK_PATH:\=\\%> app\local.properties
    echo Updated local.properties with SDK path
)

echo Environment setup complete!
echo Note: You may need to run 'build-as-admin.bat' for building
pause