# Build Android project with proper Java configuration
Write-Host "Building Android project..." -ForegroundColor Green
Write-Host ""

# Try to find Java in Administrator context
Write-Host "Checking Java availability..." -ForegroundColor Yellow
try {
    $javaCheck = & runas /user:Administrator "java -version 2>&1" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Java is available in Administrator context" -ForegroundColor Green
    } else {
        throw "Java not accessible"
    }
} catch {
    Write-Host "ERROR: Cannot access Java in Administrator context" -ForegroundColor Red
    Write-Host "Please ensure Java is properly installed" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Android SDK
$sdkPath = "C:\Users\Administrator\AppData\Local\Android\Sdk"
if (-not (Test-Path $sdkPath)) {
    $sdkPath = "$env:LOCALAPPDATA\Android\Sdk"
    if (-not (Test-Path $sdkPath)) {
        Write-Host "WARNING: Android SDK not found" -ForegroundColor Yellow
        Write-Host "Please install Android SDK through Android Studio" -ForegroundColor Yellow
    }
}

if (Test-Path $sdkPath) {
    Write-Host "Android SDK found at: $sdkPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "To build the project, please:" -ForegroundColor Cyan
Write-Host "1. Right-click Android Studio" -ForegroundColor White
Write-Host "2. Select 'Run as administrator'" -ForegroundColor White
Write-Host "3. Open the project in Android Studio" -ForegroundColor White
Write-Host "4. Build the project normally" -ForegroundColor White
Write-Host ""
Write-Host "This ensures Android Studio runs with access to Java." -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to continue"