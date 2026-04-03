@echo off
echo 正在结束所有Java相关进程...
echo.

echo 1. 结束Java进程...
taskkill /f /im java.exe 2>nul
if errorlevel 1 echo 没有找到java.exe进程

echo 2. 结束Java窗口进程...
taskkill /f /im javaw.exe 2>nul
if errorlevel 1 echo 没有找到javaw.exe进程

echo 3. 结束Gradle进程...
taskkill /f /im gradle.exe 2>nul
if errorlevel 1 echo 没有找到gradle.exe进程

echo 4. 结束Java启动器进程...
taskkill /f /im jp2launcher.exe 2>nul
if errorlevel 1 echo 没有找到jp2launcher.exe进程

echo 5. 结束子进程...
taskkill /f /fi "IMAGENAME eq java.exe" /t 2>nul
taskkill /f /fi "IMAGENAME eq javaw.exe" /t 2>nul

echo.
echo =========================================
echo 所有Java相关进程已结束！
echo.
echo 现在可以：
echo 1. 重新打开Android Studio
echo 2. 打开项目：c:\Users\nora\cinder-pilot
echo 3. 等待Gradle同步完成
echo =========================================
echo.
pause