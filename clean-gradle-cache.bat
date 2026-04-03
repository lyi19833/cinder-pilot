@echo off
echo 清理Gradle缓存...
echo.

echo 停止所有Gradle守护进程...
gradle --stop

echo.
echo 清理Gradle缓存目录...
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
)
if exist "%USERPROFILE%\.gradle\wrapper\dists" (
    rmdir /s /q "%USERPROFILE%\.gradle\wrapper\dists"
)

echo.
echo 清理项目构建目录...
if exist "build" (
    rmdir /s /q "build"
)
if exist "app\build" (
    rmdir /s /q "app\build"
)

echo.
echo 重新下载Gradle包装器...
gradle wrapper --gradle-version 8.5

echo.
echo 清理完成！请重新打开IDE并同步项目。