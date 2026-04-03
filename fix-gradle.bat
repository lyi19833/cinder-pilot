@echo off
echo Fixing Gradle issues...

REM Clear Gradle cache
echo Clearing Gradle cache...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Gradle caches cleared.
)

REM Clear project-specific Gradle files
echo Clearing project Gradle files...
if exist "app\.gradle" (
    rmdir /s /q "app\.gradle"
)
if exist ".gradle" (
    rmdir /s /q ".gradle"
)

REM Stop Gradle daemons
echo Stopping Gradle daemons...
call gradlew --stop 2>nul

echo.
echo Gradle cache cleared. Now try building again.
echo.
echo If you still get errors, try:
echo 1. Close Android Studio
echo 2. Kill all Java processes in Task Manager
echo 3. Restart Android Studio and rebuild
echo.
pause