@echo off
echo Downloading Gradle wrapper...

if not exist "gradle\wrapper" (
    mkdir gradle\wrapper 2>nul
)

cd gradle\wrapper

REM Download gradle-wrapper.jar
echo Downloading gradle-wrapper.jar...
powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle-wrapper.jar'}"

if exist "gradle-wrapper.jar" (
    echo Gradle wrapper downloaded successfully.
) else (
    echo Failed to download gradle-wrapper.jar
    echo You can manually download it from:
    echo https://github.com/gradle/gradle/raw/v8.4.0/gradle/wrapper/gradle-wrapper.jar
    echo And place it in gradle\wrapper\ directory
)

cd ..\..
echo.
echo Now try building your project again.
pause