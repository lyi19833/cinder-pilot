@echo off
echo Downloading Gradle wrapper...

if not exist "gradle\wrapper" (
    mkdir gradle\wrapper 2>nul
)

cd gradle\wrapper

REM Download gradle-wrapper.jar for Gradle 8.5
echo Downloading gradle-wrapper.jar for Gradle 8.5...
powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/gradle/gradle/raw/v8.5.0/gradle/wrapper/gradle-wrapper.jar' -OutFile 'gradle-wrapper.jar'}"

if exist "gradle-wrapper.jar" (
    echo Gradle wrapper downloaded successfully.
) else (
    echo Failed to download gradle-wrapper.jar
    echo Trying alternative source...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://services.gradle.org/distributions/gradle-8.5-bin.zip' -OutFile 'gradle-8.5.zip'}"
    if exist "gradle-8.5.zip" (
        powershell -Command "& {Add-Type -Assembly 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::ExtractToDirectory('gradle-8.5.zip', 'temp'); Copy-Item 'temp\gradle-8.5\wrapper\gradle-wrapper.jar' -Destination '.'}"
        rmdir /s /q temp 2>nul
        del gradle-8.5.zip 2>nul
        echo Gradle wrapper extracted from distribution zip.
    ) else (
        echo Failed to download gradle-wrapper.jar
        echo You can manually download it from:
        echo https://github.com/gradle/gradle/raw/v8.5.0/gradle/wrapper/gradle-wrapper.jar
        echo And place it in gradle\wrapper\ directory
    )
)

cd ..\..
echo.
echo Now try building your project again.
pause