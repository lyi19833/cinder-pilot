@echo off
echo Building Android project...
echo.
echo IMPORTANT: This script requires Administrator privileges to access Java.
echo If prompted for password, enter the Administrator password.
echo.
echo If you prefer, you can:
echo 1. Right-click Android Studio ^> "Run as administrator"
echo 2. Open the project and build normally
echo.
echo Starting build process...
echo.

REM Run gradle build as Administrator
runas /user:Administrator "cd /d \"%~dp0app\" && gradlew.bat build"

if %errorlevel% neq 0 (
    echo.
    echo Build failed or was cancelled.
    echo Try running Android Studio as Administrator instead.
) else (
    echo.
    echo Build completed successfully!
)

echo.
pause